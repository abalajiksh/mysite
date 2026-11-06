+++
date = '2026-11-06T15:50:00+01:00'
draft = false
title = "It Started Minimal: A Field Guide to My Growing Jenkins Estate"
useAlpine = false
loadNerdFont = false
tags = [
    "jenkins",
    "ci-cd",
    "pipeline-design",
    "self-hosting",
    "homelab",
    "crete",
    "tapedeck",
    "starling",
    "libdsddpcm",
    "rust",
    "cpp",
    "webassembly",
    "cross-architecture",
    "security",
    "pull-requests",
    "opensuse-build-service",
    "homebrew",
    "fedora",
    "rpm",
    "flatpak",
    "open-source"
]
+++

*A tour of the Jenkins pipelines running on one little homelab controller — what each one builds, where it runs, and the handful of ideas that keep repeating as the estate grows.*

I have written about individual pipelines here before. [Twenty-Four Idle Minutes](/posts/twenty-four-idle-minutes/) was the story of splitting one Tapedeck job into four after I actually measured it; [the audiocheckr deep dive](/posts/audiocheckr-deep-dive/) touched on its test harness. What I have never done is step back and look at the *whole* thing — the single Jenkins controller in my homelab that now drives several separate projects, close to thirty jobs across eight folders, and seven build agents spanning **three** CPU architectures — x86-64, ARM, and now RISC-V — plus an operating system I do not even own a machine for.

The important thing to say up front is that **none of this started big.** It started as one pipeline that built one project, because I needed exactly that and nothing more. Everything here accreted: a second project wanted packaging, a release wanted qualification, a public repository wanted a way to test strangers' code safely, a Raspberry Pi wanted its own binary. Each addition was small and local. The complexity you are about to see is not a design — it is a sediment. That is the real subject of this post: not any single job, but what a CI setup turns into when you keep a minimal one running long enough that projects pile up on it.

{{< notice note >}}
Everything here runs on hardware I own and pay the electricity for: a Jenkins controller in an LXC, a handful of mini-PCs and Raspberry Pis, and a small k3s cluster. No cloud CI minutes, no third-party runners. The whole point of the exercise is that the pipelines are *code I keep*, versioned in a repository, not clicks in a web UI I will have forgotten in a month.
{{< /notice >}}

## The shape of the estate

One controller, eight folders. The controller itself never runs a build step — every job declares a `label` and Jenkins routes it to a matching agent.

One small confession before the diagram: **every machine and every label in this fleet is named after a character or a place from Robin Hobb's *Realm of the Elderlings*.** It is a deliberate, slightly self-indulgent convention, and a genuinely useful one — a new box is not `jenkins-agent-04`, it is a name I will actually remember. The hosts are the Six Duchies and beyond — `fallstar`, `prophetfool`, `verity`, `kelsingra` (a place — the Elderling city), `kettriken` — and the Jenkins labels are drawn from the same well: `chade`, `bee`, `sacrifice`. A label and its host are usually two different names for the same machine, which is why the tables below carry both. If you have read the books it is a little map of the Realm; if you have not, it is just a set of names that happen never to collide.

![A map of the whole Jenkins estate: one controller, product folders with their jobs colour-coded by agent, a band of utility folders, and the agent legend](/images/jenkins-estate/estate-map.svg "The controller is a router. Coloured chips are jobs; the colour is the agent each one lands on. Below the headline projects sits a band of folders that just package third-party software and self-hosted apps — the estate is bigger than its interesting parts.")

The headline folders — the ones with real pipeline design in them — are:

- **Crete** — my C++17 dynamic-range meter. The most elaborate release machinery here, because it ships to the openSUSE Build Service, a Homebrew tap, a Scoop bucket, a WebAssembly site, *and* native Windows binaries.
- **Tapedeck** — my self-hosted music journal, written in Rust. Driven by a shared Jenkins library (`td-pipelines`) so the deploy logic exists exactly once.
- **Starling** — the Android client for Tapedeck. One job today, and a clean example of a pipeline that stays small because its job is small.
- **libdsddpcm** — the BSD-2 DSD→PCM decoder library that crête consumes, with its own build and listening-test jobs.

