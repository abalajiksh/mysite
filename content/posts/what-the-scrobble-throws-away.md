+++
title = 'What the Scrobble Throws Away: Building Tapedeck, a Personal Music Journal in Rust'
date = '2026-08-08T07:12:00+02:00'
draft = false
useAlpine = false
loadNerdFont = false
tags = [
    "tapedeck",
    "rust",
    "self-hosting",
    "music-journal",
    "scrobbler",
    "listenbrainz",
    "musicbrainz",
    "sqlite",
    "axum",
    "sveltekit",
    "audio-quality",
    "signal-chain",
    "vinyl",
    "jenkins",
    "raspberry-pi",
    "open-source"
]
+++

*On seven months of building a personal music journal in Rust, the bugs that taught me more than the features, and why "which pair of headphones" turned out to be a harder question than "which track".*

Since the 3rd of January this year I have been building a thing called
**Tapedeck**. It is a self-hosted **personal music journal** written in Rust —
one binary, SQLite underneath, a web UI baked into the executable — and it runs on
a Raspberry Pi Zero 2 W in my flat, quietly recording everything I listen to, for
about another week until I admit it has outgrown the hardware. The source lives at
[codeberg.org/abksh/tapedeck](https://codeberg.org/abksh/tapedeck), under AGPL-3.0.

![The Tapedeck dashboard, reels turning](/images/tapedeck/dashboard.png "The dashboard. The reels only turn when something is actually playing — this turned out to be harder than it sounds.")

![The Tapedeck dashboard, reels turning](/images/tapedeck/dashboard2.png "The dashboard. The reels only turn when something is actually playing — this turned out to be harder than it sounds.")

Let me get the description right before anything else, because I have spent seven
months resisting the shorter version of it.

Tapedeck **scrobbles**. It is not a scrobbler. It ingests listens and forwards
them to Last.fm and ListenBrainz because that is table stakes — the same way a
notebook has lines on it. That is a feature; it is not the thing.

The thing is an **ode to how music used to be consumed, and how it ought to be**,
meeting what we can actually do today. Somebody who bought a record in 1983 got a
sleeve, liner notes, an object, a side that had to be flipped, and a decision
about which of the four albums they owned to play tonight. All of that was
*context*, and all of it has been optimised away. What replaced it counts plays.
Tapedeck is an attempt to put the context back using the one advantage this era
genuinely has — that a computer can remember perfectly, join across years, and
notice things you would not.

So: a journal of what you played, how you played it, what you thought of it at the
time, and how your taste and your equipment shaped each other — **with a social
element built in from the schema up** rather than bolted on when someone asks for
it. The scrobbling is how the pages get filled.

This post is the development history. It is long, because the interesting part of
this project was never the feature list; it was the twenty or so decisions where
the obvious implementation was quietly wrong, and the four or five bugs that were
wrong in a way that produced no error at all.

## Seven Months at v0.7, and Then Two Weeks

Before anything else, the shape of the calendar, because it is genuinely odd and I
think it is the most interesting fact about the project's history.

Tapedeck started on **3 January 2026**. Nearly seven months later, on **24 July**,
it was still at **version 0.7**. It ingested listens, it forwarded them, it had a
rough web UI, and I used it every day. It was, in the honest sense, finished
enough to stop.

That day I did not stop, and the version numbers have not behaved since. Here is
the actual history, which I find faintly ridiculous:

| Date | Versions |
|---|---|
| 3 Jan – 24 Jul | v0.1 → v0.7 — seven versions in seven months, none tagged |
| 24 Jul – 3 Aug | v0.7 → v0.13.2 — still untagged, see below |
| 4 August | v0.13.3 → v0.20.1 — eleven releases |
| 5 August | v0.21.0 → v0.25.0 — five |
| 6 August | v0.38.0 → v0.39.0 |
| 7 August | v0.40.0 → v0.47.0 — eight |
| 8 August | v0.48.0 → v0.49.0 |

Thirty-one tags in four days, some of them separated by four minutes. `v0.14.0`,
`v0.14.1`, `v0.15.0`, `v0.16.0` and `v0.16.1` all landed inside a twenty-minute
window on the afternoon of 4 August, which tells you something about the size of a
"release" here and possibly something about my judgement. The
[commit that starts it](https://codeberg.org/abksh/tapedeck/commit/e0d4a3ba6fcd4c0128479e18046e12678d031880)
is dated 24 July, and everything after it happened at a pace I have not managed on
any other project.

{{< notice note >}}

An admission attached to that table: **there are no tags before `v0.13.3`.** Not
because nothing was released, but because I did not actually know what git tags
were for, or how releases were supposed to work, until roughly seven months into
maintaining a repository. The first thirteen versions exist only as `Cargo.toml`
bumps. If you are also carrying around a hole in your fundamentals that everyone
assumes you filled years ago: same, and nobody noticed.

{{< /notice >}}

I have thought about the acceleration, and I do not think it was inspiration. I
think it was that **the data model came good**. Those seven slow months were spent
arriving at three structures — the four-rung chain ladder, listens as the single
counting unit, and derived-not-accumulated hours — and once those were right, most
of what followed was queries rather than architecture. The shelf, the rediscovery
collections, equipment hours, the genre map: each of those is a day or two of work
*given* the schema, and would have been weeks otherwise. Seven months of getting
the nouns right, and then the verbs came almost for free.

The second reason is less flattering and worth saying: around v0.7 I started
keeping proper written project notes alongside the README — a running file
recording every decision and every trap as I hit it, now some three thousand
lines. It is the reason I stopped re-deciding things I had already decided, and it
is also, more or less, the source material for this post.

One structural note, then. I have organised what follows by **problem, not by
date**. A chronological version would be that table above with commit hashes
attached, and it would hide the thing that actually happened, which is that the
same class of mistake kept reappearing in different costumes until I finally
learned to look for it. So: problems, roughly in the order I hit them.

## The Problem Nobody's Scrobbler Solves

I have written on this blog before about what happens to music between the
mastering desk and your ears — [the sausage waveform
epidemic](/posts/sausage-waveform-epidemic/), the [DSEE Ultimate
experiments](/posts/self-hosting-music-library-and-dsee-shenanigans/), the
[low-latency Snapcast
streamer](/posts/ditching-bluetooth-building-a-low-latency-hi-res-audio-streamer-with-raspberry-pi-hifiberry-and-snapcast/)
I built so I would stop putting a Bluetooth codec in the middle of my own
listening. The through-line in all of them is that **the signal chain is the
experiment**, and the recording is only the sample.

And yet: every scrobbler I have ever used throws that away.

Last.fm knows I played *Sound of Silence* at 21:14. It does not know whether that
was the 24/96 FLAC through the Mimir and the Midgaard into a pair of HD 650s, or
the same file transcoded to 256 kbps AAC and shoved down an SBC pipe into a pair
of earbuds on a train. Those are not the same event. They are barely the same
*category* of event. One of them is listening; the other is having music on.

Once I noticed I was annoyed about this, a second annoyance arrived immediately
behind it: **nothing scrobbles a record player.** No API, no protocol, no metadata
— a turntable is a device that will never tell you anything. Which means that for
anyone who listens that way, their listening history is systematically biased
against exactly the format they most likely care about.

I should be straight about my standing here, since I am about to spend a long
section of this post on it: **I don't own a turntable.** I want one. What I
actually do is go to the used record store and spend an hour flipping through
crates while whatever the staff have put on plays over the shop system — which is,
incidentally, some of the best listening I do all month, and none of it is
recorded anywhere either. So the shelf in Tapedeck was built for a deck I intend
to buy, which is an unusual way to develop a feature and one I will come back to.

So the requirement, written down early and never revised:

{{< notice note >}}

Tapedeck should not be another Last.fm. It should become a **personal musical
autobiography** — not only what I listened to, but *how* I listened, what I
thought about it at the time, and how my taste and my equipment shaped each
other.

{{< /notice >}}

That sentence has settled more arguments in this codebase than any technical
principle. Four consequences fall straight out of it, and I have used them as
tie-breakers over and over:

1. **How something was played is first-class data, not decoration.** A listen
   arriving without a signal chain is a bug, not a cosmetic gap.
2. **Your own library beats any metadata provider.** If the exact file you played
   has cover art embedded in it, that art is *more correct* than anything an API
   can return, and it costs nothing.
3. **Nothing recommends music you don't own.** A self-hosted listening journal
   that points you at things to go and buy is the wrong shape.
4. **Anything personal is editable by hand.** Including the things the software
   guessed at.

## Prior Art, Mostly My Own

Tapedeck did not appear from nothing. It has two direct ancestors, both of which
I have written about here.

The first is my **ListenBrainz analytics scripts** — the `musical_personality_v2.py`
monstrosity that pulls my entire listen history, canonicalises collaboration
credits with a two-pass regex, does a rate-limited MusicBrainz language lookup with
disk caching, and spits out nineteen PNG plots and a pile of CSVs. It worked. It
also took several minutes to run, produced static images I then had to go and
look at, and answered exactly the questions I had thought to ask when I wrote it.
Every one of those plots is now a live screen in Tapedeck, computed from a local
database in milliseconds. That was not the plan; it is just what happens when you
put the data somewhere queryable.

The second is the **self-hosted music library** post — the 450 GB of FLAC on a
Plex server, the whole argument about whether hoarding lossless files is worth the
storage. Tapedeck is, in a sense, the instrumentation for that argument. If I am
going to spend disk on 24-bit files, I would quite like to know how often I
actually listen to them through a chain that can resolve the difference.

There is a third, more distant relative: `libdsddpcm` and **crête**, my DSD decoder
and dynamic-range meter. Those are not integrated with Tapedeck and there is no
plan for them to be. But they come from the same thesis — that the measurable
properties of a delivery format are worth measuring rather than assuming — and
they are the reason DSD is a first-class citizen in Tapedeck's quality model
rather than an afterthought bolted onto a PCM-shaped schema.

## Design Constraints, Fixed on Day One

Before any code, four constraints, all of which survived:

**One binary.** No Docker Compose file with six services. No separate frontend
deployment. `scp` a binary, restart a systemd unit, done. This is the constraint
that has paid for itself the most times, and it is also the one that cost the
most engineering — the SvelteKit SPA is compiled by `build.rs` and embedded via
`rust-embed`, which means `cargo build` is genuinely the whole build, and which
also means **bun is a hard requirement for every `cargo check`**. There is an
escape hatch (`TAPEDECK_SKIP_WEB_BUILD=1`) for Rust-only work, but the default is
that a fresh clone compiles into a runnable artefact. I will take that trade
every time.

**Rust.** Partly because the target is a Pi Zero 2 W and I wanted the memory
profile of a compiled binary rather than a JVM or a Node process. Partly because I
wanted the compiler to be adversarial with me. Mostly, honestly, because I wanted
to write a real Rust project rather than another Python script.

**SQLite, in WAL mode.** One file. `VACUUM INTO` gives a consistent backup while
the process is running. `busy_timeout(10s)` means concurrent writers wait instead
of erroring. A hard `SIGKILL` cannot corrupt it. For a personal system of record
where the entire dataset is tens of thousands of rows, anything bigger would be
ceremony.

**Privacy by default.** The instance is private and invite-only. There is no
self-registration. Credentials that have to be replayed — Plex tokens, Jellyfin
API keys, the Navidrome password, Last.fm session keys — are encrypted at rest
with XChaCha20-Poly1305 and a key held *outside* the database.

That last one deserves an honest threat model, because it is easy to oversell:

{{< notice warning >}}

The encryption key lives on the same host as the database. This protects **a
leaked backup or a stolen DB file** — which is a real risk, because
`GET /api/v1/backup` will happily hand you the entire database over HTTP. It does
**not** protect against host compromise, and I do not claim it does. The
corollary is that the key must never end up inside a backup, which would defeat
the entire point.

{{< /notice >}}

## Speaking a Protocol Instead of Inventing One

The first real design decision was the ingest API, and I got it right by being
lazy in the correct direction.

I could have designed a nice clean Tapedeck-native submission format. Then I
would have had to write a client for Android, a client for the desktop, a client
for whatever comes next, and persuade other people's software to care. Instead
Tapedeck implements **the ListenBrainz Core API** — the endpoints a scrobble
client actually exercises: `validate-token`, `submit-listens`,
`user/…/listens`, `playing-now`, `listen-count`, `services`, `playing-now/delete`
and `latest-import`.

The result is that Pano Scrobbler, Web Scrobbler, multi-scrobbler, mpdscribble
and fooyin all work with zero Tapedeck-specific code. You point them at your own
URL, paste a token, and they cannot tell the difference.

![Pointing Pano Scrobbler at a Tapedeck instance](/images/tapedeck/pano-config.png "Pano Scrobbler configured against a self-hosted Tapedeck. It thinks it is talking to listenbrainz.org.")

There are exactly two deliberate deviations from listenbrainz.org, and both are
consequences of being self-hosted rather than public:

- **Reads require a token.** On ListenBrainz your listens are public, so
  `user/:user/listens` is unauthenticated. On a private household instance that
  would be a data leak with extra steps. Every read endpoint requires auth and
  returns only your own data.
- **No MSIDs.** ListenBrainz assigns a message-set ID to every recording;
  Tapedeck keys listens by source instead, so `/1/delete-listen` simply isn't
  implemented. `DELETE /api/v1/scrobbles/:id` does the job. Playlists and
  `lb-radio` aren't implemented either, and return a clean JSON 404 rather than a
  stub that lies.

### `additional_info` is a swamp, and you must wade through it politely

The ListenBrainz spec has an `additional_info` object which is, by design, free
form. Real clients disagree wildly about what goes in it and in what shape, and
the bug this produced is the most recent thing I fixed — it landed the morning I
started writing this post, so the details are unusually fresh.

The symptom, reported by me about my own instance: **fooyin passed the connection
test, scrobbled happily to Last.fm and ListenBrainz, and put absolutely nothing
into Tapedeck.** Two independent causes, and the second only became visible once
the first was out of the way.

**Cause one: a strict type in a free-form bag failed the whole submission.**
`additional_info.tracknumber` was typed `Option<i32>`. fooyin's
`Metadata::trackNum` is a `QString`, so it sends `"tracknumber": "1"` — a string.
serde failed, and serde has no per-field recovery. Axum's `Json` extractor
therefore rejected the entire request body with a **422 before my handler ever
ran**: the whole batch died, no `rejected` entry named a cause, nothing was logged
past the extractor, and fooyin's disk cache dutifully retried the same doomed
request forever.

And here is why it read as an authentication problem: **`validate-token` parses no
body.** So "Test Connection" kept cheerfully reporting that everything was fine,
while every actual submission was being thrown away at the door. This one *did*
produce an error, unlike the others in this post — it was simply invisible to
every party in a position to act on it.

`lenient_track_number` now takes a number, `"7"`, or `"7/12"`, and swallows
anything else. One deliberate exception, which I like:

{{< notice note >}}

A vinyl **`"A1"` deliberately does not parse to `1`.** A side letter is a
*position*, not an index into the release — parsing it would file every side's
opener at track one, and it would do so silently and confidently. Better to have
no track number than a wrong one that looks right.

{{< /notice >}}

The rule the field now follows, and which I have propagated everywhere: **a bad
value in that bag costs the field and never the listen.** `duration_ms` has the
same shape and escapes today only because fooyin happens to send it as a number,
which is not a property I want to be relying on.

**Cause two: MBIDs were being thrown away, and the spec said otherwise.**
`mbid_mapping` is the shape ListenBrainz *returns* — it's what an export carries,
which is why the import path reads it. But a *submitting* client writes
`recording_mbid` / `release_mbid` / `release_group_mbid` / `artist_mbids` at the
top of `additional_info`. Reading only the mapping meant a client that had
*already identified the recording* paid for a rate-limited MusicBrainz lookup
anyway, with nothing erroring to say so. My own `openapi.yaml` had been documenting
these as read since v0.39.0. They weren't.

Both are read now, `additional_info` first — the client is describing the file it
just played, whereas a mapping is ListenBrainz's own guess. And blank is not an
answer: an empty string outranking a real MBID would satisfy every `IS NOT NULL`
that the enrichment backfills queue on, filing the row as identified and never
looking it up again.

### `listen_type: "import"` does not mean what the field name implies

The same investigation turned up a third thing, and its resolution is the most
*design*-shaped decision in the ingest path.

Tapedeck stores listens marked as an import but does not forward them, because an
import normally means a chunk of old history and pushing that onward rewrites a
permanent public record. Reasonable. Except that **fooyin hardcodes `import` for
every scrobble it has ever sent**, single or batched. So `import` is not a
statement that this is a backfill — it is whatever that client's author decided
the word meant, and nothing on the wire distinguishes the two cases.

Matching on `submission_client` was the obvious fix and is wrong twice over: it's
free text the client picks, so the guard protecting a permanent public record
would be under the control of the very thing it guards against; and it would need
a new entry per client, forever.

So the decision is **the operator's, stated once per token**: a *Relay listens*
checkbox in Settings → API Tokens, off by default and off for every token that
already exists. Tokens are already one-per-app, which is exactly the granularity
the question has.

Both gates are load-bearing. The token gate says *this client batches live
scrobbles*. A 24-hour window bounds how wrong that claim can be, so a client
marked live that later performs a genuine backfill **fails closed** on its old
timestamps. The token alone would re-open the exact bug the disposition field
exists to close. A day is far more than any player's offline queue and far less
than any backfill, and Last.fm accepts fourteen days regardless. Future timestamps
are clock skew and are allowed — but only to an hour.

One small thing I am pleased with: the dry-run preview and the real path call the
**same function**. A preview that says "will be forwarded" about a listen that
then isn't is worse than having no preview at all.

## The Four-Rung Ladder

This is the part of Tapedeck I would defend hardest, and it is the direct answer
to the "which headphones" problem.

The naïve design is a field on the listen: `equipment: "HD 650"`. This is wrong
for a structural reason that took me a while to articulate. **Attribution happens
at the source, but a chain lives downstream.** fooyin knows it is fooyin. It does
not know that its output is going through a Schiit Mimir into a Midgaard into a
pair of 300-ohm open-backs, and it has no business knowing.

So a signal chain in Tapedeck is a server-side object — an ordered path from
source to ears:

```
Desktop → Schiit Mimir (DAC) → Schiit Midgaard (Amp) → HD 650
```

Components are picked from your equipment list rather than typed as free text, so
one piece of gear is one record no matter how many chains it appears in. A step
can still be free text for something you don't own and don't want to catalogue.

And then the server resolves which chain a listen belongs to on a **four-rung
ladder**, first match winning. The order is not arbitrary; it encodes what each
rung *is* as evidence:

1. **An explicit chain name from the client** (`tapedeck_chain.chain_id`). Direct
   evidence about this specific listen. Wins outright.
2. **An output-device binding.** The client reports the OS output device —
   a USB DAC's name, a Bluetooth device, `"wired"` — and every distinct output is
   **auto-learned** and surfaced in an Outputs panel. You map it to a chain
   *once*, and every future listen through that output attributes itself.
3. **The submitting token's default chain.** This is the rung that made the whole
   thing usable. One token per app — `fooyin`, `Pano on Android`, `walkman` — is
   how people organise these anyway, so a token carries a chain and the app needs
   no Tapedeck-specific configuration whatsoever. Crucially, a token can be
   *repointed* later without re-issuing it, so fixing a chain never means pasting
   a new credential into a music player.
4. **The submitting machine's default chain**, as the coarsest fallback.

![Signal chain editor](/images/tapedeck/signal-chains-1.png "A signal chain, built from equipment records rather than free text.")

![Signal chain editor](/images/tapedeck/signal-chains-2.png "A signal chain, built from equipment records rather than free text.")

The payoff is that **you never tag a listen by hand.** Issue one token per app,
give each token a chain, and attribution is done forever. Ambiguous cases — one
output feeding two rigs — get fixed retroactively with a bulk chain-reassign in
the History screen.

And because a chain names its components, questions that would otherwise need a
per-listen equipment field become joins. "Which albums have I never heard on the
HD 650s?" is answerable with no extra schema at all. That query is now a feature
called *Rediscovery*, and it exists purely because the data model was right.

### Hours are derived, never accumulated

A related decision that I keep being glad about. Tapedeck tracks total hours on
each piece of gear — useful for driver burn-in, warranty records, and stylus wear.
The obvious implementation is a counter you increment as listens arrive.

Don't. **Sum the listens instead.** A chain's hours are the running time of every
listen carrying it; a component's hours are the sum of the chains naming it. It
costs a `GROUP BY` and it buys two things: assigning a chain to a device
retroactively moves the hours for listens *you already have*, and the number can
never drift from the plays it claims to count. An accumulated counter is a second
source of truth, and a second source of truth is a bug with a delay fuse.

Skips don't count either. Crediting a pair of headphones with a track's full
running time on the basis of three seconds of audio is not a measurement.

## Everything Is Per-User, Including the Things That Hurt

Tapedeck started single-user and it was much easier that way. Making it
multi-user was the first genuinely invasive refactor, and it touched the poll
engine, the sink layer and every query in the codebase.

The single-row `plex_settings` table became `user_sources`, one row per user per
source. The engine's `Vec` of sources became a registry keyed by
`(user_id, kind)` with per-source poll intervals and **staggered polling**, so
that N users × M sources doesn't hammer a Raspberry Pi on the same tick.

The important half is the sinks. **Forwarding is strictly per user; there are no
server-wide scrobble credentials.** Each account connects its own Last.fm and
Libre.fm (one-click OAuth) and ListenBrainz (paste a token). A listen can only
ever reach accounts the listening user connected themselves. Connect nothing and
your listens simply stay local. `sinks_for_user()` is the only place a sink gets
constructed, which is the kind of chokepoint that makes an isolation property
auditable rather than aspirational.

Same for sources: **each person connects their own Plex token or Jellyfin API
key**, and Tapedeck resolves it to a remote account and records only that
account's playback. There is no fragile matching of Plex display names against
Tapedeck usernames — every household member has their own Plex account anyway, so
the name-matching fallback was deleted rather than kept as a safety net.

There is one wrinkle I want to be honest about, because it is a live known gap:
**entity pages don't scope by user.** Play counts are correctly the caller's, but
an entity's *name* comes from a shared table, so ids can be walked to learn what
another household member has annotated. Low severity on an authenticated,
invite-only instance, metadata-only — and parked deliberately as a design call,
because the fix interacts with the visibility model that the (deferred) social
phase will settle. I would rather have a stated gap than a fix that boxes in a
schema decision.

## Where Listens Actually Come From

By the time this was done, Tapedeck could ingest from five directions:

### Rockbox, and the timezone I refused to guess

You can upload a `.scrobbler.log` straight off a Rockbox DAP. The format
(Audioscrobbler Log 1.1) is tab-separated with three `#`-prefixed header lines
and eight columns, the last of which carries MusicBrainz IDs — so those listens
skip MusicBrainz entirely.

Two things in there are worth the space:

**Skips are stored but never counted.** Rockbox marks each row `L` (listened) or
`S` (skipped). Discarding the `S` rows loses genuinely interesting data — skip
rate is a real signal about how you feel about a record. But a skip that reaches
Last.fm is a *wrong scrobble on a permanent public record*. So they're stored,
flagged, and excluded from listen counts, from analytics and from forwarding.

**`#TZ/UNKNOWN` is refused, not guessed.** A DAP with no time sync writes that
header, and the temptation is to assume the server's timezone. Don't. If you
assume wrong you shift that device's entire history by the offset, silently, and
you cannot recover it afterwards because nothing in the file records what the
right answer was. Tapedeck asks which timezone the device was set to. It is one
extra dialog and it is the difference between a history and a plausible-looking
fiction.

![Rockbox log import, asking for the device timezone](/images/tapedeck/rockbox-import.png "Refusing to guess. One dialog, and the alternative is silently shifting a whole device's history.")

### Navidrome speaks two APIs and needs both

Navidrome is the best of the sources because it keeps **its own play history**,
which means connecting it backfills listens from before Tapedeck existed and then
keeps up live. Nothing else on the list does that — Plex and Jellyfin both start
from the moment you connect them.

It needs both of Navidrome's APIs: the native one (`/auth/login` →
`x-nd-authorization`, then `/api/scrobble/?from=`) for history, and Subsonic
(`/rest/*`) for now-playing and for metadata. Your library's own MusicBrainz IDs
come along for the ride, so those listens never need a lookup.

The awkward bit: Subsonic authenticates by hashing `password + salt` on every
request, so Tapedeck has to store the account *password*, not a token. It's
encrypted like everything else, and I am not thrilled about it, but the
alternative is giving up on the user's own library as a first-class metadata
source — which is a pillar, not a nice-to-have.

### Plex, Jellyfin, and the deck that got stuck

Both are polled directly. No webhooks, no Plex Pass required, accurate scrobble
thresholds (50% played or four minutes), and live Now Playing on the dashboard.

And this is where I hit the first bug that genuinely taught me something, which
gets its own section below.

## Four Bugs That Taught Me More Than the Features

The fooyin story above at least produced a 422 somewhere. These four produced
**no error at all**, which is the common thread and the whole lesson. A crash is a
gift. A field that is quietly always `None` is not.

### 1. The deck showed the previous track

Symptom: the dashboard's cassette deck displayed the track *before* the one
playing. Scrobbling worked perfectly. It read, unmistakably, as a frontend bug,
and I looked at the frontend for far too long.

The cause was one boolean, reused. `plex.rs::process_live_track` gated
now-playing on `!state.scrobbled` — the same flag that stops a track being banked
twice. So the moment a track crossed the 50% threshold and was scrobbled, it
dropped off the now-playing report. The pipeline read the resulting empty session
list as "playback stopped", and the dashboard fell back to `recent[0]`, which is
the track that just finished.

{{< notice note >}}

**Having banked the scrobble says nothing about what's on the deck.** They are
two independent outputs from the same poll: `ready_to_scrobble` fires exactly
once, `now_playing` fires every tick the player is playing.

{{< /notice >}}

The corollary bit me a second time in the opposite direction: `flush_pending`
must **not** be gated on "is anything playing", or nothing forwards to Last.fm
until you stop the music.

### 2. Last.fm never received a single now-playing

`sinks::submit_now_playing` used to downcast to `ListenBrainzSink` to find
something with a now-playing capability. Which meant Last.fm and Libre.fm silently
never got now-playing at all. Scrobbles worked, so nothing looked broken, and I
did not notice for weeks.

The fix was conceptual rather than mechanical: now-playing became a
`ScrobbleSink` **trait method** with a default no-op body, and `submit_now_playing`
just calls it on every sink. The `Any`-downcasting elsewhere in the pipeline is
for capabilities the traits genuinely can't express; *every* service Tapedeck
forwards to has the concept of now-playing, so it belongs in the trait. If you
find yourself downcasting to reach a capability that every implementor has, the
trait is wrong.

(One deliberate asymmetry survived: Last.fm's `track.updateNowPlaying` has no
retry loop, unlike `scrobble`. Now-playing is superseded by the next tick, so a
backoff would only queue stale state and then report it as current.)

### 3. "Various Artists" ate the performers

I had a rule — "the record's artist wins" — introduced to stop a compilation
credit fragmenting across the sanitiser. It is correct for a soundtrack. It is
catastrophically wrong for a compilation, where `Various Artists` is a
**placeholder meaning *look at the track***.

The result was that every listen from *Do You Like Brahms?* went into my history
credited to Various Artists instead of to Punch and Kim Na Young.

Worse, the same trap was waiting in the metadata sanitiser's split-attribution
pass. The placeholder appears on *every* track of a compilation, so it wins any
breadth test outright — the sanitiser would have cheerfully folded real performers
onto it. `db::is_various_artists` is now a guard in both places, and the rule is
directional: **you can fold away from the placeholder, never onto it.**

### 4. The denominator bug I found five times

This is the one I want to dwell on, because it is the oldest lesson in
experimental work wearing a software costume: *choosing the right observable
matters as much as measuring it carefully.*

Skips are stored but must never be counted. Simple rule. I have now written it
wrong **three separate times** — in a play count, in an artist rank, and in an
artwork-coverage numerator — each time because a new query got written beside an
old one and inherited everything about it except the `skipped = FALSE`.

Then the same species of bug turned up in a completely different guise, in the
fidelity cards, and this version was worse because the output *looked correct*.

**Audio quality is only known for listens a live source reported.** An import from
Last.fm, ListenBrainz or Spotify carries no format information at all. When I
audited this the history was 21,390 listens and **97% of it** had no format. It
has since grown past 48,000 and the share has, if anything, got worse — the
Spotify extended-history import that caused most of that growth carries no format
field either. So a card reading "42% lossless" was computing a share over the few
per cent of my listening whose format was known, and presenting it as a verdict on
my library.

That number is not wrong, exactly. It is a fact about the twentieth. It is
displayed as a fact about the whole.

{{< notice warning >}}

The rule now, and it is enforced everywhere a figure is drawn: **every figure
computed over a narrower population than "everything you played" must say so.**
Below a quarter coverage, the card reports its *coverage* instead of a
percentage — because a share drawn from a twentieth of your history reads as a
verdict and isn't one.

{{< /notice >}}

Collapsing the duplicated fidelity cards then exposed two more instances of the
identical bug in adjacent cards, and the album page ended up dropping its Lossless
card entirely rather than displaying a number nobody could interpret. Five
instances of one mistake.

The generalised lesson, which I have now written on a metaphorical wall: **audit,
don't trust.** When a rule has to hold across many queries, at some point you stop
grepping for the rule and start writing a test that enumerates the queries.

### An honourable mention: the edit that changed the wrong function

A process note rather than a code bug, and it cost real time. An edit anchored on
a SQL snippet matched `artist_rank` instead of the function I meant, because both
contained the identical line `GROUP BY LOWER(TRIM(artist))`. It applied silently
and cleanly. Had it shipped, it would have ranked `LINKIN PARK` and `Linkin Park`
as two different artists.

`assert old in s` is not sufficient when the string appears more than once. Check
the **count**, or anchor on something unique to the function you actually mean.

## Measure Before You Adopt: the simd-json Non-Story

I was convinced the JSON parser was the bottleneck in large imports. A 21,000-listen
ListenBrainz archive takes minutes; parsing is obviously the hot path; simd-json is
obviously the fix.

Measured: **1.01× against `serde_json`** on 80,000 listens. Parsing is roughly
60 ms of a job that runs for minutes. Reverted the whole thing.

Two lessons, one specific and one general. The specific one: SIMD JSON needs
*large* documents to amortise its setup, and JSONL is a stream of ~300-byte ones —
precisely the worst case. The general one is the reason I am including a
non-result in a promotional blog post at all: **my intuition here was confidently
wrong**, and the only reason I know that is that I measured it before believing
it. That is the same discipline as running the benchmark before writing the
transcoding post, and it is the only reason any of my numbers are worth anything.

## The Shelf: Recording What Nothing Can Report

This is my favourite part of Tapedeck, and it is the feature that most clearly
belongs to *this* application rather than to scrobblers in general.

You catalogue a shelf — vinyl, cassette, CD, SACD — by barcode, catalogue number,
or artist and release. MusicBrainz always; Discogs first for a barcode when a
token is configured, because Discogs catalogues **pressings** and will usually
land on the exact edition rather than a plausible one.

Then you play a side. Press **Start** when the needle drops, and a platter turns
on screen at a real 33⅓ with a countdown. The browser runs the clock, so pause
and skip are recorded *as they happen* and each track lands where it actually
played.

![The shelf, with a turntable deck mid-side](/images/tapedeck/shelf-vinyl.png "The deck is drawn for the medium in hand: a tonearm swings down for a record, both reels turn for a cassette, a disc spins faster and with a sheen.")

Four decisions in there that took thought:

**A side writes one listen per track, not one per side.** Every counting query in
Tapedeck is over listens. A side-shaped row would be invisible to all of them —
your vinyl listening would exist in the database and appear nowhere in your
statistics. This is the single most important structural call in the feature.

**Sides are split by playing time, and the UI admits it's a guess.** No provider
reliably reports sides; MusicBrainz records a vinyl track number as `A1` only when
a human editor entered one. So Tapedeck splits by duration, on the reasoning that
a side holds around twenty minutes and a mastering engineer balances them.
Splitting by *track count* would put a nine-minute closer on the wrong side of the
break. It is a guess, it is labelled as a guess, and the tracklist is editable.

**A disc is the smaller problem.** A CD or SACD plays start to finish, so its
tracks come off as one numbered unit and the UI says *Disc 1* rather than *Side
A*. Which rule applies is decided by the medium's own format string, not by what
you searched for. This is also why discs are a *shelf* format rather than a
*source*: no disc player of any brand or vintage will tell you what it is
playing, but the shelf already holds the tracklist — so it works today, with no
driver at all.

**If you didn't watch the clock, say so.** There is an *Already played* button
that lays the running order out backwards from the sleeve times. Right ordering,
right gaps, but nobody observed the timestamps — and the UI states that, rather
than presenting inferred times with the same confidence as measured ones.

Stylus hours and the cassette counter are derived from the sides played, never
accumulated. Same rule as gear hours, same reason.

### Building for a deck I don't own yet

As I said at the top: I have no turntable and no cassette deck. Every side of
vinyl this feature has ever recorded was somebody else's, catalogued and clocked
by hand as an exercise. So it is fair to ask what business I have building it.

Two answers, one defensive and one that I think is actually right.

The defensive one is that the hardest parts of this feature are not about owning
the hardware. The side-splitting heuristic, the one-listen-per-track decision, the
*Already played* honesty flag, the derived counters — those are questions about
data and about what a record is allowed to claim, and you can get every one of
them wrong or right with no turntable in the room. What I cannot test is the
ergonomics: whether pressing **Start** as the needle drops is actually a thing a
person does twice, or whether it is the kind of ritual that sounds charming in a
README and dies in week two. I genuinely do not know, and I will not know until I
own the deck.

The better answer is that I built it because of the record store. I spend real
time in a used shop near me, going through crates while whatever the staff have
put on plays overhead — and that is some of the most attentive listening I do,
precisely because I did not choose it and cannot skip it. None of it is recorded
anywhere. It occurred to me that the reason my listening history is thin on
exactly the music I most enjoy discovering is not a taste problem, it is an
*instrumentation* problem. Building the shelf first is a bet that the
instrumentation should exist before the habit does, rather than trying to
reconstruct a year of it afterwards from memory.

Ask me again when there is a turntable in the flat and the first Sunday afternoon
goes unlogged.

## Analytics That Refuse to Lie

The analytics were where the "autobiography, not leaderboard" framing did the most
work, mostly by telling me what *not* to build.

There is no *"you out-listened 88% of listeners this year"*. That statistic needs
other people's listening, and on a household instance it quietly reports how much
your partner plays. Where a design called for a percentile, Tapedeck ranks the
period against **your own**: *"your 2nd busiest month of 8"*.

**Reports** are your listening in chapters — a week, a month or a year at a time,
with a stepper to walk back through the whole history. The three are genuinely
different shapes rather than one card resized: a month gets the full treatment
(clock, genres, on repeat, off the shelf); a week gets the compact one, because
seven days make a hopelessly thin hour-of-day distribution so it simply isn't
drawn; a year is a bento of tiles around a twelve-month line with the prior year
ghosted behind it. All folded from **one pass** over the history, bucketed in your
own timezone.

![Reports — the monthly chapter](/images/tapedeck/reports-month.png "A month of listening, one pass over the history, bucketed in your own timezone.")

That timezone is an IANA region (`Europe/Berlin`), not a fixed offset, and that is
deliberate: `Europe/Berlin` *is* CET in winter and CEST in summer, and hard-coding
either one puts half your year in the wrong hour.

### The genre map, and two techniques I deliberately did not use

Tapedeck scrapes **Every Noise at Once** into its own database and places your
listening on it. From that you get a coverage map, a taste trajectory over time,
the genre neighbourhoods bordering what you already play, and two scale-free
breadth numbers.

![Genre map with listening overlaid](/images/tapedeck/genre-map.png "Every Noise at Once, with my own listening lit up on it.")

Two implementation notes for the physicists in the room, and one negative result
I am unusually pleased with.

The colour blending is done **in linear light, not sRGB**. Mixing gamma-encoded
values is the classic wrong-but-plausible operation; it produces muddy midtones
and, more importantly here, it makes the blend non-linear in exactly the quantity
you are trying to represent.

The trajectory's granularity **follows the data**. A history with eight months in
it gets monthly buckets; one with eight years gets yearly. Fixing the bucket size
means either a trajectory made of noise or one made of two points.

And the negative result. The obvious move, once you have genre positions and a
listening history, is to run UMAP or t-SNE over it and produce a beautiful
manifold. I deliberately did not, for a reason worth stating plainly:

{{< notice note >}}

**Every Noise is already a dimensionality reduction.** Its 2D layout is the
product of an embedding whose axes carry meaning — dense/atmospheric ↔
spiky/bouncy, organic ↔ mechanical. Running t-SNE over that output discards the
one property that makes the axes interpretable, in exchange for a prettier
picture that means less.

I also considered persistent homology over the genre point cloud, and rejected it
for the same species of reason: with a few hundred distinct genre positions in
two dimensions, the "holes" you would find are artefacts of Glenn McDonald's
layout, not facts about a listening history. Confident-looking output that means
nothing is worse than no output.

{{< /notice >}}

I mention this because it is the closest thing in the project to a physics
decision — the difference between an observable and an artefact of your
coordinate choice — and because a promotional post that only lists what got built
is not much of a history.

### Playlist Lab

The genre map earns its keep in **Playlist Lab**, which grows a playlist by moving
through the space your listening actually lives in. Three modes: *similar songs*
(nearest neighbours of your seeds), *dimensional crawl* (a path traced between two
or more seeds, one step at a time), and *rollercoaster* (a trajectory that climbs
to peaks and dives to lows along whichever axis you pick). A phase-space plot
shows any two of the ten dimensions with your playlist drawn on it.

The ten dimensions, precisely: six come from Every Noise via each track's artist —
dense/atmospheric ↔ spiky/bouncy, organic ↔ mechanical, the three colour channels
(Every Noise encodes audio character in them), and how far apart a track's own
genres sit. Four come from your own listening — era, familiarity, hour of day,
recency. A *Judge by* slider weights the two halves, because without it "similar"
quietly drifts towards "played at the same hour".

![Playlist Lab phase-space plot](/images/tapedeck/playlist-lab.png "Two of ten dimensions, with a generated playlist drawn as a trajectory through them.")

And the disclaimer, which is in the UI and not only in the README, because this is
exactly the sort of thing that gets oversold:

**This is not a per-recording audio analysis and nothing here pretends
otherwise.** Genres attach to *artists*, so every track by one artist shares its
six sound coordinates; it is the four listening axes that separate them. Tracks
whose genres have no place on the map are dropped rather than parked at the
origin, and the count of dropped tracks is reported.

Finished playlists export as M3U, JSON or plain text — or go straight to your own
Plex, Jellyfin or Navidrome with **Send to…**, matched by artist and title with
every match checked, so a fuzzy hit for the wrong artist is discarded rather than
added. Tapedeck has no playback and is never going to grow any; pushing to the
server you already run is the correct shape for that.

### Musical Personality

The direct descendant of my Python script. Five explainable axes — Adventurer ↔
Loyalist (artist spread), Curator ↔ Drifter (album-block listening), Casual ↔
Obsessive (replays), Lark ↔ Night Owl, and Mood-Driven ↔ Identity (how much your
rotation shifts by context) — plus a per-artist loyalty score that separates
long-haul favourites from one-week infatuations.

All computed locally, no external calls. Album-playthrough detection uses stored
track numbers, which is one of the reasons that forgiving `"7/12"` parse mattered.

Apparently I am The Obsessive Curator — which, given that I will play a box set
straight through and then do it again, I dispute on neither axis.

## Making It a System of Record

Somewhere around the point where Tapedeck held my entire listening history back to
January 2023 — 48,000 listens and counting, including hand-entered plays that
exist nowhere else — it stopped being a toy and the reliability requirements
changed underneath me.

**Durable ingest.** Listens are written to SQLite *before* the API returns. If a
listen can't be persisted, `/1/submit-listens` returns a retryable `503` so the
client resends. Deduplication makes retries safe, so nothing is silently dropped.

**At-least-once forwarding with no double-scrobbles.** Each pending listen carries
a `delivered_sinks` JSON set; a retry only re-sends to sinks that haven't accepted
it. A flaky Last.fm can't cause duplicate scrobbles because ListenBrainz was
down. Both sinks retry with backoff.

**Graceful shutdown.** On `SIGTERM` the HTTP server drains in-flight requests,
then the poll engine finishes its current tick and exits — no work is cut
mid-write. A hard `SIGKILL` can't corrupt the database either (WAL plus atomic
writes); pending scrobbles resume on restart, and an interrupted import is
*recorded as interrupted* rather than left looking finished. Metadata enrichment
runs off the request path, so a bulk submit returns in milliseconds and can't
stall shutdown.

