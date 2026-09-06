+++
date = '2026-09-06T20:15:00+02:00'
draft = false
title = "Twenty-Four Idle Minutes: Splitting One Jenkins Pipeline Into Four"
useAlpine = false
tags = [
    "jenkins",
    "ci-cd",
    "tapedeck",
    "rust",
    "cargo",
    "pipeline-design",
    "self-hosting",
    "cross-architecture",
    "glibc",
    "build-provenance",
    "homelab"
]
+++

*On what happens when you actually measure a build pipeline instead of reasoning about it, and why four jobs turned out to be fewer moving parts than one.*

Tapedeck[^1] — my self-hosted music journal, the one I wrote about at length in [What the Scrobble Throws Away](/posts/what-the-scrobble-throws-away/) — has had continuous integration since roughly the point where it stopped being a toy. One Jenkins pipeline. It checked out the source, ran the tests, built a release binary, and pushed that binary onto the Raspberry Pi 4B that four people in this household actually use. It worked. For months it worked, in the sense that green builds appeared and the thing on the Pi was the thing in the repository.

The trouble with a pipeline that works is that you stop looking at it.

I looked at it this weekend because I wanted something else — a release pipeline, the kind that produces downloadable binaries and multi-architecture container images when I push a tag — and it became obvious within about ten minutes that I could not build that on top of what I had. Not because the existing pipeline was wrong, but because it conflated three questions that want different answers:

- *Do these commits pass their tests?*
- *Does this source compile into a binary for every architecture I care about?*
- *Is this particular binary fit to install on this particular machine?*

One job answering all three does each of them badly, and the badness only becomes visible when you ask it to do a fourth thing.

So I split it. What follows is what came out, and — more usefully — the four decisions I reversed while doing it, every one of them because I measured something rather than argued about it. I went in expecting to write a nice tidy fan-out. I came out having deleted about a third of the work the old pipeline was doing, on the grounds that it was doing nothing.

## What one pipeline actually cost

The shipped arrangement was this: everything ran on the Pi 5 build agent. Checkout, tests, release build, deploy. The Pi 5 is a genuinely capable little machine and it is also, for a Rust release build of a dependency tree with three hundred-odd crates in it, slow. Thirty-seven minutes from push to deployed.

Thirty-seven minutes is survivable if it is thirty-seven minutes of work. The first thing the restructure told me is that it was not.

Two structural problems sat underneath that number, and I want to be honest that I only saw the second one after fixing the first.

**Problem one: `main` deployed to the instance people use.** The Pi 4B is the household instance — four accounts, real listening history, the thing someone opens on their phone on the train. Every push to `main` restarted it. That is a canary in the wrong mine. A canary is supposed to be somewhere its death is informative and cheap; mine was somewhere its death meant explaining to actual humans why their listening history was unreachable for four minutes. There was a specific incident behind this worry — a migration that could not run against an existing database, which crash-looped **297 times in 26 minutes** while the entire test suite stayed cheerfully green, because every test starts from an empty file and takes the `init()` path rather than the migration path. Nothing in CI could have caught it, and it happened on the instance with users on it. That incident is the ancestor of about half the decisions in this post.

**Problem two: the architectures were serialised for no reason.** The tests and the amd64 build have nothing to say to each other, and neither has anything to say to the arm64 build beyond *here is the commit*. They ran one after another because they were in one job, and things in one job run one after another. That is not a design; it is the absence of one.

{{< notice note >}}

**Three machines, and which one is which.** Everything in this post is on my own network, so let me name the cast once. **Gimli** is the Dell OptiPlex — x86_64, Fedora, plenty of cores, the Jenkins agent that does the heavy hewing. **Legolas** is the Raspberry Pi 5, aarch64, the only arm64 machine I am willing to compile on. **Gandalf** is the Jenkins controller itself, which builds nothing and sends everyone else on errands.

The deploy targets: **Elrond** is a Zimaboard running Fedora Server, x86_64, and it holds the council before anything ships. **Samwise** is the Pi 4B — the household instance, four accounts, the one that must not break. **Pippin** is a Pi Zero 2 W serving the public demo: small, exposed, and prone to getting into trouble.

Two more turn up later. **Denethor** is the Postgres box, sitting alone with the records. **Bombadil** is the Gitea instance, which has its own domain, its own rules and an extremely strange certificate.

{{< /notice >}}

## The line the split follows

If you are going to split a pipeline, the only interesting question is *along which line*. There are several plausible ones — by stage, by branch, by speed — and most of them produce two jobs that both need the same expensive thing and therefore both do it.

The line that matters here is this:

> **The tests are architecture-independent. The binaries are not.**

If that is true, the expensive half runs exactly once, on the fastest machine, and only the compile is duplicated. If it is false, splitting on that line silently deletes test coverage and you will not find out until something breaks on arm64 that x86 was proving.

So I checked instead of assuming, because "these tests are surely portable" is precisely the kind of statement that is true right up until a floating-point comparison or a raster hash makes it false.

The suite is six hundred and sixty-seven tests, and they are pure functions plus `sqlx`[^2] against a temporary SQLite file. Both targets are 64-bit little-endian. Rust on x86_64 uses SSE2 rather than the x87 stack, so `f64` arithmetic is IEEE-754 on both and there is no excess-precision divergence lurking — that old C trap where an intermediate is silently kept at 80 bits and a comparison flips depending on register pressure. Good.

Then I went looking for the places where the premise is not strictly true, because there always are some.

{{< notice warning >}}

**Three places the premise leaks, and only one of them is a real loss.**

1. **`tiny-skia` rasterises through per-architecture SIMD** — SSE2 on x86, NEON on arm. It is the one dependency in the tree whose *output* could plausibly differ between the two targets. So I read every raster assertion in the report-image module: they are all comparative or threshold-based. Bold's ink against regular's ink; "more than thirty-two distinct pixels were touched". Not one exact pixel value and not one image hash. The premise holds — but it holds by luck as much as by design, and if I ever write an assertion against an exact rendering, this decision needs revisiting.

2. **Concurrency interleaving follows core count.** This one is real. A bug I found some months ago — using `fetch_one` on a statement whose `RETURNING` clause could legitimately produce no row — surfaced as a flake appearing about one run in eight of the full suite under parallel load. A different core count is a different interleaving is a different probability of hitting it. Running the suite only on Gimli genuinely loses this, and there is no cheap way to buy it back.

