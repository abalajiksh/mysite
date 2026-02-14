+++
title = 'The Sausage Waveform Epidemic: How Apple Killed the Headphone Jack and the Music Industry Followed'
date = '2026-02-13T13:18:02+01:00'
draft = false
useAlpine = false
loadNerdFont = false
tags = [
    "audio-quality",
    "dynamic-range",
    "loudness-war",
    "codec-safe-mastering",
    "lossy-vs-lossless",
    "cd-quality",
    "bluetooth-audio",
    "airpods",
    "streaming-platforms",
    "loudness-normalisation",
    "audiophile",
    "ilaiyaraaja",
    "hilary-hahn",
    "music-industry"
]

+++
*On rediscovering dynamic range, the tragedy of codec-safe mastering, and why Hilary Hahn's Chaconne sounds glorious at 16-bit/44.1kHz*

I recently upgraded my listening setup. A Schiit Mimir multibit DAC, a Midgaard amplifier, and a pair of Sennheiser HD 650s — connected with XLR, playing local FLAC files on a Fedora Linux desktop. No streaming service in the chain. No Bluetooth. No codec deciding what I'm allowed to hear.

The first thing I did was revisit albums I'd been listening to for years — Ilaiyaraaja's synth-laden Tamil film scores from the 1980s, Hilary Hahn's recording of Bach's Chaconne, some Radiohead, some Evanescence, Michael Jackson's later work. Music I thought I knew intimately.

I didn't know it at all.

## The Revelation That Shouldn't Have Been One

Old albums sounded *dramatically* different through this setup compared to streaming. Ilaiyaraaja's Roland and Korg synthesiser pads, which I'd always heard as pleasant background textures, suddenly had room to breathe. Reverb tails decayed naturally into silence — actual silence, not the faint noise floor of a Bluetooth codec. Transients from tabla and percussion had a snap and physicality to them that I'd never noticed. The stereo image opened up; instruments occupied distinct positions in space rather than being smeared into a vaguely wide blob.

Then I played Hilary Hahn's Chaconne. Fifteen minutes, one violin, no ornamentation to hide behind — just raw harmonic architecture and emotion. On the HD 650s through the Mimir, the rosin and wood of the instrument sat right in front of me, almost uncomfortably intimate. The dynamic range was enormous. When Hahn digs into the D minor gravity of those opening chords and then lets a phrase taper off into near-silence, you can hear every micro-gradation of that decay. The quiet passages emerge from a black background, and the loud passages have real force behind them.

Here's what stunned me: this was a CD-quality recording. 16-bit, 44.1 kHz. Red Book standard, designed in 1982. Not some exotic high-resolution format. Just properly mastered audio played through a competent signal chain.

So I got excited and started playing newer albums. Contemporary pop. Recent indie releases. Stuff from the last five or six years.

The difference between FLAC and streaming? Barely perceptible. Sometimes none at all.

## Why New Albums Sound the Same Everywhere

This puzzled me until I thought about it more carefully, and the explanation is both simple and depressing.

When Ilaiyaraaja's engineers recorded those 1980s sessions, the dynamic range was enormous by modern standards. Peaks might hit −3 dBFS, but the average loudness sat around −18 to −20 LUFS. Light compression on individual instruments during mixing, maybe, but the final master had headroom. The difference between the quietest reverb tail and the loudest percussive hit might span 15 to 20 dB. All of that information is faithfully preserved in a lossless file. When a lossy codec like AAC or OGG Vorbis encodes that same recording, it starts making decisions — discarding quiet detail, smearing the stereo image, softening transients. On a revealing system, you hear what was lost. There's *actual information* to lose.

Modern masters are a different story. The loudness war — that decades-long arms race to make every track louder than the next — has fundamentally changed what ends up in the file. A contemporary pop master is typically compressed to within an inch of its life, then slammed into a brick-wall limiter at −6 LUFS or louder. The waveform looks like a sausage: nearly flat on top, with quiet and loud sections sitting within 6 dB of each other instead of 15 to 20 dB. The limiter works constantly, clipping transients and destroying micro-dynamics.

When you encode that sausage into AAC, there's barely any dynamic information left to discard. The lossy codec and the lossless file converge perceptually — not because the codecs have gotten better, but because the mastering has pre-destroyed exactly the kind of detail that lossless formats exist to preserve.