**Scoped tokens**, which is a security story with a nice punchline. An API token
carries explicit scopes and **none implies another**:

| Scope | What it allows |
|-------|----------------|
| `submit` | `POST /1/submit-listens` and nothing else. What every scrobble client holds. |
| `read` | History, stats, loves, notes, now-playing, chains, gear. |
| `write` | Loves, notes, and editing or deleting a listen. |
| `all` | `read` + `write`. |

`submit` deliberately does not imply `read`, because the token sitting in a
scrobble client on a phone that gets lost must not be able to read the history it
is appending to. Matching is exact, so a scope of `rewrite` does not grant
`write` — there is a test pinning that specific substring case.

And the punchline: a valid token missing the needed scope gets **403, not 401**.
It authenticated fine. A 401 would send a well-behaved client into a token-refresh
loop it can never win.

`DELETE /api/v1/scrobbles` (clear everything), everything under `/admin/`,
sources, connections, export and backup are **permanently session-only** — no
token reaches them at any scope. That is the one listen operation a lost phone
could make unrecoverable.

## Documenting an API So It Can't Drift

The whole API — 105 paths, 132 operations — is described in `openapi.yaml`, and
every running instance serves its own copy at `GET /api/openapi.yaml`,
unauthenticated. Unauthenticated because it documents *shapes, not data*, and a
client has to read it before it has a credential; the login and device-pairing
flows are in there.