3. **What is actually lost is compile coverage, not test coverage** — and only if the arm job builds one backend. That one has a fix, and it is below.

{{< /notice >}}

The second point is why the arm job can run the suite on demand. `RUN_TESTS` is a parameter, off by default so an ordinary push stays fast, and forced on when the build is for a tag. An everyday commit gets the fast path; a release gets the tests proven on the hardware that will actually run them.

The third point is why **the arm job builds both database backends even though it never runs a test.** Since I split the database layer to support Postgres as well as SQLite, the feature flag decides *which code even compiles*. A `--features postgres` compile error on aarch64 is invisible to every single stage of the x86 pipeline. It would sit there, perfectly silent, until the day I cut a release — which is the worst imaginable moment to discover that half your build matrix does not compile. Compiling both configurations on Legolas costs a couple of minutes, because of a measurement I will come to shortly, and buys back exactly the coverage the split would otherwise have thrown away.

## The shape

Four jobs, living in a private repository of their own.

![The four Tapedeck pipelines and what each of them touches](/images/tapedeck-ci/pipeline-topology.png "The fan-out. `tapedeck-main` triggers `tapedeck-arm` and does not wait for it; `tapedeck-deploy` builds nothing and installs bytes that already exist.")

| job | agent | trigger | deploys |
|---|---|---|---|
| `tapedeck-main` | `gimli` (x86_64) | push to `main` | **staging only** |
| `tapedeck-arm` | `legolas` (aarch64) | triggered by main | nothing |
| `tapedeck-deploy` | any | manual | the host you pick |
| `tapedeck-staging-refresh` | any | nightly | nothing — data only |

And the hosts they can reach:

| host | arch | role |
|---|---|---|
| **Elrond** (Zimaboard) | x86_64 | staging — a production snapshot in replica mode. Where `main` deploys |
| **Samwise** (Pi 4B) | aarch64 | household — four accounts. Deployed **by hand** |
| **Pippin** (Pi Zero 2 W) | aarch64 | public demo, reset data, 512 MB |

The substantive change is the one word *staging* in the first row. `main` no longer touches Samwise at all. Elrond holds a nightly-refreshed snapshot of production with `TAPEDECK_REPLICA=1` set, which means it forwards no listens anywhere, publishes no federated actor and asks MusicBrainz nothing — it is a machine that looks exactly like production and acts on nothing. That is where a bad commit should land. Samwise and Pippin are reached deliberately, by a human, through `tapedeck-deploy`.

The cost of that, which I should state plainly: **staging is x86, so it never rehearses the arm binary.** Elrond being green tells me nothing about whether the aarch64 build starts. That gets bought back in two places — the arm suite runs at tag time, and the deploy job asks the target host about its glibc rather than assuming. Both of those are below.

Four binaries come out of every commit: `{amd64, arm64} × {sqlite, postgres}`. Only the SQLite ones are deployable today; the Postgres pair exists to prove the configuration compiles on both architectures.

## Reversal one: I was paying twenty-four minutes for a build number

Here is the first thing I got wrong, and it is the one that produced the title.

The original design had `tapedeck-main` trigger `tapedeck-arm` with `wait: true`. There was a reason, and it was not a stupid one. Waiting means Jenkins' `build` step returns a `RunWrapper` object, and a `RunWrapper` has a build number on it, and that build number is how the deploy job could later fetch *exactly* the arm artifact that was built from the same commit. Wait, get a number, record the number, use the number. Clean.

Then the first green run happened, and the timestamps said this:

![Before and after: where the thirty-seven minutes went](/images/tapedeck-ci/before-after-timeline.png "Thirteen minutes of x86 work followed by twenty-four minutes of nothing. The job was idle for two thirds of its own duration.")

Thirteen minutes of x86 work. Then twenty-four minutes of a job sitting there, holding an executor, doing nothing whatsoever, waiting for a Raspberry Pi to finish compiling. Two thirds of a thirty-seven minute job was dead air, and I had designed it that way on purpose, to obtain an integer.

The fix is one line:

```groovy
stage('Build — aarch64') {
  when { expression { params.TRIGGER_ARM } }
  steps {
    script {
      build job: env.ARM_JOB,
            wait: false,                       // ← this
            parameters: [
              string(name: 'COMMIT_ID',        value: env.SRC_SHA),
              booleanParam(name: 'RUN_TESTS',  value: params.ARM_TESTS),
              booleanParam(name: 'SKIP_POSTGRES', value: params.SKIP_POSTGRES),
              booleanParam(name: 'CLEAN_BUILD',   value: params.CLEAN_BUILD),
            ]
      echo "→ ${env.ARM_JOB} triggered for ${env.SRC_SHA.take(8)}; not waiting for it"
    }
  }
}
```

Two details about where that stage sits are worth more than the line itself.

**It fires immediately after the toolchain check**, before the linting and long before the tests. That looks reckless — I am starting an arm64 build for a commit that has not passed anything yet. It is not, for two reasons. Legolas is otherwise idle, so a commit that later fails its tests has cost me some electricity and nothing else. And the deploy job *cannot install* that arm binary anyway, because there will be no matching provenance file from a failed main build for it to pair against. The wasted build is unreachable rather than dangerous.

**It passes a resolved forty-character SHA, never `main`.** This is the single most important line in the entire restructure and it looks like nothing:

```groovy
env.SRC_SHA = sh(script: "cd ${SRC_DIR} && git rev-parse HEAD",
                 returnStdout: true).trim()
```

Two checkouts of a branch name, minutes apart, can be two different commits. If Gimli checks out `main` and hands the arm job the string `"main"`, and I push something in between, then Legolas builds a *different commit* — and both jobs go green, and the deploy job pairs them happily, and I install an arm binary built from source that was never tested with the amd64 binary sitting next to it. Silently. Every indicator green. That is the failure I find genuinely frightening, because nothing in the system would ever tell me it happened.

A consequence follows and it is worth flagging because it costs real time: **neither checkout can be shallow.** Fetching an arbitrary SHA from a shallow clone requires the server to allow `uploadpack.allowReachableSHA1InWant`, and Codeberg may not. So both jobs do a full clone, and I pay for the history on every build rather than debugging an intermittent fetch failure six months from now.