But the problem goes deeper than just loudness. It's about *who the music is being mastered for*.


## Mastering for AirPods: The Codec-Safe Epidemic

The recording industry knows its audience. And its audience, overwhelmingly, listens on AirPods. Or Galaxy Buds. Or some other pair of true wireless Bluetooth earbuds connected to a phone that doesn't have a headphone jack.

This has changed the entire mastering workflow from the ground up. Engineers now routinely check their mixes on laptop speakers, cheap earbuds, and Bluetooth speakers alongside studio monitors. If a mix falls apart when a codec drops the stereo image or smears a transient, that's a problem — because it'll fall apart for 95% of the audience. So the master gets shaped to be "codec-safe" from the start. You lose the headroom that made older recordings bloom on good equipment. Delicate spatial information gets flattened because it won't survive Bluetooth SBC encoding anyway. Quiet passages get pulled up because they'd disappear in subway noise.

The result is music that sounds roughly the same on everything: good enough on AirPods, good enough on a car stereo, good enough streamed at 256 kbps AAC. And on a resolving system with proper amplification playing lossless files — still roughly the same. There's nothing left to reveal.

This is where I lay a significant portion of blame at Apple's feet.

## The 3.5 mm Removal and Its Downstream Consequences

In September 2016, Apple removed the 3.5 mm headphone jack from the iPhone 7. Phil Schiller stood on stage and called it "courage." The word has been correctly mocked ever since, but I don't think the full consequences of that decision have been properly reckoned with.

Apple didn't just remove a port. They restructured the incentive landscape of the entire music production chain.

Before the iPhone 7, the default way to listen to music on a phone was to plug in a pair of wired headphones. The analog signal path from the phone's internal DAC through a 3.5 mm jack to a decent pair of wired earbuds was simple, direct, and — with a competent headphone amplifier stage — perfectly capable of resolving well-mastered audio. No codec in the middle. No Bluetooth compression. No battery to degrade.

After the removal, the default shifted to wireless. Apple conveniently had AirPods ready to sell. Samsung followed. Then everyone else. Within a few product cycles, the headphone jack was gone from virtually every flagship phone. An entire generation of listeners adopted Bluetooth audio as their baseline, most of them never having experienced what they were losing.

This created a feedback loop. Consumers listen on Bluetooth. Labels and engineers know consumers listen on Bluetooth. Masters get optimised for Bluetooth playback. The masters sound the same on Bluetooth and on wired setups because the dynamic range has already been crushed. Consumers see no reason to use wired headphones because they can't hear a difference. The headphone jack disappears from more devices. The loop tightens.

The engineering facts make this loop inevitable. Bluetooth audio, even at its best with codecs like LDAC or aptX Adaptive, involves lossy compression. At its most common — the SBC and AAC codecs that AirPods and most true wireless buds use — the bitrate and psychoacoustic model simply cannot preserve the kind of spatial and dynamic information that a wired analog connection passes transparently. The technology has improved, but it is physically constrained by bandwidth and latency requirements that wired connections don't have.

Apple knew this. They sell a "Lossless" tier on Apple Music that cannot actually be transmitted losslessly to their own AirPods. The absurdity of this situation tells you everything about where their priorities lie: not with audio fidelity, but with selling wireless accessories and locking users into an ecosystem where the dongle is the answer to everything.

## The Bitter Irony of Lossless Streaming

Here's the cruel joke. The technology to deliver lossless audio to everyone finally exists. Apple Music offers it. Amazon Music offers it. Tidal pioneered it. Qobuz has been doing it for years. You can stream CD-quality or better to any device with an internet connection.

But the content being produced doesn't fully exploit it anymore. We have the pipes, and nothing worth pumping through them. The artists who do master with care — Nils Frahm, Floating Points, the engineers at ECM Records — are essentially optimising for the one or two percent of listeners who have the equipment and care enough to hear the difference.

Streaming platforms make this worse with loudness normalisation. Spotify normalises to −14 LUFS, YouTube to −13 LUFS. So the engineer's attempt to win the loudness war gets undone by the platform anyway — the track gets turned down to match everything else. But the dynamic range damage is permanent. The limiter already clipped those transients. The compressor already crushed those quiet passages. Normalisation adjusts the volume; it can't restore information that was thrown away at mastering.