Serving it from the binary is the one thing a separately hosted docs site cannot
do: it describes **that** instance at **that** version. For self-hosted software
that beats any version dropdown on a docs site.

The load-bearing piece is a **drift test** that walks every `.route("…")` literal
in the source and compares both directions — routed but undocumented, *and*
documented but not routed. The second direction is the one that bites: a stale
path sends a client author to an endpoint that 404s, and nothing else in the build
would ever notice. Two traps I hit while writing it: axum spells a parameter `:id`
and OpenAPI spells it `{id}`, so both fold to `{}` before comparing (a rename from
`:id` to `:job_id` is not drift); and the scanner reads *its own source*, where
`.route(` appears inside test string literals. There is a companion test asserting
the scanner finds known routes, because a silently-broken scanner would make the
drift check pass by finding nothing at all.

A later addition enforces `info.version` against `CARGO_PKG_VERSION`, added after
the field had gone four releases stale. That matters more here than a wrong
version number usually would: the entire argument for serving the spec from the
binary is that it describes that instance at that version, so a version field that
lies undoes the property the endpoint exists for.

The README used to carry endpoint tables. They are gone. A second copy of the API
maintained by hand is a copy that goes stale, and they had already gone stale in
the way that matters — still describing tokens as able to do "exactly one thing",
two versions after scopes shipped.