Result: main reports on the work it actually did — nine minutes and twenty-four seconds — and "both architectures are ready" arrives at about seventeen minutes rather than thirty-seven.

What I gave up for that is real, and I will come back to it in reversal three.

## Reversal two: three hundred and thirty-two crates to learn nothing

This is the finding I would publish on its own if it were not embedded in a larger story.

Tapedeck compiles against SQLite by default and Postgres under `--features postgres`. The pipeline built both. Each configuration had its own `CARGO_TARGET_DIR`, on the reasoning that is written in every cargo discussion you will ever read: **flipping a feature invalidates the dependency graph, so sharing a target directory means each build evicts the other's artifacts and you thrash.**

That rule is correct. It is correct in general and I have seen it bite. It is also, for this crate, completely false — and the first green build told me so by recompiling three hundred and thirty-two crates for Postgres having just compiled the same three hundred and thirty-two for SQLite.

The reason it does not apply is specific and checkable. In `Cargo.toml`:

```toml
[features]
postgres = []
```

The feature enables *nothing downstream*. It gates code inside my own crate with `#[cfg(feature = "postgres")]` and does not switch on a single optional dependency, because `sqlx` carries both drivers unconditionally either way — the optional MusicBrainz mirror needs the Postgres driver regardless of which backend the application is using. So the resolved feature set of every dependency in the tree is identical in both configurations. Identical resolved features means identical fingerprints means every artifact is reusable.

Checked, not argued:

```console
$ cargo tree -e features > sqlite.txt
$ cargo tree -e features --features postgres > postgres.txt
$ diff sqlite.txt postgres.txt && wc -l < sqlite.txt
2882
```

Byte-identical. Two thousand eight hundred and eighty-two lines and no diff at all. And then, on a cold directory:

![What one shared target directory actually costs](/images/tapedeck-ci/target-dir-measurement.png "The second configuration costs one crate, not three hundred and thirty-two. Both root-crate variants coexist in the same directory, so flipping back is free.")

Thirty-five point eight seconds and 332 crates for the default features. Twelve point seven seconds in the *same directory* with `--features postgres`, recompiling `tapedeck` alone. Then zero units on the way back to default, because both root-crate variants happily coexist in the fingerprint directory once each has been built once.

Two target directories were paying for 332 crates to learn nothing, twice per build, on two agents — and doubling the disk footprint to do it. The disk halving is the part that amuses me most, because it is the exact opposite of what the original design note predicted.

{{< notice warning >}}

**The consequence that is load-bearing.** One target directory means `target/release/tapedeck` is a *single path* that the second build overwrites. So each binary must be copied out **before the next one is built**. The ordering in the release stage is not stylistic:

```sh
cargo build --release --locked
cp "$CARGO_TARGET_DIR/release/tapedeck" \
   "$WORKSPACE/dist/tapedeck-$SRC_SHA-linux-$ARCH-sqlite"

if [ "$SKIP_POSTGRES" != "true" ]; then
  # Only `tapedeck` itself recompiles here — every dependency is already
  # built and fingerprint-identical.
  cargo build --release --locked --features postgres
  cp "$CARGO_TARGET_DIR/release/tapedeck" \
     "$WORKSPACE/dist/tapedeck-$SRC_SHA-linux-$ARCH-postgres"
fi
```

Build, copy, build, copy. Not build, build, copy, copy — that ships the same binary twice under two names, and nothing anywhere would notice.

{{< /notice >}}

The general lesson, which I think travels beyond this crate: **a rule about cargo's caching behaviour is really a rule about feature propagation.** Whether flipping a feature costs you the world depends entirely on whether that feature reaches your dependencies. `cargo tree -e features`[^3] answers that in one command, and it is worth running before paying a structural cost to work around a problem you may not have. This particular unexamined assumption cost me 332 crates per build on two machines, on every push, for months.

## Reversal three: an exact pair became a verified pair

Detaching the trigger cost me the arm build number. That number was load-bearing, so something had to replace it.

The problem it solved is worth stating carefully, because it took me a while to see that it was a problem at all. *"The last successful amd64 build"* and *"the last successful arm64 build"* **are not a pair.** They are two independent queries against two independent job histories. A push between them produces two builds of two different commits, and a deploy job that pairs them by recency will eventually install a binary whose source was never tested alongside the one it thinks it matches. Both builds are green. Nothing is wrong anywhere you would think to look.

So `tapedeck-main` archives a provenance file. It is called `build-info.env` and it looks like this:

```sh
SRC_SHA=<40-character commit sha>
VERSION=0.109.1
BUILT_AT=2026-09-06T14:22:07Z
AMD64_BUILD=214
GLIBC_AMD64_SQLITE=2.42
GLIBC_AMD64_POSTGRES=2.42
UI_HASH_AMD64=<sha256 of the built static/ tree>
```

`KEY=value` rather than JSON, and that is deliberate rather than lazy. Groovy reads it with a four-line loop and no plugin; a remote shell reads it with `source` and no parser. The moment provenance needs a JSON library on both ends, it becomes something you maintain rather than something you use.

The arm job writes its own — `build-info-arm.env`, carrying its `SRC_SHA`, its own glibc floors, and `UI_HASH_ARM64`.

And the deploy job, instead of *constructing* a pair from a recorded number, **verifies** one:

```groovy
def sel = params.ARM_BUILD?.trim() ? specific(params.ARM_BUILD.trim())
                                   : lastSuccessful()
copyArtifacts projectName: env.ARM_JOB, selector: sel,
              filter: 'dist/**', target: 'from-arm', flatten: true

def info = readBuildInfo('from-arm/build-info-arm.env')

if (info.SRC_SHA != env.SRC_SHA) {
  error """the arm64 build this fetched is ${info.SRC_SHA?.take(8)},
but you are deploying ${env.SRC_SHA.take(8)}.

Nothing was installed. Either that commit was never built for arm64, or a
newer one has been since. Find the matching build under ${env.ARM_JOB} and
re-run with ARM_BUILD set to its number."""
}
```

The construction became a verification, and I want to be precise about what that trade actually is, because "we lost exact pairing" sounds worse than it is.

**What is unchanged:** a binary built from source that was never tested alongside this one still cannot be installed. That failure mode is closed either way. One approach makes it impossible by construction; the other makes it impossible by assertion. Both stop the deploy.