The artists who master dynamically get penalised twice: their music sounds quieter on platforms that don't normalise (or where users have it disabled), and the dynamic range that makes their work special is only audible to listeners with proper playback chains.

## CD Quality Is Enough. It Was Always Enough.

One thing this experience has reinforced for me is that the high-resolution audio marketing push — 24-bit/96 kHz, 24-bit/192 kHz, MQA before its ignominious collapse — was largely solving the wrong problem.

Hilary Hahn's Chaconne sounds transcendent at 16-bit/44.1 kHz through a proper DAC and amplifier. Red Book CD quality gives you a theoretical dynamic range of 96 dB and a frequency ceiling of 22.05 kHz. Human hearing in ideal conditions tops out around 120 dB dynamic range and 20 kHz. For the vast, overwhelming majority of recordings and listening scenarios, CD quality captures everything that matters.

The problem was never the format. The problem is what happens to the music before it reaches the format. A beautifully mastered 16-bit file will always sound better than a dynamically crushed 24-bit file. Bit depth and sample rate are the container; mastering is the content.

The audiophile industry's focus on ever-higher resolution formats was, in hindsight, a distraction from the real issue: the masters themselves were getting worse. Selling people 24-bit files of a recording that was brick-wall-limited to −6 LUFS is like selling a 4K Blu-ray of a film that was shot out of focus. The extra resolution faithfully captures every detail of the damage.

## The Million-Dollar Rebellion

In 2013, Daft Punk spent over a million dollars and four years making *Random Access Memories* — an album that, by every rational industry metric, should not exist. They were two of the most successful electronic musicians alive, and they chose to abandon laptops entirely. They booked legendary studios — Henson, Conway, Capitol, Electric Lady — hired session musicians whose credits read like a history of American funk and disco, and recorded everything to Ampex analog tape running simultaneously alongside Pro Tools sessions. Thomas Bangalter described the late 1970s and early 1980s as "the zenith of a certain craftsmanship in sound recording." That wasn't nostalgia. It was a design specification.

The engineering was obsessive to the point of absurdity. They auditioned multiple units of the same compressor model — several 1176s, several LA-2As — because each individual piece of analog hardware sounds slightly different. They swapped a vintage Neve 33609 they'd spent a fortune reconditioning for the one that happened to live at Conway Studios, because it sounded better. Engineer Mick Guzauski tracked with minimal EQ, preferring to get the tone right at the microphone rather than fix it in the mix. Everything was mixed through a 72-input analog console at 96 kHz. When the final master tapes were ready, engineer Peter Franco drove them by car from Los Angeles to Bob Ludwig's mastering studio in Portland, Maine — because they refused to hand the tapes to a courier service or let them pass through airport scanners. As Franco put it, it would have been like handing over your own child.

The result? The vinyl pressing of *Random Access Memories* hits a dynamic range rating of DR13 — extraordinary for any modern release, let alone one that debuted at number one in over twenty countries. It won Album of the Year, Best Engineered Album, and proved that you don't need to slam your master into a limiter at −6 LUFS to achieve commercial success.

And here's the part that should haunt every label executive: *Get Lucky* became one of the best-selling digital singles of all time. An album recorded on analog tape, mixed through a vintage console, mastered with care for dynamic range, and driven across a continent by hand — outsold the sausage waveforms. The market didn't punish craft. It rewarded it. The industry just chose not to notice.
## What Gets Lost

I want to be specific about what we're losing, because it's easy to dismiss this as audiophile neurosis.

When Ilaiyaraaja layered Roland synth pads under a Tamil vocal line in 1986, those pads had a natural dynamic envelope. They swelled, they breathed, they decayed into the reverb of the room. On a properly mastered FLAC file through a resolving system, you hear all of that. You hear the synth as a *voice* — a musical entity with its own life and space in the mix.

When that same approach is applied to a modern recording that's been compressed and limited for codec-safe playback, the synth pad becomes a flat texture. It doesn't breathe because the compressor won't let it. It doesn't decay naturally because the limiter keeps everything at the same level. The spatial information is baked out because it wouldn't survive Bluetooth anyway. It's still there, technically, but it's been reduced from a living instrument to wallpaper.