## The Silent Failure That Cost Me a Day

The frontend deserves its own war story, because it is the purest example of the
theme.

The SPA is SvelteKit 2 with Svelte 5 installed (though written in Svelte 4 idiom —
`export let`, `on:click`, `$:`, `<slot />`), Tailwind with a Rosé Pine palette
exposed as `rp-*` utilities, `adapter-static`, `ssr = false`.

One day the whole app rendered a spinner forever. The build succeeded. The markup
was correct. Nothing logged. No console error.

`@sveltejs/vite-plugin-svelte@4` has a peer of `vite@^5`, and it had been
installed alongside `vite@6`. The result was that the toolchain **compiled every
`onMount` call out of the bundle**. Which meant the root layout's auth gate never
ran, so first-run never redirected to `/setup`, and every page shipped its
pre-fetch skeleton and stopped.

The mitigations, in order of how much I trust them:

- `web/bun.lock` is committed, with an explicit `!web/bun.lock` negation against
  the blanket `*.lock` in `.gitignore`.
- The build **greps the emitted bundle for `auth/status`** and fails loudly if the
  layout's `onMount` went missing. This smoke test is deliberately duplicated in
  `build.rs::verify_bundle` and in `build-web.sh` — change one, change the other.
- The CI pipeline runs it *again* as its own stage, after the build.