**What is lost:** deploying an *older* main build to an arm host no longer finds its counterpart automatically. If I ask to install build 190 on Samwise, the newest successful arm build is not build 190's counterpart, the SHAs differ, and the job refuses and tells me to pass `ARM_BUILD` by hand. That is a genuine regression in convenience, and it is worth twenty-four minutes on every single push. It is not close.

The clean way to get both properties back is a store keyed by SHA rather than by build number, at which point the deploy job asks for a commit and no build number matters anywhere. There is a MinIO instance on this network that would serve perfectly. That is a later problem.

![Every check tapedeck-deploy makes before it swaps a single byte](/images/tapedeck-ci/deploy-gates.png "Two hard refusals, one warning, and a health check that asserts the thing it actually cares about.")

### The check that fired on its first real use

The middle gate in that diagram is the one I am most pleased with, and it is also the one that immediately told me something I did not want to hear.

Each agent builds its own UI bundle. The alternative was to build the frontend once on Gimli and ship it to Legolas, which buys provably identical UI bytes in both binaries and costs a coupling that makes the arm job unrunnable on its own. I chose standalone runnability, which means I gave up a guarantee.

So I made the property **observable instead of guaranteed**. Both jobs hash their built `static/` tree and record it:

```sh
UI_HASH="$(find static -type f -exec sha256sum {} + \
           | sort -k2 | sha256sum | cut -d" " -f1)"
```

and the deploy job compares them:

```groovy
if (env.UI_AMD64 && info.UI_HASH_ARM64 && env.UI_AMD64 != info.UI_HASH_ARM64) {
  unstable("the amd64 and arm64 builds of ${env.SRC_SHA.take(8)} " +
           "embed different UI bundles")
}
```

Not fatal — the binary being installed is still a tested binary, and a frontend difference is a thing to know rather than a thing to panic about. Just visible.

The second real run of `tapedeck-deploy` went UNSTABLE on exactly this. The amd64 and arm64 builds of the same commit embed different frontends. The install succeeded, the instance came up, and I now know something I would otherwise have discovered from somebody's browser doing something odd on one architecture and not the other.

The likely cause is different `bun` versions between Gimli and Legolas, or `bun build` simply not being byte-reproducible; I have not chased it down and I am not going to before publishing this, because in practice both bundles work. But there is a decision waiting there — pin bun on both agents, or go back to building `static/` once and shipping it — and the pipeline is what surfaced it rather than a user.

If there is one design idea in this whole restructure I would press on someone else, it is that one. **When you trade away a guarantee, replace it with an observation.** A property you have stopped enforcing and stopped watching has not been traded away; it has been forgotten.

## Reversal four, briefly

The old pipeline ran a SonarQube analysis stage. The SonarQube server no longer exists — I decommissioned it some months ago and never touched the pipeline. The stage had been failing softly and being ignored for long enough that I had stopped reading it.

Deleted. There is no cleverness here, but it is worth saying out loud that a third of the reversals in this restructure were "measure it" and one was "notice that you are still paying for something you stopped using". The second kind is more common than the first and much easier to miss, because a stage that fails quietly is indistinguishable from a stage that is fine.

## The four rules the fan-out rests on

Everything above works because of four small things that are easy to get wrong and produce confusing failures when you do.

### 1. Downstream gets a resolved SHA, never a ref name

Covered above, and I am repeating it because it is the one that fails silently. Everything else on this list fails loudly.

### 2. Job names stay relative — except the one that does not

Jenkins' `build job:` and `copyArtifacts projectName:` both resolve **relative to the calling job's own folder**. So when I moved all four jobs from the top level into a `Tapedeck/` folder on Gandalf, `tapedeck-main` carried on finding `tapedeck-arm` with no edit whatsoever. That is a genuinely nice property and it is why those names are deliberately left bare in the Jenkinsfiles.

There is exactly one exception, and it cost me a confusing quarter of an hour. The Copy Artifact plugin's permission property[^4] — `CopyArtifactPermissionProperty`, which is how an upstream job declares who is allowed to copy from it — matches on the copier's **full** name. Inside a folder, that entry has to read `Tapedeck/tapedeck-deploy`, not `tapedeck-deploy`.

{{< notice warning >}}

**And a stale entry there fails as *"no artifacts found"*.** Not "permission denied". Not "you are not on the list". The copy is refused and the job reports that it could not find any artifacts matching the filter — which sends you to look at your `archiveArtifacts` pattern, then at whether the upstream build actually produced anything, then at the workspace, and finally, some time later, at permissions.

{{< /notice >}}

### 3. Provenance is a file, in the dullest possible format

Covered above. `KEY=value`, read by both Groovy and `sh`, no plugin and no parser on either side.

### 4. The glibc floor is checked against the target, not assumed

This is the one that turned from a comment into a check, and the reason is that my fleet stopped being homogeneous.

A binary linked against a newer glibc than the host provides does not degrade gracefully. It does not run slowly or lose a feature. It refuses to start, with this and nothing else:

```
/lib/aarch64-linux-gnu/libc.so.6: version `GLIBC_2.xx' not found
```

The old pipeline's header *reasoned* about this — the build agent's glibc must be no newer than the target's — and then checked nothing, because both boards were aarch64 Debian and the reasoning was enough. Adding an x86 target changed that overnight. **Fedora Server's glibc is far newer than anything Debian ships**, so a binary built on Gimli essentially only runs on recent Fedora. Fine for Elrond. A hard, unhelpful failure for anything else.

So both build jobs record what they produced:

```sh
floor() {
  if command -v objdump >/dev/null; then
    objdump -T "$1" 2>/dev/null | grep -o 'GLIBC_[0-9.]*' \
      | sed 's/GLIBC_//' | sort -uV | tail -1
  elif command -v readelf >/dev/null; then
    readelf -V "$1" 2>/dev/null | grep -o 'GLIBC_[0-9.]*' \
      | sed 's/GLIBC_//' | sort -uV | tail -1
  fi
}
```

and the shared deploy step asks the target for its own before touching anything:

```sh
if [ -n "$D_GLIBC" ]; then
  have=$(ssh $SSHOPTS "$TARGET" 'getconf GNU_LIBC_VERSION' 2>/dev/null \
         | awk '{print $2}')
  if [ -z "$have" ]; then
    echo "⚠ could not read glibc on $D_HOST — proceeding without the check"
  else
    oldest=$(printf '%s\n%s\n' "$D_GLIBC" "$have" | sort -V | head -1)
    if [ "$oldest" != "$D_GLIBC" ]; then
      echo "❌ this binary needs glibc >= $D_GLIBC and $D_HOST has $have."
      echo "   It would not start. Build it on an agent whose glibc is"
      echo "   no newer than the target's, or ship a container build."
      exit 1
    fi
    echo "✓ glibc: needs $D_GLIBC, target has $have"
  fi