Multiply that across every element of a mix — vocals, drums, strings, electronics — and you understand why old recordings can sound so revelatory on good equipment while new ones sound merely competent.

## The Maestro Who Said No

There's a man in Chennai who has been fighting this battle longer than most people have been aware there was one to fight.

Ilaiyaraaja — the composer behind over 7,500 songs across 1,500 Indian films, the man who treated Korg and Roland synthesisers as legitimate orchestral voices in the 1980s when most Western electronic musicians hadn't caught up — has spent the last decade in and out of the Madras High Court, waging a war over the rights to his own compositions. The details are complex: labels like Echo Recording and Sony Music acquired sound recording rights through chains of assignments dating back to agreements signed in the 1980s and 1990s, long before streaming existed. Ilaiyaraaja's position is that those contracts covered physical audio releases, not perpetual digital exploitation on platforms that didn't exist when the ink dried.

The courts have recognised his "special moral rights" over his compositions. He has sent legal notices to film productions that used his songs without permission. He has had films pulled from Netflix. He has been called greedy and selfish by people who don't understand what he's protecting.

But I think there's something deeper at work than just royalties and licensing. When Ilaiyaraaja's 1997 contracts expired, he didn't rush to get everything onto Spotify and call it a day. His insistence on controlling how his music is distributed — who plays it, where, in what context, under what terms — reads to me like the stance of a man who understands something about the relationship between a composition and its medium of delivery that the streaming industry refuses to acknowledge.

Those 1980s recordings were made with analog care. The synth pads breathe. The reverb tails decay into real silence. The stereo image is wide and intentional. Every instrument has its own space in the mix. This is music that was composed and recorded to be *heard* — not to be background noise compressed into a Bluetooth codec and piped through a pair of earbuds on a commuter train.

When a streaming platform takes that recording, encodes it to OGG Vorbis at 160 kbps, and serves it to someone wearing AirPods on the Tokyo Metro, something is lost that the composer never consented to losing. Ilaiyaraaja's refusal to hand over his life's work to an industry that will flatten it, compress it, and serve it as content is not stubbornness. It is the same instinct that makes a physicist refuse to publish a half-baked derivation just because the journal will accept it. Some things are worth more than their market-efficient form.

The tragedy is that the legal system frames this as a dispute about money and ownership. It is also, whether Ilaiyaraaja would articulate it this way or not, a dispute about dynamic range.

## The Minority Report

I'm under no illusions about my position in the market. The number of people who play local FLAC files through a dedicated DAC and headphone amplifier into 300-ohm open-back headphones is vanishingly small. The number of people who would even notice the differences I'm describing is small. The number of people who would care enough to change their listening habits is smaller still.

The market is rational. Apple removed the headphone jack because most people genuinely don't care about audio quality enough for it to affect their purchasing decisions. AirPods are convenient, they sound acceptable, they integrate seamlessly with the iPhone. For most people, that's the end of the analysis.

But "most people don't care" is not the same as "it doesn't matter." The dynamic range of a recording is not a preference or a luxury. It is *information*. It is the difference between a whisper and a shout, between tension and release, between a violin string vibrating freely and one being choked. When that information is destroyed at mastering — whether in service of the loudness war or in deference to the Bluetooth playback chain — it is gone permanently. No future technology will recover it from the file. No headphone upgrade will reveal what isn't there.

The technology to record, distribute, and play back music with extraordinary fidelity exists today and has existed for decades. The 16-bit/44.1 kHz Red Book standard from 1982 was, and remains, sufficient for capturing the full range of human musical expression. What we lack is not better formats or higher bit rates. What we lack is the market incentive to use what we already have.

Apple's "courage" in 2016 didn't just remove a port. It accelerated a cascade that changed how music is made, mastered, and experienced — overwhelmingly for the worse. And the saddest part is that most people will never know what they're missing, because they've never heard it any other way.

---

*Written on a Fedora Sway desktop, alternating between Hahn's Chaconne and Nils Frahm's All Melody in FLAC through a Schiit stack. The violin is right here in the room with me, every note has room to breathe — and Frahm's layers of synths and piano unfold with a spatial depth that streaming will never deliver.*