Three copies of one three-line check is not elegant. It is proportionate to a
failure mode that produces a correct-looking build and a blank app.

## CI/CD: a Pi 5 Builds, a Pi Zero Runs

I already run Jenkins for [custom ffmpeg
builds](/posts/transcoding-benchmark-amd-vs-m3/), so Tapedeck got a pipeline too —
and this one has a constraint I enjoyed.

The build agent is a **Raspberry Pi 5**. The deployment target is a **Raspberry Pi
Zero 2 W**. Both are aarch64, so the Pi 5-built binary runs on the Pi Zero — with
one condition worth writing into a comment at the top of the pipeline script:
*the Pi 5's glibc must be ≤ the Pi Zero's*. Cross-compilation without a
cross-compiler, held together by a version inequality.

Because the SvelteKit UI is baked into the binary, **the only deploy artefact is
the binary**. The whole deploy stage is: `scp` it over as `tapedeck.new`, `chmod`,
`mv -f` for an atomic swap, `systemctl --user restart`, sleep 3, `is-active`.

Two small operational gotchas that took a while:

- Jenkins sets `$HOME` to the workspace mount on this agent, not the user's home,
  so `rustup` and `bun` (installed under the real home) aren't on `PATH`. Every
  step is prefixed with a snippet that resolves the real home out of
  `/etc/passwd` and points `CARGO_HOME`/`RUSTUP_HOME` at it — which also means
  cargo reuses its existing caches rather than recompiling the dependency graph
  every build.