And then there is everything that is *not* a headline project — a whole band of the estate whose jobs just build software I want on my own machines. More on those at the end, because they are the clearest evidence of the "it keeps growing" claim.

The agents, and what makes each one special:

| label | host | arch | why it exists |
|---|---|---|---|
| `bee` | prophetfool | x86_64 | has `osc` logged in for the openSUSE Build Service — the release agent |
| `chade` | fallstar | x86_64 | the beefy Ryzen; crête's weekly, and the Android builds |
| `optiplex` | verity | x86_64 | Tapedeck's tests and amd64 builds |
| `pi5` | — | aarch64 | real ARM hardware; proves ARM binaries actually start |
| `sacrifice` | kettriken | riscv64 | an Orange Pi RV2; the third architecture crête's cross-arch check runs on |
| `windows` | kelsingra | x86_64 | the only Windows machine; native MinGW builds |
| k3s pod | fallstar | — | throwaway, network-isolated pods for cross-builds and untrusted code |

Label and host are two Realm names for one machine — `sacrifice` is the board called *kettriken*, the same way `chade` is *fallstar*. For most of what runs here there are two target architectures, x86-64 and ARM, and the thing I keep relearning is that **cross-compilation plus one real machine beats native-everywhere**: the Pi used to do full Rust release builds and it was painfully slow; now a k3s pod on the Ryzen cross-compiles for aarch64 in a fraction of the time and the Pi only has to start the binary. crête adds a third architecture, RISC-V, for a different reason entirely — not to ship it, but to *prove the decoded bits match across all three*. That one gets its own section below.

## Crête: a release is a guarded tag push

Crête has eight jobs, but they orbit one idea: **a published tag is a promise you cannot take back, so everything is checked *before* the tag exists.** You never tag and then validate. You validate, and the tag is the last step.

![The crête release flow: Crete-Tag qualifies a candidate by running the full weekly suite on its exact SHA, refuses on a failed gate, then pushes the tag; the Codeberg webhook then wakes three jobs](/images/jenkins-estate/crete-release.svg "Crete-Tag is a gate with a tag push on the far side of it. Once the tag lands, the webhook fans out — and every downstream job is idempotent, which is what makes the daily cron backstops safe.")

The jobs:

- **Crete-Weekly** runs the entire test corpus — every album, every DSD rate, cross-architecture identity checks on two agents — through a SonarQube pass. On its Monday schedule it is a health check. Called by Crete-Tag, it becomes a *qualifier*.
- **Crete-Tag** is the only way a crête tag is made. It resolves the candidate SHA, checks the `Makefile`'s `VERSION` against it, runs Crete-Weekly on that exact SHA, and then hands the measurements to a Python script that **refuses to compose a tag message** if the gate failed or if the release claims "no change" while the numbers moved. `DRY_RUN` is on by default: the usual flow is a dry run, read the release notes it *would* write, then a real run that tags exactly what you read.
- **Crete-Release** fires on the tag webhook. It assembles a deterministic source tarball, smoke-builds it, commits it to the openSUSE Build Service, and waits until all fifteen distribution repositories have published before bumping the Homebrew tap. In parallel it triggers **Crete-Windows** (native MinGW build on the one Windows box), attaches that zip to the Codeberg release, and points the Scoop bucket at it.
- **Crete-Wasm** rebuilds [check.crete-dr.com](https://check.crete-dr.com) for the tag: crête and a compact FFmpeg compiled to WebAssembly, proven to measure bit-for-bit what the native binary does, driven through a headless-Chromium end-to-end test, then deployed to Cloudflare.
- **Crete-Site** adds the release to the website changelog and pushes — the push is what makes Cloudflare rebuild.
- **Crete-Compare** and **Crete-Manual** are the workbench: compare any weekly run against a committed golden run, or pick individual test suites by hand.

{{< notice tip >}}
**The quiet hero here is determinism.** The source tarball crête uploads is byte-reproducible from a tag. That single property is what lets every release job be safely re-run: a job fired for a tag that is already out finds the artifact identical, skips the commit, and passes its wait immediately. Idempotence is not a nice-to-have bolted on afterwards — it is the thing that makes a daily cron backstop *cheap enough to leave running*, because 364 days out of 365 it does nothing and says so.
{{< /notice >}}

Feeding all of this, in a separate repository, is **crete-pytest** — the test harness. Its `Jenkinsfile` runs on a push; its `Jenkinsfile.weeklyRuns` is what Crete-Weekly actually executes. The two share one audio corpus cache *outside* the workspace, on the same agent, guarded by a mkdir lock because the jobs can overlap. The harness is architecture-neutral by contract: a single tunable block at the top is the only place that names an agent, so moving the whole suite from x86 to the Pi 5 is a three-line change.

## Tapedeck: four questions want four jobs

Tapedeck is where I learned that one pipeline doing everything does each thing badly. A CI job is really answering up to four different questions, and they want different machines and different trust levels:

1. *Do these commits pass their tests?*
2. *Does the source compile for every architecture I ship?*
3. *Is this specific binary fit to install on this specific host?*
4. *Is this pull request — someone else's code — safe to even build?*

![The Tapedeck flow: main tests and builds amd64 and deploys to staging; arm cross-builds in k3s and smoke-starts on the Pi 5; deploy installs a provenance-paired binary; the PR guard runs untrusted code in an isolated pod; plus the nightly staging refresh and the security jobs](/images/jenkins-estate/tapedeck-flow.svg "Each job answers one question. The dashed line is the provenance chain: deploy installs the exact bytes a build tested, paired by a file, never 'the latest green build of each'.")

- **tapedeck-main** (on `optiplex`) answers questions 1 and part of 2: lint, test both database backends — SQLite *and* Postgres, because a feature flag decides which code even compiles — build amd64, and deploy to a staging replica that forwards nothing and acts on nothing. The tests run *once*, here, because both targets are 64-bit little-endian with IEEE-754 floats; running them twice buys almost nothing.
- **tapedeck-arm** cross-compiles aarch64 in a k3s pod and then smoke-starts the binary on the real Pi 5. The glibc floor is *pinned* to 2.35, not inherited from the build pod, so nothing that ran on the old native Pi builds can suddenly stop. For a release tag it also runs the full suite on the Pi — because a different core count is a different concurrency interleaving, and that is the one thing a cross-build genuinely cannot prove.
- **tapedeck-deploy** builds *nothing*. That is the entire point: it installs the exact bytes that were tested, so "it worked on staging" stays evidence. The pairing of "this amd64 build" with "that arm64 build" is explicit — carried in a `build-info.env` provenance file — because pairing by recency will eventually install two halves that were never tested together.

### Why the arm build runs on x86 instead of on the Pi

For months, `tapedeck-arm` did the obvious thing: build aarch64 *on* aarch64, natively on the Pi 5. The Pi 5 is a genuinely capable little machine and it is also, for a cold Rust release build of Tapedeck's dependency graph, **slow — north of twenty minutes** a build. Every push paid that, twice over once there were two database backends to compile. So now the compile happens in a k3s pod on the Ryzen, cross-compiled for aarch64 with `zig` through `cargo-zigbuild`, and the Pi only ever has to do the one thing a cross-build cannot fake: *start* the binary, on real ARM hardware, and for a release tag run the suite under its actual core count.

That move — taking the build off the slow machine and keeping the slow machine only for the thing it uniquely proves — is a small instance of a much larger shift that Avi Press (Scarf's founder) wrote up in July 2026, when Scarf [reluctantly moved away from Haskell](https://avi.press/posts/2026-07-10-after-7-years-in-production-scarf-has-reluctantly-moved-away-from-haskell.html) after seven years in production. Their reason was not a bug or a missing feature; it was compile time. His framing is that once an agent can draft a plausible change in minutes, a long cold build stops being a papercut and becomes *"the dominant cost of that thread of work."* The deeper point is about *disposable, parallel execution contexts*: he wants to fork off five worktrees, let five agents try five things, and throw away four — and in that world the cold-start build cost is the whole tax, paid five times.

My Tapedeck build is Rust, not Haskell, and twenty minutes on a Pi is nowhere near Scarf's scale. But the economics are identical: the moment the build is the bottleneck, you stop running it on whatever is nearest the deploy target and start running it on the fastest, cheapest, most disposable context you have — a throwaway k3s pod on the Ryzen that exists for one build and vanishes. The Pi did not get faster; it just stopped being on the critical path. If my homelab ever grows agents forking worktrees of their own, that pod is already the shape of the answer.

The rest are scheduled or tag-triggered support jobs: **tapedeck-staging-refresh** restores a sanitised production snapshot to staging nightly (so every migration is re-run against a production-shaped database — the one thing an always-empty test database can never check); **tapedeck-spec-sync** copies the released OpenAPI spec into the website repo on a tag; **tapedeck-obs-release** publishes Linux packages, modelled on crête's release job minus the Homebrew tap.

## tapedeck-pr: how a public project tests a stranger's code

This is the job I am asked about most, so it gets its own section. Tapedeck is public. A pull request's `build.rs`, its tests, its dependencies — all of it is **arbitrary code**, and `tapedeck-main` runs that kind of code on an agent inside my LAN, next to every deploy key I own. Running a stranger's branch there is not an option. But refusing to test contributions is also not an option. So the PR guard is built entirely around one question: *where does each step run, and what can it reach from there?*

The job declares `agent none` and then picks an agent per stage, because the stages do not all deserve the same trust:

**Resolve — on the trusted agent.** It never builds anything. It pulls the PR's facts from the Codeberg API and decides, before a single line of the PR's code executes, whether this PR may be built at all:

- the PR must be *open*;
- a fork's PR is built **only** once a maintainer has added an `ok-to-test` label — otherwise a drive-by PR could run code the moment it is opened;
- a head commit that already has a result is skipped unless you force it, so the same push is not re-tested forever.

If it passes those gates, the trusted agent clones the PR head *here*, on the trusted side, and does everything that must not depend on the pod: static analysis of the migrations, commit-hygiene checks, and working out what "the last release" means — the highest `v*` tag reachable from the base branch. It posts `pending` commit statuses (`tapedeck-pr/tests` and `tapedeck-pr/migrations`) using the one Codeberg token that can write, and it fetches the database seed from MinIO **here**, so the storage key never enters the pod. A fork never gets the real listening-history seed — only synthetic data — because a fork's code with real data *and* internet access is exactly the combination you do not create.

**Test — in a throwaway k3s pod.** This is the only place the PR's own code runs, and the pod is built to contain it:

- `automountServiceAccountToken: false` — no Kubernetes API token is mounted, so the PR's code cannot talk to the cluster;
- a `tapedeck-pr` NetworkPolicy lets the pod reach the public internet (it has to fetch crates) and **nothing on the LAN** — not the Postgres box, not the deploy targets, not the controller;
- its Postgres is a **sidecar** that listens on the pod's loopback only, with `trust` auth and durability switched off, and dies when the pod does — the "throwaway live database" the tests need, with no shared server and no credential;
- its build cache is this job's *own* volume, never a cache anything trusted builds from, because the PR writes to it.

Inside that box it runs the real work: `fmt`, both test suites, the live-Postgres checks, the Svelte UI build and `svelte-check`, `clippy`, and a migration check against both backends. Crucially, each check is wrapped so that a failure turns its stage red but **never fails the build outright** — the build's verdict is decided afterwards, on the trusted side, from the results the pod wrote.

**Report — back on the trusted agent.** It reads those results and produces one sticky PR comment, two commit statuses, and — if a required check failed — closes the PR. The migration check is the subtle part: it builds both the last release *and* the base branch's tip, so a finding that already exists on `main` is reported as main's problem and never fails somebody's PR for a thing they did not cause.

{{< notice warning >}}
**Trust is a property of the agent, not the job.** The single most important line in this whole design is *where a step runs*. Anything that touches a secret — the Codeberg token, the MinIO key, the production seed — runs on a trusted agent inside the LAN. Anything that runs code I did not write runs in a pod that can reach the internet and nothing else. The pod's own results are believed only as far as the PR's code could not fake them anyway: it can always delete a test, which is what review is still for. Collapse those two trust levels into one agent "for simplicity" and the convenience you gain is exactly the blast radius you have just handed to a malicious pull request.
{{< /notice >}}

**tapedeck-pr-scan** is the small sibling that makes this usable: every ten minutes, and on the PR webhook, it starts `tapedeck-pr` for each open PR head that has no result yet. The webhook is the fast path; the timer is the backstop for a webhook that got lost.

## The security jobs, and the shared library

Two things deliberately do *not* live inside a single product.

**The shared library (`td-pipelines`).** The deploy step, the SonarQube analysis, and the Strix security scan each exist exactly once as a library step, called by whatever job needs them. A new deploy target is a row in a caller's table, not a copied block of Groovy. This is the difference between several pipelines and several *copies* of one pipeline — and the reason a fix to the deploy logic lands everywhere at once (or, when I want caution, only where a job pins an older library version).

**Strix scans → td-security.** On a minor release tag, `tapedeck-strix` runs [Strix](https://github.com/usestrix/strix) — an LLM-driven penetration tester — against the Tapedeck source and a throwaway live instance, inside a network-isolated k3s pod with a hard monthly budget cap. Findings are filed as issues in a private `td-security` repository. A companion job, **td-security-sync**, reads `Security-Fix: td-security#N` trailers on the main branch, comments when a fix lands, and closes the issue once a release tag contains it — no model, fully idempotent, triggered by every `tapedeck-main` build rather than on a timer that mostly found nothing.

That `td-security` repository is the one with no Jenkinsfile of its own, and that is correct: it is the *destination* for findings, not a thing that gets built.

## Starling and libdsddpcm: small projects, small pipelines

Not every project needs a fan-out. **Starling**, the Android client, has exactly one job: on a version tag it tests and builds the app on `chade`, verifies the signing certificate, and archives the APK. That is the whole pipeline, and it should be — the job is small, so the pipeline is small. The lesson I keep having to re-teach myself is that elaboration is a cost you pay only when a project earns it.

**libdsddpcm** — the BSD-2 DSD→PCM decoder library that crête links against — sits in its own folder with a build-and-test job and a separate listening-check job. It is a dependency with a conscience: it gets its own CI precisely because crête trusts its output, and "the library my meter believes" is worth proving independently of the meter.

## The third architecture: a RISC-V board that proves the bits match

Both crête and libdsddpcm run on a **RISC-V** machine — an Orange Pi RV2 running Fedora 44, which joined the controller as an SSH agent in October 2026. Its hostname is *kettriken*; Jenkins knows it by the label `sacrifice`. And it is there for a reason that has nothing to do with wanting RISC-V binaries and everything to do with *trust in a number*.

crête is a measurement tool. Its whole claim is that it decodes an audio file and reports a dynamic-range figure you can rely on. The quiet nightmare for a tool like that is a decoder that is subtly wrong on *one* architecture — an off-by-an-ULP float result, a fused multiply-add the compiler slipped in on one target and not another — so that the same lossless file reads one number on your laptop and a different one on the Pi. So crête's weekly carries a **cross-architecture identity check**: it decodes the same lossless carriers on every architecture at once and asserts the shipped build's output is *bit-identical* across all of them. The agents it runs on are a list in one place:

```groovy
CROSSARCH_LABELS = ['bee', 'pi5', 'sacrifice']   // x86_64, aarch64, riscv64
```

Two architectures agreeing is reassuring. **Three — and three that could not be more different: a desktop x86-64, an ARM Pi, and a RISC-V board — is evidence.** When all three decode a FLAC to the exact same samples, the thing being tested is no longer "does it work on my machine" but "is the integer decode path genuinely architecture-independent," which is the property crête actually needs to be true. The check builds two variants on each side: the shipped one with `-ffp-contract=off` (compared for strict bit-identity) and a `-ffp-contract=fast` one (reported only) — because the fused-multiply-add question is exactly the kind of thing that bites differently on RISC-V's and ARM's FPUs, and pinning contraction off is what makes "identical" mean identical. libdsddpcm rides the same logic: its coefficient design is meant to be libm-free and reproducible, and a RISC-V board is a stern, cheap place to prove that claim rather than assert it.

{{< notice tip >}}
**A third architecture is cheaper than it sounds, because it runs in the gaps.** The cross-arch check runs *in parallel* with the main suite, which takes far longer, so a slow RISC-V side — and the RV2 is slow — costs no extra wall-clock time until it becomes the long pole, which it is nowhere near. If the board is offline the stage simply times out and marks the build UNSTABLE rather than failing it. The one real cost was setup friction that is pure RISC-V-is-still-young: MinIO ships no `riscv64` build of its `mc` client, so the agent builds `mc` from source; and there is **no `riscv64` build of Bun at all**, which is the clean reason this board serves the C and C++ projects (crête, libdsddpcm) and never the ones whose toolchain is Bun (Tapedeck, the Wasm UI). The architecture you can add to a job is, once again, a property of what the ecosystem ships — the same lesson the Fedora packages teach one folder over.
{{< /notice >}}

## FedoraBuilds: native packages, because Flatpak is a tax I can opt out of

The **FedoraBuilds** folder — `Signal`, `ffmpeg`, `melonDS`, `mgba`, `Notepadqq` — exists for a reason I feel strongly enough about to give it its own section: I would rather run a **native build** of a program than a Flatpak of it, and for open-source software I can simply make that true.

Flatpak solves a real problem — "ship one binary that runs on every distro" — but it solves it by paying for isolation in bulk. Each app brings a runtime, and often its own copies of libraries the system already has, so you end up with several slightly different builds of the same dependency resident at once. You pay in disk, in memory, in a sandbox that has to be poked full of portal holes before the app can see your files or your theme, and in a startup path that goes through all of that before it reaches the program. For a one-off tool that is fine. For the handful of things I actually live in, it is a bloated answer to a question I do not have — my machines are *my* distro, not "every distro," so the one problem Flatpak is bundling for is a problem I do not have.

So Jenkins builds them the native way instead. Each job takes the project's **source** and produces something that belongs to the system: an RPM where it makes sense, or a from-source build installed cleanly into the right prefix where it does not. The binary links the system's own libraries, starts without a sandbox in the way, and integrates with the desktop like anything else Fedora ships. `ffmpeg` is the sharpest example, and it is not the one people expect: the point is not "Fedora's ffmpeg is crippled, swap in RPM Fusion's." Even RPM Fusion's package — the usual answer — is built with *somebody else's* `./configure` flags, and it still does not ship every decoder the ffmpeg tree can build. I build it myself specifically to **turn on the decoders I want to test against** — the odd, the obscure, the ones no distro bothers to enable — by choosing the configure flags myself. No packaged build, Fedora's or RPM Fusion's, hands you that; a from-source build with flags you control is the only way to get the exact decoder set you need. (This feeds straight into the audio work: a meter is only as trustworthy as the reference decoder you check it against.) The agent does the compile once when there is a new release and drops a red square in Jenkins if it ever stops building.

**And here is the load-bearing word: *source*.** Every one of those native builds is possible only because the program is open source. I have the code, so I can compile it, package it, strip what I do not want, and own the result. The moment that is not true, the whole option disappears.

The example that made this concrete for me is **Plexamp**. I would love a native Fedora package of it — it is the player I reach for — but Plexamp is **closed source**. There is no source tree to feed an `rpmbuild`, no way to relink it against my system's libraries, no way to produce anything but what Plex themselves hand out. So Plexamp is the one audio app on my machines that I run as a Flatpak (well, an AppImage), bundled runtime and all, *not because I chose that packaging but because its licence chose it for me.* It is the exception that proves the rule sitting one folder over: the native-package freedom my FedoraBuilds jobs exercise is not a property of my toolchain or my cleverness — it is a property of the software's licence. Open source is what hands you the choice; closed source quietly takes it back.

That, more than anything else in this folder, is why these "boring" jobs are on the controller at all. They are not interesting as pipelines. They are interesting as a standing vote: when the licence lets me, I build it myself.

## …and the rest: the estate is bigger than its interesting parts

Here is the honest picture, and the best evidence for the "it keeps growing" framing. Beyond the headline projects and the Fedora packages, the controller carries a few more jobs that just keep my own machines fed:

- **arm_builds** — `vaultwarden`, `bytestash`: self-hosted services compiled for the aarch64 machines that run them (and, where upstream only ships x86 or a container, built natively for ARM for the same reason the Fedora packages exist).
- **k3s** — `cognee-ingest`, `hello`: a scheduled ingest job and the obligatory smoke job that proves the cluster's Jenkins cloud still works.

Neither of these has a Jenkinsfile worth a section of its own. They are short shell scripts that happen to live in Jenkins because Jenkins is already there, already has the agents, and already sends me a red square when something breaks. **That is how a minimal setup grows** — not through grand design, but because the marginal cost of one more job, on infrastructure you already run, is nearly zero. And the sum of all those nearly-zero costs is an estate with close to thirty jobs in it, which is a sentence I could not have predicted writing when the whole thing was one pipeline building one meter.

## The patterns that repeat

Enough jobs, across enough projects, and the same handful of ideas keep surfacing. If there is anything worth carrying away from a tour like this, it is these:

1. **The controller is a router; agents do the work.** Every job declares a label and nothing builds on the controller. This keeps the controller cheap, stable, and rarely restarted.
2. **Validate before you publish; the publish step is irreversible.** Crête's tag is cut *after* qualification. A tag you cannot move is checked before it exists.
3. **Idempotence makes cron backstops free.** Deterministic artifacts mean every release job can re-run safely, which means a daily "did anything slip through?" cron costs nothing when nothing changed.
4. **Trust follows the agent, not the job.** Secrets live on trusted agents inside the LAN; untrusted code lives in a pod that can reach the internet and nothing else.
5. **Provenance is an explicit file, not an inference.** "The latest green build of each" is a trap; a dull little `build-info.env` that pairs exact SHAs and build numbers is the fix.
6. **Cross-compile widely, verify on one real machine.** You do not need native hardware for every architecture — you need it once, to prove the binary starts.
7. **Write the shared step once.** A Jenkins global library turns several pipelines into thin callers of one tested step, and a fix lands everywhere at once.
8. **Elaborate only when a project earns it.** Starling's one job is not under-engineered; it is right-sized. Complexity is a cost, not a trophy.

None of this is really Jenkins-specific. It is what you end up believing after you have run enough pipelines that the cost of getting the shape wrong starts showing up in your evenings. Jenkins just happens to be the thing holding it all together in my homelab — a quiet little controller that started out building one program and now turns a `git push` into a package on fifteen Linux distributions, a signed APK, a WebAssembly site, and a Raspberry Pi that four people in this house actually use. It started minimal. It did not stay that way, and that is not a failure — it is what *working on things* looks like, written down in Groovy.

---

*If you want the deep version of any one of these, the repositories carry header comments that read like design notes, and I wrote up the Tapedeck split in full in [Twenty-Four Idle Minutes](/posts/twenty-four-idle-minutes/). The music journal itself is [What the Scrobble Throws Away](/posts/what-the-scrobble-throws-away/).*
