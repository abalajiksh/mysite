+++
title = 'Mastering Is the Damage, the Codec Is the Alibi'
date = '2026-07-02T09:30:00+02:00'
draft = false
useAlpine = false
tags = [
    "audio-quality",
    "dynamic-range",
    "loudness-war",
    "null-test",
    "dsp",
    "bluetooth-audio",
    "sbc",
    "aptx",
    "aac",
    "pedalboard",
    "ffmpeg",
    "daft-punk",
    "signal-processing"
]
+++

*A null-test follow-up to [The Sausage Waveform Epidemic](https://ashwinbalaji.xyz/posts/sausage-waveform-epidemic/), in which I set out to prove my own thesis with numbers, and the numbers had other plans.*

## The Hypothesis

In the previous article, I argued that modern masters are compressed and limited into "codec-safe" sausages — and that this is why new albums sound the same on AirPods and on a proper wired chain. The claim hiding inside that argument is testable: **a heavily compressed master should lose less to a lossy Bluetooth codec than a dynamic master does**, because the mastering already destroyed the fine detail the codec would have thrown away. Less to destroy, less destroyed. In exchange, the crushing kills micro-dynamics and, so the folklore goes, the codec smears the soundstage on top.

Before touching a single sample, it is worth remembering how old this war actually is. Greg Milner's *Perfecting Sound Forever*[^1] — the best aural history of recorded music I know of — treats the loudness war as a central theme, and traces its modern front not to streaming, not to Bluetooth, not even to CDs, but to a New York FM radio feud in the early 1980s: Z-100 and WPLJ, two stations cranking broadcast processors at each other in a battle to simply *be louder* on the dial. Milner also names the psychoacoustic engine that has powered every escalation since: play people the same music at two different volumes and they will nearly always call the louder one better, because at higher levels the equal-loudness contours flatten and more of the frequency spectrum becomes audible. Louder wins every A/B comparison and loses every album. The war predates the codecs I am about to blame by a quarter of a century — which, in retrospect, should have been my first hint about how this experiment would end.

Prose is cheap. I have `ffmpeg`, a Python interpreter, and a weekend. Time to measure.

## The Test Track

I needed one track with genuine dynamic range, so that *I* could be the one to destroy it — under controlled conditions. Comparing an old dynamic album against a different modern loud album proves nothing; the music differs, the mastering differs, everything differs. The clean experiment is: one track, three masters, made by me, differing only in how hard the compressor and limiter worked.

The source is *Horizon (Ouverture)* from the 10th Anniversary Edition of Daft Punk's *Random Access Memories* — my own CD rip, 16-bit/44.1 kHz. If you read the previous article, you know why this album: it is the million-dollar rebellion against the loudness war, one of the most dynamic mainstream releases of the century[^2]. And using a CD rip is not a compromise; it is the point. CD quality was always enough. We are about to do violence to a Red Book file and measure precisely how much.

There is a pleasing symmetry in the choice, too. *RAM* was mastered by Bob Ludwig — the man to whom Daft Punk's engineer hand-delivered the tapes by car to Portland, Maine. The very same Bob Ludwig appears near the *beginning* of the loudness war's history: his famously hot 1969 master of *Led Zeppelin II* had to be recalled because it made turntable cartridges jump out of the groove. Vinyl physically refused excessive loudness; the medium itself pushed back. Digital media removed that physical veto — as Milner's history makes clear, the CD said yes to everything, and the war escalated accordingly. One mastering engineer's career bookends the entire story: from a master too hot for the medium to carry, to a number-one album that won the war by refusing to fight it. That is the file I am about to feed into a compressor.

First, the baseline measurements:

```bash
ffmpeg -i HorizonOverture_DaftPunk.wav -af ebur128=framelog=verbose -f null -
```

{{< notice note >}}
The rip measures **−17.1 LUFS** integrated with a loudness range (LRA) of **6.7 LU**[^3] — yet its crest factor (peak-to-RMS) is **18.6 dB**. These are different quantities and people conflate them constantly. LRA measures *macro*dynamics: how much the loudness wanders over the course of the track. Crest factor measures transient headroom: how far the peaks poke above the average. A steady orchestral build can have modest LRA and enormous crest. When someone says "dynamic range", ask which one they mean.
{{< /notice >}}

## Making Three Masters

The mastering chain is a bus compressor into a lookahead limiter — the standard recipe — implemented in Python with Spotify's `pedalboard`[^4] library, with the gain into the limiter iterated until the integrated loudness hits a target.

A small detour for the Linux people: my plan was to use the LSP plugins via LV2, since that is what I would reach for in Reaper on Fedora. It turns out `pedalboard` does not host LV2 at all — VST3 and Audio Units only. And LSP[^5] offers no official macOS binaries either; building it from source was more yak than I was willing to shave for a weekend experiment. So the numbers you are about to see come from pedalboard's built-in `Compressor` and `Limiter`. The script still probes for an LSP VST3 bundle first and falls back gracefully, so the Fedora rerun of this experiment can use the real thing — same convergence loop either way, so the masters remain comparable.

The two processed masters, designed to imitate real mastering decisions rather than a caricature:

| master   | target  | compressor                          | character                              |
|----------|---------|-------------------------------------|----------------------------------------|
| moderate | −11 LUFS | 2.5:1, −18 dB thr, 30 ms attack     | gentle bus glue, limiter barely working |
| crushed  | −7 LUFS  | 4:1, −24 dB thr, 10 ms attack       | ~10 dB of gain shoved into the limiter  |

The core of the loop:

```python
for i in range(8):
    board = Pedalboard([compressor, Gain(gain_db),
                        Limiter(threshold_db=-1.0)])
    out = board(audio, sr)
    lufs = meter.integrated_loudness(out.T)
    err = target_lufs - lufs
    if abs(err) < 0.2:
        break
    gain_db += err
```

And what came out:

| master   | LUFS-I | crest factor | DR (TT) | median 400 ms window crest |
|----------|--------|--------------|---------|-----------------------------|
| orig     | −17.1  | 18.6 dB      | 12      | 11.0 dB                     |
| moderate | −10.8  | 13.7 dB      | 9       | 10.9 dB                     |
| crushed  | −7.2   | 10.1 dB      | 6       | 10.3 dB                     |

The DR column deserves a moment of appreciation. I picked the LUFS targets hoping to land "somewhere around DR9" and "somewhere around DR6" — and Crete[^6], my own DR meter built on an ffmpeg-compact backend, reads the three masters as exactly DR 12, DR 9 and DR 6. The untouched rip scoring DR 12 also independently confirms what the Dynamic Range Database says about this edition. When your guesses land on the nose like that, you check twice; I checked twice.

![Same track, three masters](/images/plot_waveforms.png)

There is the sausage progression from the previous article, manufactured to order. Notice how the quiet opening of the overture — those first twenty seconds where the orchestra is barely breathing — gets pulled up until it is as thick as everything else. Keep an eye on that third column of the table, though. It is going to matter later.

## The Codec Gauntlet

Each of the three masters went through six encode–decode round-trips, covering the Bluetooth codecs people actually use and the operating points they actually get:

| tag     | codec           | rate      | represents                                    |
|---------|-----------------|-----------|-----------------------------------------------|
| sbc328  | SBC, bitpool 53 | ~328 kbps | A2DP high-quality, a good day                 |
| sbc229  | SBC, bitpool ~35| ~229 kbps | the common fallback, a congested train        |
| aptx    | aptX            | ~352 kbps | fixed 4:1 ADPCM, no bitrate knob to turn      |
| aptxhd  | aptX HD         | ~576 kbps | same scheme, ~2 more bits per subband sample  |
| aac256  | AAC (AudioToolbox) | 256 kbps | the Apple Music delivery rate              |
| aac160  | AAC (AudioToolbox) | 160 kbps | typical AAC-over-Bluetooth on Android      |

Two implementation details I enjoyed. First, `ffmpeg` encodes *and* decodes SBC and aptX natively, so the entire Bluetooth leg is a file pipeline — no actual radio required. Second, on macOS the `aac_at` encoder is Apple's own AudioToolbox AAC, the closest thing to the actual AirPods-era encode chain you can run from a command line:

```bash
# SBC there and back
ffmpeg -i master_X.wav -c:a sbc -b:a 328k enc.sbc
ffmpeg -i enc.sbc -c:a pcm_f32le decoded.wav

# aptX: the raw stream is headerless, the decoder must be told what it is
ffmpeg -i master_X.wav -c:a aptx -f aptx enc.aptx
ffmpeg -f aptx -ar 44100 -ac 2 -i enc.aptx -c:a pcm_f32le decoded.wav

# AAC through Apple's own encoder
ffmpeg -i master_X.wav -c:a aac_at -b:a 256k enc.m4a
ffmpeg -i enc.m4a -c:a pcm_f32le decoded.wav
```

## The Null Test

The measurement is old-school and merciless: time-align the decoded file against its pre-codec master, subtract, and what remains — the residual — *is* the codec's damage. No opinions, no golden ears, just arithmetic.

Alignment matters because every codec has its own fixed latency. Rather than hardcoding offsets, the analysis script cross-correlates each decoded file against its master and trims to the lag peak. The measured lags double as a sanity check: SBC came back at +73 samples, aptX and aptX HD at +90, and AAC at... zero. That zero worried me for a minute — AAC has a priming delay of thousands of samples — until I realized `aac_at` writes proper edit-list metadata and `ffmpeg` honours it on decode, trimming the priming automatically. The headerless SBC and aptX streams get no such courtesy.

From the aligned pairs, the script computes residual RMS relative to the signal — overall, per channel, and split into Mid (L+R) and Side (L−R) — plus a per-⅓-octave-band residual spectrum and a short-window crest-factor track. Everything lands in a CSV[^7].

## The Results, or: My Hypothesis Meets Reality

Here is the headline table — residual level relative to signal, Mid channel, in dB (more negative = less damage):

| codec   | orig   | moderate | crushed |
|---------|--------|----------|---------|
| sbc328  | −44.6  | −44.1    | −44.5   |
| sbc229  | −36.5  | −36.4    | −36.7   |
| aptx    | −44.7  | −44.5    | −44.5   |
| aptxhd  | −56.9  | −56.7    | −56.7   |
| aac256  | −34.8  | −33.5    | −31.9   |
| aac160  | −28.7  | −28.0    | −26.9   |

Read the rows. For SBC and aptX, the numbers are flat across all three masters — identical to within measurement wiggle, at *both* SBC operating points. The crushing changed nothing. My hypothesis predicted these rows should improve left to right, and they simply refuse.

In hindsight, they were always going to refuse, and I should have seen it coming. SBC and aptX are *waveform* codecs — fixed-rate subband and ADPCM quantizers. Their error is proportional to the signal: constant signal-to-noise ratio, by construction. They do not know or care what a limiter did to the file. Feeding a quantizer a louder signal gets you proportionally louder quantization noise, and the ratio — which is what the table shows — never moves. Crete agrees from a completely different angle: running the DR meter over all 21 decoded files returns DR 12, 9 and 6 down the columns — every file inherits its master's DR untouched, no matter which codec it survived.

Then look at the AAC rows. They are not flat. They get *worse* left to right — the crushed master loses 2–3 dB of relative fidelity compared to the dynamic one, at both bitrates. The one codec in the matrix with a psychoacoustic model shows real master-dependence, and it runs **backwards** from my prediction. A brick-walled master is spectrally dense and loud *everywhere, all the time*: less masking headroom for the model to hide error in, fewer bits per unit of detail. Crushing does not protect music from AAC. It actively antagonizes it.

{{< notice note >}}
A gift for the physicists: aptX HD improves on aptX by 12.2 dB in this data. aptX HD spends roughly 2 extra bits per subband sample, and the textbook quantization-SNR rule says 6.02 dB per bit — predicting 12.0 dB. The measurement lands within a fifth of a decibel of ideal-quantizer theory. The codecs are behaving like the textbook says they must, which is exactly why the hypothesis never stood a chance.
{{< /notice >}}

## A Bonus Casualty: True Peak

While running Crete over the full file set, a third mechanism fell out of the Max. True Peak column — one I had not even planned to measure.

| master   | source (dBTP) | after sbc328 | after aac256 | after aac160 |
|----------|---------------|--------------|--------------|--------------|
| orig     | −1.76         | −1.76        | −1.75        | −1.77        |
| moderate | −0.22         | −0.24        | −0.21        | −0.28        |
| crushed  | **+0.16**     | +0.14        | **+0.28**    | **+0.47**    |

The crushed master already sits at **+0.16 dBTP** straight out of the mastering chain: the limiter holds *sample* peaks at the ceiling, but the reconstructed analog waveform swings between the samples — intersample peaks, exactly as real brick-walled commercial masters exhibit. Feed that zero-headroom file to a lossy codec and the imperfect reconstruction overshoots further: **+0.47 dBTP** after AAC at 160 kbps. Anything downstream that is not floating-point — a DAC's interpolation filter, a fixed-point DSP stage in a pair of earbuds — will clip those overshoots into audible distortion. The dynamic master, cruising along at −1.8 dBTP, never gets anywhere near full scale no matter what is done to it.

This is precisely why mastering guidelines recommend leaving about 1 dB of true-peak headroom for lossy delivery. It is also the third independent way this experiment found crushing to *create* codec damage rather than prevent it: less masking headroom, fewer bits per detail, and now decode-side clipping. (Crete even reads the AAC-decoded crushed files as DR 7 rather than 6 — the codec's overshoot and noise nudging the meter upward. The only "dynamics" the codec added were the wrong kind.)

## The Soundstage Acquittal

The second half of the folklore: Bluetooth smears the stereo image. SBC uses joint stereo, and at starved bitpools it should rob the Side channel to feed the Mid. So the residuals should be dramatically worse in Side than Mid — especially at bitpool 35.

![Mid vs Side residuals across the full matrix](/images/plot_ms_degradation.png)

The Mid/Side gap is about 1 dB. Everywhere. Including — and this is the part that settles it — for **aptX**, which codes left and right as two independent mono channels. aptX never computes a Side channel and therefore *cannot* starve one. If a codec that is structurally incapable of joint-stereo damage shows the same 1 dB gap as SBC, then the gap is a property of this track's stereo content, not of any codec's behaviour.

So on this evidence, the soundstage-smearing claim from my previous article is **not supported** at any operating point I tested. It costs me something to type that, since I wrote several confident paragraphs about smeared stereo images not four months ago. Two honest caveats before the acquittal is final: a file round-trip cannot capture what a real congested radio link does — packet loss and the decoder's concealment guesses are a different beast entirely — and one track is not a survey. But the clean-link, correct-decode case is exonerated.

## Micro-Dynamics: Where I Was Wrong Twice

I expected the short-window crest plot to be the most brutal figure in the post — the crushed trace pinned flat while the original breathes.

![Short-window crest factor over time for the three masters](/images/plot_microdynamics.png)

Reality is subtler, and it took me a while to make peace with it. The crushed trace rides systematically lower, yes — but only by 1–2 dB, and the tallest transients still punch through to 17–19 dB. Look back at the master table: global crest fell by 8.45 dB, but the *median window* crest fell by only 0.78 dB. How can both be true?

Because global crest factor is peak-over-whole-track-RMS. The loudness push raised the RMS by 10 dB while the limiter held the peaks at the ceiling — so global crest collapses almost by definition, driven by the loudness push, not by wholesale transient annihilation inside every 400 ms window. On this track, with this chain, "crushing" mostly means the quiet passages were dragged up to sit shoulder-to-shoulder with the loud ones (look at the waveform figure again — the opening bars) and the local texture was shaved, not shattered. The damage is death by a thousand cuts, not decapitation.

And the codecs? The worst codec-induced change in short-window crest across the entire eighteen-cell matrix is **0.107 dB**. The mastering chain moved the global figure by **8.45 dB**. The limiter did roughly eighty times more dynamic damage than the most destructive Bluetooth codec in the chain — and, in a final small irony, every codec softened the *crushed* master slightly more than the original, not less.

## Where the Numbers Stop Being the Whole Truth

Time for the ritual confession: residual RMS is not audibility, and I am not going to pretend otherwise.

![Residual-to-signal ratio per third-octave band](/images/plot_residual_spectrum.png)

By raw residual RMS, AAC at 256 kbps is the *worst* codec in this test — 10 dB more residual than lowly SBC. By every published listening test in existence, it is perceptually the best of them. The spectrum plot shows why the RMS number lies: AAC's error is psychoacoustically shaped, tucked under the signal where masking hides it, and a healthy chunk of its residual energy is a high-frequency roll-off that a self-described half-deaf physicist was never going to hear anyway. aptX's error, by contrast, is honest broadband quantization noise — lower RMS, but unshaped and unhidden. Two rigorous measurements of "damage" that rank the codecs in opposite orders, and the resolution is that one of them was never designed to minimize the number I measured. Choosing the right observable before measuring — where have I heard that before?

(The spikes below ~30 Hz in that plot are an artifact, not a finding: those bands contain essentially no signal energy, so the ratio is meaningless there.)

Quantifying audibility properly needs a perceptual metric — ViSQOL[^8], roughly the VMAF of audio — and that is parked as the follow-up, pending a Bazel build that does not fight my toolchain. Add the other caveats to the pile: one track, one genre, a clean file pipeline instead of a lossy radio link, and my ears deliberately kept out of the methodology.

## Conclusion

I built the tools to prove that mastering compression protects music from Bluetooth codecs at the cost of its soul, and the null tests dismantled the claim piece by piece. The waveform codecs are indifferent to mastering — constant-SNR quantizers, exactly as the textbook demands. The one perceptual codec punishes crushing rather than rewarding it. The crushed master's zero headroom turns lossy decoding into true-peak clipping the dynamic master never suffers. The soundstage smearing I blamed on Bluetooth did not occur at any operating point, on the testimony of a codec that cannot commit the crime. And the dynamics damage everyone attributes to the transmission chain is measured in tenths of a decibel, while the mastering chain's damage is measured in whole ones — done permanently, before any codec ever touches the file.

The previous article said mastering is the content and the format is the container. This one sharpens it: the destruction we hear in modern releases was never the codec's doing. **Mastering is the damage. The codec is the alibi.** The sausage was cooked long before Bluetooth got the blame — and I had to be wrong about half of my own thesis to find out which half was right.

Milner's history says the same thing from the other direction. The loudness war was already self-defeating on FM radio in 1983, already crushing masters in the CD era, already condemned by the very engineers waging it — all of it decades before a single SBC frame ever crossed a Bluetooth link. My weekend of null tests adds one small quantitative footnote to his four-hundred-page argument: the causality only ever ran one way. We did this to the music ourselves, with a compressor and a limiter and a market that rewards the louder A/B — and then, when it sounded flat everywhere, we blamed the radio in our earbuds.

[^1]: Greg Milner, *Perfecting Sound Forever: An Aural History of Recorded Music*, Faber & Faber, 2009. The loudness war is a central theme; the Z-100/WPLJ radio war and the louder-always-wins-the-A/B observation are recounted there. If you enjoy this blog's audio articles, read this book.

[^2]: The [Unofficial Dynamic Range Database](https://dr.loudness-war.info/) tracks DR scores per release; the *RAM* editions consistently sit in DR12–13 territory, extraordinary for a chart-topping release.

[^3]: LUFS, LU and LRA are defined in [EBU R 128](https://tech.ebu.ch/publications/r128); the measurements here come from ffmpeg's `ebur128` filter.

[^4]: [pedalboard — Spotify's audio effects library for Python](https://github.com/spotify/pedalboard). The full mastering, transcoding and analysis scripts, plus the README with the complete findings, live in the [complimit_demo repository](https://github.com/abalajiksh/complimit_demo).

[^5]: [LSP (Linux Studio Plugins)](https://lsp-plug.in/) — excellent and Linux-native; macOS means building from source yourself.

[^6]: [Crete](https://github.com/abalajiksh/Crete) — my DR meter project built on an ffmpeg-compact backend, reporting TT-style DR (PMF), true peak, PLR, PSR and friends per file.

[^7]: Full `results.csv` with per-channel residuals, LUFS, crest factors and window-crest softening for all 18 master–codec pairs is in the [repository](https://github.com/abalajiksh/complimit_demo).

[^8]: [ViSQOL](https://github.com/google/visqol) — Google's open-source full-reference perceptual quality metric, outputting MOS-LQO on a 1–5 scale.