- `systemctl --user` over a non-login SSH needs `XDG_RUNTIME_DIR`, which only
  exists because `loginctl enable-linger` has been run for the deploy user. And
  the `$(id -u)` in the remote command has to be escaped, or it evaluates on the
  build agent instead of the target.

The pipeline is deliberately self-contained: it clones the Tapedeck source from
Codeberg itself as its first stage, rather than assuming a checked-out workspace.
That means it works pasted straight into the job's Pipeline script box, which is
in fact where it lives — **it is not committed to the repository**, and I go back
and forth on whether that is laziness or the right call. The argument for leaving
it out is that it hardcodes my LAN addresses, my agent label and my deploy user,
so as a file in a public repo it would be a template pretending to be
configuration. The argument against is that it is the only description anywhere of
how this thing actually gets built and deployed, which is why it is described
here. From that one script it runs `cargo test --locked`, the bundle
verification, a release build, an optional SonarQube pass, the deploy, and
archives a SHA-tagged binary.

![Jenkins pipeline view](/images/tapedeck/jenkins-pipeline.png "Checkout → toolchain → test → verify bundle → build → SonarQube → deploy → archive. Sixty-minute timeout because the first build compiles every dependency; later ones are incremental.")

Total deploy time from push to a running service on the Pi Zero: a few minutes,
almost all of it `cargo build --release` on a Pi 5.