fi
```

One SSH round trip. It refuses **before** the swap rather than leaving me to diagnose a service that will not come up, and it degrades to a warning rather than a hard stop if the floor was never recorded — an unmeasurable check should not become a new failure mode of its own.

The version-sort trick is worth a second look, because glibc versions are not numbers and `2.9` is older than `2.36` no matter what a naïve string comparison thinks. `sort -V` handles it; `sort -n` and `[ "$a" -lt "$b" ]` both get it wrong in ways that would silently disable the gate rather than break it.

## Four bugs I wrote before the pipelines ever ran

I want this section in the post because the honest version of "I restructured my CI" includes the part where I read back what I had written and found four things that would not have worked. All of them were caught by re-reading rather than by running, which is the only reason they are amusing rather than expensive.

**1. GString map keys never match String keys in Groovy.** This one is properly nasty:

```groovy
// what I wrote
env.GLIBC_FLOOR = info["GLIBC_AMD64_${params.BACKEND.toUpperCase()}"]
```

That subscript is a `GString`, not a `String`. The map's keys, parsed out of a text file, are `String`s. `GString` and `String` have different `hashCode()` implementations, so the lookup misses, returns `null`, and — because the deploy step treats an empty floor as "not recorded" and warns rather than failing — **the glibc gate would have been silently skipped on every single deploy.** The check I had just carefully written would have been decorative. The fix is `.toString()` on the key and it is invisible in a diff:

```groovy
env.GLIBC_FLOOR = info["GLIBC_AMD64_${params.BACKEND.toUpperCase()}".toString()] ?: ''
```

**2. `.each` with a pipeline step inside is not reliably CPS-transformable.** Jenkins' Groovy runs through a continuation-passing-style transformer so that a pipeline can be paused and resumed across a controller restart. Closures passed to `.each` do not reliably survive that transformation when they contain pipeline steps. The failure is not a syntax error; it is stranger than that. Plain `for (x in things)` loops are fine, and that is what the provenance parser uses.

**3. Bash parameter expansion keeps backslashes literally.** The job-creation script needs to turn a folder path into a Jenkins URL path — `Ops/Tapedeck` into `/job/Ops/job/Tapedeck`. I wrote:

```sh
FOLDER_PATH="${FOLDER//\//\/job\/}"     # wrong
```

In `${var//pattern/replacement}` the replacement is not a place where `\/` means `/`. The backslashes are kept, and a nested folder would have produced `/job/Ops\/job\/Tapedeck`. My single-level folder worked purely by accident, because there was no separator to replace. `sed 's#/#/job/#g'` does the job with no escaping question at all.

**4. `$CLEAN_BUILD` would simply never have worked.** The build steps read parameters as bare shell variables. Jenkins' implicit injection of build parameters into the shell environment is documented as unreliable, and my shared environment preamble does not set `-u`. So an uninjected parameter expands to the empty string, `[ "" = "true" ]` is quietly false, and `CLEAN_BUILD` does nothing — forever, with no error, no warning and no way to tell from the log that the `cargo clean` you asked for never happened.

The fix is to stop relying on the implicit behaviour:

```groovy
environment {
  // Parameters are read as bare shell variables by the build steps below,
  // and Jenkins' implicit injection of them is unreliable. Exporting them
  // here makes it explicit.
  CLEAN_BUILD   = "${params.CLEAN_BUILD}"
  SKIP_POSTGRES = "${params.SKIP_POSTGRES}"
}
```

Three of these four share a shape, and it is the shape I now actively look for: **the failure is silence.** Not a red build, not a stack trace — a thing quietly not happening. A gate that does not gate. A clean that does not clean. Those are worth more attention than anything that produces an error message, because an error message is a system telling you where to look.

## And four the environment had waiting for me

The pipelines were the easy part. Jenkins itself, and the three machines it talks to, had their own opinions.

**`cargo` was not on `PATH` for the agent user.** Obvious in hindsight, invisible in advance: I had been installing toolchains as myself and the agent runs as `jenkins`. Worse, Jenkins repoints `$HOME` at the workspace on an agent, so even a correctly installed `rustup` in the real home is not found. Every build step therefore begins with the same preamble, which resolves the real home out of `/etc/passwd`:

```sh
set -e
H="$(getent passwd "$(id -un)" | cut -d: -f6)"
export PATH="$H/.cargo/bin:$H/.bun/bin:$PATH"
export CARGO_HOME="$H/.cargo"
export RUSTUP_HOME="$H/.rustup"
```

Pointing `CARGO_HOME` at the real home is not cosmetic — it is what lets cargo reuse its existing registry cache rather than re-downloading the index into a workspace that gets wiped.

**The Postgres credential held a literal placeholder from my own documentation.** The live-Postgres stage failed with:

```
password authentication failed for user "user"
```

I spent a genuinely embarrassing amount of time on Denethor before working out what had happened. My operating manual documents the credential as `postgres://<user>:<pass>@10.0.0.20/records_db`, and at some point I had pasted that line into the Jenkins credential *as written*. The angle brackets are conventional enough to be invisible when you are copying quickly, and the resulting connection string is perfectly well-formed — it just describes an account called `user`.

Two things made it worse. Postgres was reporting `active (exited)` in systemd, which looks broken and is not — that is simply how Debian's wrapper unit presents itself, with the real work happening in a per-cluster unit underneath. So I diagnosed a healthy box for a while before reading the error message properly.

{{< details summary="The documentation fix, which is the actual lesson" >}}

A placeholder that reads like a value is a trap in your own notes. `<user>` looks like a slot; `postgres://user:pass@host/db` looks like a working example. I now write placeholders so they cannot possibly be pasted:

```
postgres://REPLACE_ME_USER:REPLACE_ME_PASS@10.0.0.20/records_db
```

and the README says, immediately underneath and in bold, that pasting the line as written produces exactly the error above. The note is there so that future me, who will have forgotten all of this, finds the answer in the same file as the mistake.

{{< /details >}}

**Gitea serves HTTPS on port 3000 with a Cloudflare Origin certificate.** This one is genuinely interesting rather than merely annoying.

My private pipelines repository lives on Bombadil, reachable on the LAN at `https://10.0.0.95:3000`. Three separate things conspire:

- It is **HTTPS on 3000**, not HTTP. A plain HTTP request to that port answers `400`, which is what a TLS server does when handed plaintext, and which reads exactly like a broken URL.
- The certificate is a **Cloudflare Origin certificate**[^5] — issued by an authority that no public trust store carries, because it is designed to be trusted only by Cloudflare's edge rather than by browsers.
- Its SAN list contains `DNS:*.westmarch.example` and **no IP address at all**.

So a bare-IP URL fails verification twice over: untrusted issuer *and* hostname mismatch. Installing the Cloudflare Origin CA root into every trust store on the network fixes the first half and not the second — you cannot make a certificate with no IP in its SAN validate for an IP.

The choice I made was LAN traffic with verification disabled for that one origin:

```sh
sudo git config --system \
  http."https://10.0.0.95:3000/".sslVerify false
```

Two things about that command are load-bearing. It is **scoped to a single origin**, so the Codeberg checkout that every pipeline performs still verifies normally — `GIT_SSL_NO_VERIFY=1` or a bare `http.sslVerify false` would turn the lot off, which is a meaningfully worse trade than it looks. And it is `--system`, writing `/etc/gitconfig`, **because Jenkins repoints `$HOME` at the workspace on agents** and a `--global` setting in the real home is therefore silently ignored there. That is the same mechanism as the `cargo` problem above, showing up in a completely different place — which is a decent argument for understanding it once properly rather than working around it twice.

{{< notice note >}}

If a checkout still fails on the certificate after that, the retrieval is using **JGit** rather than command-line git, and JGit reads none of the above. Either switch the shared library's retrieval method to git, or set `-Dorg.eclipse.jgit.transport.http.sslVerify=false` on the controller.

The tighter alternatives, for completeness: the public URL through the tunnel presents a publicly trusted certificate and needs no exception at all, at the cost of depending on the tunnel for LAN traffic. Or keep verification *and* LAN traffic by using the hostname with a `/etc/hosts` override plus the Origin CA root in each trust store — correct, and three machines to touch every time one changes.

{{< /notice >}}

**A Secret text credential cannot be used for a Git checkout.** A Gitea access token[^6] is a secret string, so "Secret text" is the obviously correct credential kind for it. It is not. Jenkins' Git plugin accepts only `StandardUsernameCredentials` — username-with-password, or an SSH key — so a Secret text credential **is not even offered in the dropdown**, and you are left staring at a credentials list that seems to have lost the thing you just created.

The answer is a Username-with-password credential where the password is the token and the username is the token *owner's* login, which is not necessarily the account in the repository path. Rather than guessing, ask:

```sh
curl -sk -H "Authorization: token <TOKEN>" \
  https://10.0.0.95:3000/api/v1/user | python3 -m json.tool
```

The `login` field it returns is the username to use. One call, no guessing.

Two more, more briefly, both of which are environment rather than pipeline:

- **SELinux is enforcing on Gimli**, so any directory I create for the agent needs `restorecon -Rv`. A fresh directory is `unlabeled_t` and writes to it fail as a permissions error that is not a permissions error, which is a good way to spend an hour looking at `chown`.
- **firewalld blocks 8080 on a fresh Fedora Server.** This one is worth its own paragraph, below, because it is a trap the pipeline itself walks straight into.

### The health check that lies to you

Elrond is Fedora Server, firewalld is on by default, and port 8080 was closed. Meanwhile the deploy step's health check curls `http://127.0.0.1:8080/health` **on the target host** — from inside, over loopback, which firewalld does not touch.

So the app was up. The health check passed. The deploy reported success. And nobody could open the page.

Every deploy would have been green, forever, with a service nobody outside the box could reach. My own bootstrap script warns about this in as many words, having been written by someone who had already thought about it, and I walked into it anyway about two hours later.

```sh
sudo firewall-cmd --add-port=8080/tcp --permanent && sudo firewall-cmd --reload
```

The interesting question is whether the health check should curl the public address instead, and I think the answer is no: loopback is what proves the *binary* is healthy, which is the thing a deploy step is entitled to assert. Reachability is a property of the host's configuration, not of the deployment, and conflating them means a firewall change can fail a deploy of a perfectly good binary. What was missing was not a better check — it was the bootstrap step that opens the port, and a note in the operating manual that says a green deploy is not a reachable page.

## The script I did not touch, and the one I rewrote

Extracting the deploy logic into a shared library[^7] step meant moving about eighty lines of shell from a Jenkinsfile into `vars/tapedeckDeploy.groovy`, where all four pipelines call it as `tapedeckDeploy(...)`. It carries no host, no address and no credential — everything is a parameter — so adding an instance is a row in a caller's table and nothing here changes.

While moving it I was very tempted to tidy it. I did not, and this is the section where I explain why, because the three behaviours in it look like clutter and each is a scar.

```sh
healthy=no
state=unknown
waited=0
while [ "$waited" -lt 90 ]; do
  state=$(systemctl --user is-active "$SERVICE" || true)
  if [ "$state" = active ] \
     && curl -fsS --max-time 5 "$HEALTH_URL" >/dev/null 2>&1; then
    healthy=yes
    break
  fi
  waited=$((waited + 1))
  sleep 1
done

if [ "$healthy" != yes ]; then
  echo "unit is '$state' and $HEALTH_URL did not answer in 90s — last 40 lines:"
  journalctl --user -u "$SERVICE" -n 40 --no-pager || true
  exit 1
fi
```

**It polls rather than sleeping once.** `RestartSec=5` makes a crash loop and a slow start indistinguishable through a single check taken at an arbitrary moment. A unit restarting every five seconds is `active` for most of them. One check will tell you it is fine.

**It dumps the journal when it gives up.** Being handed a state without a reason is worse than being handed an error. The original version of this step reported `activating` and stopped, which is true, useless, and cost me most of an evening during the migration incident.

**It asserts `active` AND answering, because `active` is not `listening`.** systemd marks a `Type=exec` unit active the moment the process is running[^8] — not when it has bound a socket. Tapedeck opens its database, runs migrations and builds its indexes before it binds anything, which is about two and a half seconds against a 133,000-listen history on a laptop and longer off an SD card. A check that waits for `active` and then curls once asks the question before the app can answer it, and fails a restart that worked perfectly.

That last one is the general principle: **the loop's condition should be the thing you actually care about.** Not a proxy for it. "The unit is up and the app answers" is one condition, and no intermediate state — `failed`, `activating`, anything a crash loop cycles through on its way round — is treated as terminal. The time budget is what ends it.

Moving all that into a shared function was fine. Simplifying it would have been a way of paying for the same evening twice.

### The one I did rewrite

`deploy/staging-restore.sh` — the script that pulls a production snapshot onto Elrond nightly — is older, and it had the same bug in a worse place. It polled thirty seconds for `active` and then curled **once**, with a fifteen-second timeout.

Staging is the worst possible case for that. A freshly restored production-sized database means migrations *and* index building before the app binds anything, on storage slower than a laptop's. The nightly job was going to flake, and when it did it would look like a restore failure rather than a timing problem.

Then I found the second bug, which is better:

```sh
health=$(curl -fsS "$STAGING/health")     # under set -e
if [ -z "$health" ]; then
  journalctl --user -u tapedeck -n 40     # ← unreachable
fi
```

Under `set -e`, a failing `curl` in a command substitution **aborts the script at that line**. So the `journalctl` dump — written specifically to explain that exact failure — could never run. The diagnostic was unreachable by construction, and the script's failure output was therefore always the least informative thing it could have printed.

I rewrote it as the deploy step's loop: poll for active *and* answering, 180-second budget for the restore case, in the quoted-heredoc form the deploy step already uses.

{{< notice note >}}

**Why quoted heredocs.** The remote script goes over stdin with a quoted delimiter — `<<'REMOTE'` — so the agent's shell expands nothing in it and every `$` reaches the target verbatim.

An earlier form embedded the same script inside a double-quoted `ssh` argument inside a Groovy string, which needs three levels of escaping to agree. They did not agree. `\\$(id -u)` survived to the far end while `\\$(seq 1 20)` was expanded on the *agent*, so the target received a `for i in 1<newline>2<newline>…` and answered `syntax error near unexpected token '2'`.

Values that must come from Jenkins are passed as **arguments** rather than interpolated:

```sh
ssh $SSHOPTS "$TARGET" bash -s -- \
    "${D_DIR}" "${D_SERVICE}" "${D_HEALTH}" <<'REMOTE'
  set -e
  DEPLOY_DIR="$1"; SERVICE="$2"; HEALTH_URL="$3"
  …
REMOTE
```

which is also what stops a path with a space in it from splitting.

{{< /notice >}}

And before touching any of it, I verified the premise the script rests on: all ten tables its sanitiser deletes from actually exist, and so do the three columns it sets. Under `set -e`, one unknown table name aborts the entire restore — so a schema change I made months ago and forgot about would have quietly broken the nightly job, and the failure would have pointed at the restore rather than at the rename.

## The jobs themselves are code

One more piece, and it is the one that makes the rest reproducible.

All four Jenkinsfiles, the shared library and the operating manual live in a private repository — call it `td-pipelines` — on Bombadil. The application repository is public and has never carried its CI; its `.gitignore` has said so for as long as it has existed. There is now exactly one home for this, which is a better property than it sounds, because the previous state was a root `Jenkinsfile` that existed on my laptop and nowhere else.

Creating the jobs is a script that POSTs an XML template to Gandalf's API:

```sh
JENKINS_URL=https://jenkins.westmarch.example \
JENKINS_USER=frodo \
JENKINS_TOKEN=<api token> \
FOLDER=Tapedeck \
./jenkins/create-jobs.sh
```

Re-running updates them in place rather than refusing, so it is also how a change to the SCM settings reaches all four at once. Build history is untouched. The template deliberately contains **no parameters, no triggers and no build discarder** — a declarative pipeline declares its own, and Jenkins writes them into the job's configuration after the first build.

{{< notice note >}}

Which produces a small surprise worth writing down: **the first run of a new job shows no parameter form at all.** It uses the defaults, silently. That is normal and not a fault — run the job once and the form appears. I have now been confused by this twice, several months apart, which is exactly the kind of thing an operating manual is for.

{{< /notice >}}

The folder check in that script is a small thing I am fond of:

```sh
if [ -n "$FOLDER" ] && ! curl -fsS -o /dev/null "${AUTH[@]}" \
     "${BASE}/api/json" 2>/dev/null; then
  echo "❌ no folder '${FOLDER}' on ${JENKINS_URL} — create it first"
  exit 1
fi
```

Without it, `createItem` against a non-existent folder answers `404`, which reads like a broken URL and sends you to check your `JENKINS_URL` rather than your folder name. Three lines to turn a misleading error into an accurate one is almost always worth it.

## What it costs now

| | before | after |
|---|---|---|
| `tapedeck-main` (x86) | 37 min | **9 min 24 s** |
| `tapedeck-arm` | 24 min, serialised after main | **16 min 32 s, concurrent** |
| both architectures ready | ~37 min | **~17 min** |
| `tapedeck-staging-refresh` | did not exist | 16 s |
| `tapedeck-deploy` | did not exist | 13 s |
| binaries per commit | 1 | **4**, with a provenance file |
| what `main` deploys to | the instance four people use | a replica that forwards nothing |

The number I care about is not the seventeen minutes. It is the thirteen seconds.

`tapedeck-deploy` takes thirteen seconds because it builds nothing — it copies two archived files, verifies a SHA, checks a glibc floor, copies a binary over SSH, restarts a user service and polls a health endpoint. That is what makes the household instance something I update deliberately, when I have a reason, rather than something that gets restarted every time I fix a typo. Separating "is this code good" from "should this machine run it" did not just make the pipeline faster. It made a decision that used to be implicit into one I have to actually make.

## What this is groundwork for

None of the above was the point. The point is the release pipeline, and everything here exists so that it can be built correctly rather than quickly.

When a tag lands, I want four downloadable binaries with checksums, two container images, and a multi-architecture manifest joining them. The fan-out above is *already that shape* — it is this same structure with a tag guard in front and an upload behind. But there is one thing it must not do, and it took building all of the above to state it properly:

> **The released binaries must not be these binaries.**

The binaries these pipelines produce are linked against whatever glibc the build agent happened to have. Gimli's is far newer than anything Debian ships. That is fine for Elrond, whose glibc I know, and it is checked at deploy time for Samwise and Pippin, whose glibc I also know. It is entirely unfit for a stranger's Raspberry Pi running whatever Debian they installed in 2023, where it produces a missing-symbol-version error, no workaround, and a support burden arriving one bug report at a time.

So published binaries come out of a container with a deliberately low glibc floor — build in a `bookworm`-based image rather than a `trixie` one — and the neat consequence is that **one container build produces both the image and the release binary**, which means the published binary and the published image contain identical bytes, and the floor becomes a property of a Dockerfile under version control rather than of whichever machine happened to run the job.

The glibc gate I built this weekend is what turns that from a worry into a number. It was the vaguest item on the list when I started and it is now the most concrete, purely because something in the pipeline records a version and something else compares it.

There is also a musl build worth measuring eventually — fully static, no floor at all, and this dependency tree is unusually well suited to it: zero OpenSSL, `libsqlite3-sys` bundles its C, and the SVG and font stack is pure Rust. The known cost is musl's slower allocator under allocation-heavy work, which wants measuring on the Pi rather than assuming. That is an upgrade with a measurement attached, not a starting point.

## Still open

In the spirit of not pretending a weekend produced a finished system:

- **`tapedeck-deploy` went UNSTABLE on the UI hash**, and the amd64 and arm64 builds of one commit really do embed different frontends. Pin `bun` on both agents, or build `static/` once and ship it — a decision, not a task.
- **Linting is not yet a gate.** `cargo fmt --check` is a hard failure and clippy is report-only, and clippy stays report-only until I decide what to do about the deliberately-unused trait methods that `-D warnings` would fail on. Deleting a method a trait requires, or carrying an `allow` nobody wants, are both worse than a report.
- **The old single pipeline still exists** in the folder and still deploys straight to Samwise, bypassing staging entirely. It needs disabling, and the reason it has not been is that deleting the thing that currently works is always the last step.
- **No webhook, no tag trigger.** I kept parameterised jobs over a multibranch pipeline because the self-checkout structure is explicit and re-running with a different SHA is one form field. The cost is that a tag trigger needs the Generic Webhook Trigger plugin[^9] rather than coming for free.
- **Provenance keyed by SHA rather than by build number.** The MinIO instance on this network would serve as the store, and it restores exact pairing without restoring the wait.
- **The release pipeline itself.** Tag guard, Dockerfile, multi-arch manifest, Codeberg release assets with checksums. Signing is a decision I have not made; checksums are the honest minimum and can ship first.

## What I actually learnt

I set out to add a pipeline and ended up deleting work.

Every one of the four reversals came from a measurement rather than an argument, and in three of the four the argument I had been making was not merely wrong but *confidently* wrong — I had reasons, and the reasons were sound in general, and the general case was not my case. `wait: true` was correct reasoning about what `build` returns. Separate target directories were correct reasoning about cargo's fingerprinting. Both were paying real time to solve problems this project does not have.

The thing that broke both of them was the same thing: a number. Thirteen minutes of work followed by twenty-four minutes of nothing. Three hundred and thirty-two crates compiled twice to produce identical artifacts. Neither is subtle. Both had been happening on every push for months, and I had never once looked, because the build was green and green is the colour you stop reading.

There is a version of this post that says "measure your build pipeline", and it would be true and useless. The more specific version is this: **the general rule and your case are different objects, and the cost of confusing them is invisible.** A rule about cargo's caching is really a rule about feature propagation, and `cargo tree -e features` will tell you in one command whether it applies to you. A rule about needing a build number is really a rule about how you establish provenance, and there is more than one way to do that. The received wisdom is usually right about the world and frequently wrong about the machine in front of you, and the only way to know which is to go and look.

The other half of it, which I think is the more transferable idea: when you trade away a guarantee — and a fan-out is nothing but a sequence of such trades — **replace it with an observation.** I gave up identical UI bytes and recorded a hash instead. I gave up exact artifact pairing and recorded a SHA to compare instead. One of those fired on its first real use and told me something true that I did not know. A property you have stopped enforcing and stopped watching has not been traded away. It has been forgotten, and it will come back as a bug report from somebody else.

Next: the Dockerfile, and finding out what a `bookworm` glibc floor actually costs.

---

[^1]: [codeberg.org/abksh/tapedeck](https://codeberg.org/abksh/tapedeck) — AGPL-3.0, Rust, and considerably more opinionated about listening history than it needs to be.

[^2]: [sqlx](https://github.com/launchbadge/sqlx) — the async SQL toolkit the database layer is built on, which carries both the SQLite and Postgres drivers regardless of which one you use.

[^3]: [The Cargo Book: Features](https://doc.rust-lang.org/cargo/reference/features.html) — and `cargo tree -e features`, which is the command that settled the target-directory question in about four seconds.

[^4]: [Copy Artifact plugin](https://plugins.jenkins.io/copyartifact/) — including the permission property whose failure mode is a missing artifact.

[^5]: [Cloudflare Origin CA certificates](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/) — trusted by Cloudflare's edge and by nothing else, which is the entire design.

[^6]: [Gitea documentation](https://docs.gitea.com/) — access tokens are under Settings → Applications, and a read-only repository scope is genuinely enough.

[^7]: [Jenkins shared libraries](https://www.jenkins.io/doc/book/pipeline/shared-libraries/) — how `vars/tapedeckDeploy.groovy` becomes a step that four pipelines can call.

[^8]: [systemd.service(5)](https://www.freedesktop.org/software/systemd/man/systemd.service.html) — in particular what `Type=exec` promises about when a unit becomes active, which is less than you would like.

[^9]: [Generic Webhook Trigger plugin](https://plugins.jenkins.io/generic-webhook-trigger/) — the price of keeping parameterised jobs instead of a multibranch pipeline.