## The Pi Zero Was Optimism

Which brings me to the piece of this project I have most obviously got wrong, and
which I am about to spend money to fix.

I chose a Raspberry Pi Zero 2 W as the host because the whole design is a single
static binary against a local SQLite file, and I reasoned — correctly, as far as
it went — that this is not a demanding workload. Four cores, 512 MB of RAM,
negligible idle power, and a scrobbler is mostly asleep.

Then two things happened. First, I imported my **Spotify extended streaming
history**, which took the database from a few thousand listens to something
approaching complete: my listening back to **January 2023**, now around
**48,000 listens**. Second, four or five other people asked for accounts.

Neither of those is a large number in absolute terms. A 48,000-row SQLite table is
not a database problem; the per-listen latencies in the table further up this post
are all still true. But **512 MB is the constraint that bites**, and it bites in
the places you would predict if you thought about it for five minutes and which I
did not:

- The enrichment backfills walk the history. That is fine at 5,000 rows and
  visibly not fine at 48,000, on a core that also has to serve the UI.
- The analytics screens — the reports fold, the genre-map placement, the
  personality axes — are each *one pass over the whole history*. That was a
  deliberate design choice and I still think it is the right one, but "one pass"
  gets more expensive in exactly proportion to how much history you have.
- Every additional user multiplies the poll load. Staggered polling was built for
  precisely this and it helps, but staggering work does not reduce it.
- And the import itself: a large `.zip` of extended history is the single
  heaviest thing this application ever does, and it is the *first* thing a new
  user does.

So the instance is moving to a **Raspberry Pi 4B, 2 GB, on a 32 GB card**. Four
times the memory, a genuinely better core, same aarch64 architecture — which
means the Jenkins pipeline above needs exactly one line changed, the deploy host,
and the glibc inequality it depends on holds just as well. That is the payoff for
the single-binary constraint I have been going on about for nine thousand words:
migrating the entire application to different hardware is `scp`, a systemd unit,
and copying one SQLite file.

I want to be honest about what this admission is, though, because it is not really
a hardware story. **I sized the machine for the application I was building in
January and not for the one I would have in August.** The v0.7 Tapedeck was
comfortable on a Pi Zero. The v0.49 Tapedeck computes a taste trajectory over a
genre manifold. I did not misjudge the hardware; I misjudged how much the project
would grow, which is a much more common mistake and a much harder one to see
coming.

## What Isn't Done

A features list that only lists features is marketing. Here is the honest state.

**Known gaps — things that look finished and aren't:**

- **Artist portraits from Navidrome aren't wired.** Plex and Jellyfin are.
  Subsonic can answer the question, but an untested path that silently returns
  nothing is worse than a stated gap.
- **Audio quality is only known for listens a live source reported.** Discussed
  above; on a real imported history that is the overwhelming majority of it, and
  every affected readout says so.
- **Entity pages don't scope by user.** Discussed above; parked as a design call.
- **The SACD layer isn't recorded.** Stereo and multichannel are genuinely
  different listens, `AudioQuality.channels` has somewhere to put it, and
  `physical_plays` has no column for which one you played.

**Next, roughly in order:**

- **A Roon source.** This is the immediate next piece of work, and it is the most
  obviously correct one on the list. Roon is where the audiophile end of this
  hobby actually lives; it already models the signal chain properly, it knows
  what its endpoints are and what format is reaching them, and it exposes an API
  to ask. Every other source I have integrated makes me infer the delivery chain
  from fragments. Roon can simply be asked — which makes it, for the specific
  thesis this whole application exists to serve, the highest-fidelity source
  available anywhere.
- **Polish, and a great deal of quality-of-life.** Less quotable than a new
  source and more valuable than one. Thirty-one releases in four days leaves a
  wake: four analytics screens that answer overlapping questions with four
  independent period controls, empty states that were never designed, edit flows
  that work but take a click too many, and a general need to go back over every
  feature already built and get it from *working* to *right*. Given the growth
  described in the section above, some of that is now performance work rather
  than cosmetics. I would rather ship one excellent version of what exists than
  the next three items on this list.
- **A Navidrome plugin**, which is not mine — a friend is building it against
  Tapedeck's ingest API. It is the first time anyone else has written software
  that targets this thing, and it has already been useful in a way I did not
  anticipate: writing a client against your own API is the fastest possible way
  to discover which parts of it are hostile. The gap it depends on is recorded
  and open — letting a pushed listen *claim a library item*, so that the artwork
  proxy can serve the cover of the exact file that was played rather than
  something an external provider guessed at.
- **Network streamers** — one discovery-and-negotiation layer over SSDP/UPnP
  AVTransport, OpenHome, Google Cast and vendor HTTP APIs, so that a streamer
  works because open protocols are supported rather than because somebody wrote a
  driver for that exact box. Each source declares its own blind spots: UPnP cannot
  see Spotify Connect or AirPlay, and the UI has to say so. MPRIS belongs in this
  bucket too and is by far the cheapest of the lot on Linux.
- **An Android app** — history, barcode scanning onto the shelf, and optional
  scrobbling. `AudioDeviceInfo` is the one thing only Android can contribute: USB
  DAC vs. Bluetooth vs. speaker, straight onto the chain ladder's device rung.
- **A Spotify source.** Note the trap already recorded: its history endpoint
  reports when a track *ended*, while every timestamp in Tapedeck is
  start-of-play, so the duration has to be subtracted on read.
- **Docker**, notes full-text search and tags, and sharing a report chapter as an
  image.
- **Natural-language questions over your own history.** *When did I start liking
  jazz? Which DAC do I use most for classical? What have I not played since I got
  the HD 650s?* These are questions the database can already answer and the UI
  cannot ask, and they are the clearest case in the whole project for a language
  model earning its place — which is why the pipeline matters more than the
  model: **analytics → candidate selection → explanation**. The database chooses
  the rows; the model explains the rows it was given. Any design that lets a
  model *invent* a listening fact is wrong on its face, because the entire value
  of this application is that its record is true. A plausible sentence about an
  album I never played is worse than no feature.
- **Social — "Patch"** — following other people on the instance, patching into
  someone else's deck. This is where the "journal with a social element" framing
  has to be taken literally: the feature ships late, but it was **designed in from
  the schema up**, not deferred to be bolted on. Stable actor URIs, follow state,
  an activity log shape, visibility as an enum, `sessions.uuid`,
  `notes.visibility` — all of those exist in the database *now*, precisely so that
  postponing the feature costs nothing. Every liner note already carries a
  visibility it does not yet need.
- **ActivityPub**, last, and gated on a genuinely unsettled question:
  **ActivityStreams has no verb for "listened to a track"**. That vocabulary has
  to be decided before the social schema freezes, and guessing at it now would be
  the one deferral that turns out expensive.

**And the one I most want to build, which is nowhere near next:**

The original design document has a **listening timeline** in it — monthly and
yearly chapters, milestones (your thousandth album, a new pair of headphones, a
streak), an equipment history running alongside, "this day in music", taste
evolution as a single narrative. Reports are the closest thing built so far and
they are not it: a report is a chapter, and the timeline is the book.

That feature is the "autobiography" framing made literal, and it is probably the
highest-value unbuilt thing in the document. It is also the one that most needs
the rest to be finished first, because a timeline is only as good as the data
underneath it — which is precisely the argument for spending the next stretch on
polish rather than on another source.

Adjacent and equally unbuilt: proper **equipment analytics**. Chain hours and
stylus hours are derived already, and "never heard on this pair of headphones"
proved the chain→component join works. But pad wear, tube hours, cartridge
tracking, genre-by-equipment and sample-rate usage all need a *per-component*
clock rather than a per-chain one, which is a schema change rather than a query.

The rule underneath all of the above: deferring a *feature* is cheap, and
retrofitting stable identifiers onto rows another instance already holds is not.
So anything social, federated or timeline-shaped gets its schema decided early
and its implementation whenever it gets there.

## On the Codebase Itself, Honestly

Some numbers and some debt, because I would want them if I were reading this
about someone else's project.

`db.rs` is past 5,000 lines and holds every query in the application. The
architecture sketch in my own design doc has a tidy
`HTTP → Services → Repositories → Storage` layering with an internal event bus.
Tapedeck is `HTTP handlers → Database → SQLite`, flat.

I am not defending that as ideal, but I will defend not having refactored it yet.
The flat shape is what makes a query readable end-to-end and keeps
`skipped = FALSE` and per-user scoping **auditable in one file** — which, given
that I have written that skip filter wrong three times, is not a small property.
And the rule I have written down for myself is: *don't begin a layering refactor
as a side effect of building a feature.* If it happens it should be its own
deliberate piece of work, and the first honest step is splitting `db.rs` by domain
rather than introducing traits.

The test suite is unit-level — pure functions (side splitting, artist matching,
session state machines) plus a few `sqlx` tests against a temp database. **There
are no HTTP-layer tests.** Handlers and anything touching a remote service are
verified by running the binary and hitting it with `curl`, which is worth doing
rather than skipping. Where a remote API's shape matters, I pin it against a
*real captured response*, because several of this codebase's worst bugs were
field-name mismatches that compiled perfectly and silently produced `None`
forever.

The OpenAPI spec is hand-written rather than derived with `utoipa`, and that was a
measured call rather than laziness: 126 handlers return `impl IntoResponse`, 278
response bodies are built with `serde_json::json!`, and there are exactly 5 named
`Serialize` response structs. `utoipa` derives schemas from typed structs; with
five of them it degenerates into the same YAML inside a macro DSL, scattered
across 126 handlers. Typed response structs are recorded as **known debt**, and if
they ever land, `utoipa` gets revisited.

## Try It

### On my instance, right now

Before you clone anything: there is a **live instance with a trial account on it**,
so you can click around the real thing rather than take my word for the
screenshots.

{{< notice note >}}

**[tapedeck.insightsintoinfinite.com](https://tapedeck.insightsintoinfinite.com/)**

Username: `trialUser`
Password: `Password123##`

{{< /notice >}}

Four things worth knowing before you go, all of which follow from what this
account actually is:

- **It is a shared account.** Everyone reading this post logs into the same user.
  Whatever you edit, love, annotate or delete, the next visitor sees — and if the
  history looks strange, that is because someone got there before you. Treat it as
  a public sandbox, because that is exactly what it is.
- **Do not paste real credentials into it.** Settings has connection forms for
  Last.fm, ListenBrainz, Plex, Jellyfin and Navidrome. They work. A token entered
  into a shared account is a token you have given to strangers, and Tapedeck's
  at-rest encryption is not the relevant threat model here — anyone logged in as
  `trialUser` simply *is* that user. There is nothing to connect to prove the app
  works; the history is already there.
- **It is slow, and you now know why.** This is the Pi Zero 2 W from a few
  sections ago, carrying 48,000 listens it was never sized for. The analytics
  screens in particular will make you wait. That is an honest demonstration of
  the problem rather than a hidden one, and it should be fixed by the time most
  people read this.
- **It is temporary.** The account goes away when it becomes a nuisance, or when
  the instance moves to the Pi 4B, whichever comes first. If the login stops
  working, that is why.

Start on the Dashboard, then Statistics and the Genre Map for the analytics
argument, and the Shelf for the part I care most about.

### On your own machine

```bash
git clone https://codeberg.org/abksh/tapedeck.git
cd tapedeck
cargo build --release
./target/release/tapedeck
```

You need a Rust toolchain (1.75+) and [Bun](https://bun.sh); everything else is
optional. On first run there is nothing to copy out of the console — Tapedeck
creates an admin row with no password and waits for you to open the web UI, which
redirects you to `/setup` to name the account and set a password. No config files,
no console token hunting.

Almost nothing is configured in files at all. Scrobble connections and media
sources are per user and live in the UI. What remains in `.env` or
`tapedeck.toml` is infrastructure that has to exist before the UI can be served:
port, database path, log level, MusicBrainz user agent, and the optional
credential-encryption key.

A sample hardened `systemd` unit is in `deploy/`. The Jenkins pipeline described
above is not in the repo — it is full of my own addresses — but the deploy stage
is four lines of `scp` and `systemctl --user`, and it is quoted in full in that
section if you want to lift it.

On hardware: a Pi Zero 2 W will run this happily for one user with a few thousand
listens, and — per the section above — will not keep up with a large imported
history or a household. If you are starting with a Spotify export in hand, begin
at a Pi 4B with 2 GB and save yourself the migration.

The repository is about 69% Rust, 26% Svelte and 4% TypeScript, which is roughly
the ratio I expected and slightly more frontend than I would like to admit to.

### Licence

Tapedeck is **AGPL-3.0**, and for once the licence choice was not agonised over,
because the AGPL's distinguishing clause is written for precisely this kind of
software. The GPL's obligations trigger on *distribution*; a self-hosted network
service is the classic way to use somebody's copyleft work without ever
distributing anything. Tapedeck is a thing you run on a server and reach over
HTTP. If someone takes it, improves it, and offers it to other people as a hosted
service, I would like those improvements to come back — and the AGPL is the only
standard licence that says so.

Issues and patches welcome on Codeberg. Be warned that the README alone is a
thousand lines, and the project notes file behind it is three times that — I write
these things down as I go, and it turns out that is most of what this post is
made of.

## Closing: an Autobiography, Not a Leaderboard

The thing I did not anticipate when I started is how much of this project turned
out to be about **epistemics rather than software**.

Nearly every decision I have described here reduces to one of three questions.
*What population is this number actually about?* — the fidelity cards, the skip
filter, the percentile I refused to compute. *Did anyone observe this, or did we
infer it?* — the vinyl side split, the Rockbox timezone, the "already played"
button. *Is this quantity an observable or an artefact of my coordinate choice?* —
the t-SNE I didn't run, the persistent homology I didn't compute, the colour
blend I did in linear light.

Those are the same three questions I ask of a measurement in physics, and I did
not expect to spend seven months asking them about my own listening history. But
that is what happens when you decide that a piece of software is going to be a
*record* of something rather than a *display* of it. A dashboard can be
approximately right. A journal cannot, because you will still be reading it in ten
years and by then you will have forgotten which numbers were guesses.

Which is, in the end, the whole difference between this and a scrobbler. A
scrobbler is a counter, and a counter only has to be roughly right to be useful.
A journal is something you go back to — and the entries have to have been true
when they were written, because nobody is going to be around later to check.

The reels are turning. The Pi Zero has been up for weeks and is about to be
retired for something with room in it, which is the good kind of problem. Four
more people are waiting for accounts. And I now know, with some precision, how
many hours are on the HD 650s — which is a strange thing to have wanted, and a
very satisfying thing to have.

---

*Written on the M3 Pro, deployed from a Pi 5 to a Pi Zero 2 W, to the Cranberries'
*Treasure Box: The Complete Sessions 1991–1999* followed straight by Sinatra's *In
the Wee Small Hours* — four discs of Limerick jangle and then the loneliest record
ever mastered, back to back, which is the sort of thing a listening history is
for. Both are now in the database with their chain attached.*
