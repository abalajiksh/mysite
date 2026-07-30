+++
date = '2026-07-30T19:15:00+02:00'
draft = false
title = 'libdsddpcm Meets Real Music: 44 GB of DSD, and the Yardstick I Had to Build First'
useAlpine = false
loadNerdFont = false
tags = [
    "dsd",
    "pcm",
    "sacd",
    "signal-processing",
    "decimation",
    "measurement",
    "filter-design",
    "ffmpeg",
    "foobar2000",
    "resampling",
    "methodology",
    "open-source"
]
series = "libdsddpcm"
+++

*On paying off the one warning notice in the last article, why measuring a decoder is harder than writing one, and how four separate measurement bugs each made a good decoder look bad — quietly.*

## The Warning Notice I Left Myself

The last article[^1] ended on an admission I did not enjoy writing:

{{< notice warning >}}
**I have not tested this on a single real DSD file.** There is no DSD material on this machine. Every number above comes from synthetic vectors, which are ground truth for *correctness* — but agreement with real material is a separate claim I have not yet earned.
{{< /notice >}}

That was honest and it was also load-bearing. The whole argument of libdsddpcm is that every DSD decoder ships coefficients and none of them ship evidence. Having built the evidence for my own filters against frozen synthetic vectors, I was standing on exactly one rung of the ladder. Synthetic vectors are ground truth. They are also *my* vectors, built by *my* modulator, measured through *my* oracle. A decoder that decodes my own test signals beautifully and mangles Pink Floyd would be a very sophisticated way of being wrong.

So: 44 GB of commercial DSD later, this article is that debt being paid. Eight albums, four DSD rates from DSD64 to DSD512, seven decoder configurations, and — as it turned out — a measurement harness that took considerably longer to get right than the library it was measuring.

That last part is the actual story here. The bake-off results are at the bottom of this page and they came out roughly as the synthetic work predicted. What I did not predict is that I would spend the bulk of the effort discovering four separate ways to produce plausible-looking wrong numbers, each of which failed *silently* and each of which made some decoder look worse than it is. If you take one thing from this article, take that section.

## The Corpus

What I could actually get hold of, in the rates I needed:

| rate | material |
|---|---|
| **DSD64** (2.8224 MHz) | Alan Parsons *I Robot*, Patricia Barber *Café Blue*, Pink Floyd *DSOTM*, Michael Jackson *Thriller* |
| **DSD128** (5.6448 MHz) | Boney M. *Nightflight To Venus*, *10 000 Lightyears* |
| **DSD256** (11.2896 MHz) | Eminem *Curtain Call* |
| **DSD512** (22.5792 MHz) | Sound Liaison *Jazz Music Sampler* |

For the headline tables: three tracks per rate, an 8-second excerpt taken 40 % into each track, left channel, decoded to 44.1 kHz float64 by every contender. Twelve excerpts, seven decoder configurations. For the conservative measurement further down: entire tracks, both channels, in windows — 24 track-channels and 708 windows.

{{< notice note >}}
Several of these titles are almost certainly DSD transfers of PCM masters, and the provenance of a commercial SACD rip is not something I can verify. **This does not affect the comparison at all.** Every decoder is handed the identical bitstream. What is being measured is what each decoder does to those bits, not whether the bits deserved a DSD container in the first place.
{{< /notice >}}

The contenders:

| decoder | chain |
|---|---|
| **libdsddpcm DEFAULT** | `fir1_8d/16m/32/64m` → `hb43_150` → `hb43_150` → `eq383` — the shipped C library, driven through its own ABI |
| **libdsddpcm LEASTSQUARES** | …final stage `firls767` |
| **libdsddpcm KAISER** | …final stage `kaiser4095` (the offline reference variant) |
| **libdsddpcm DIRECT** | single wide `fir1_64`, DSD64 only — a *different* design goal, see below |
| **dsd_lut.hpp (foobar)** | `foo_input_sacd`'s multistage converter, rebuilt exactly as `dsdpcm_converter_multistage.h` builds it, at the shipped fixed-point parity, with no unity-DC renormalisation |
| **ffmpeg (swr)** | the real `ffmpeg` 8.1.2 binary on this machine — `dsd.c` 96-tap ÷8 decode, then default swresample to 44.1 kHz |
| **ffmpeg (soxr)** | same, but `aresample=resampler=soxr` |

One correction to my own earlier work sits in that table. In the synthetic comparison I measured the foobar chain as `fir1_8 → fir2_2 → fir2_2 → fir3_2`. That is what the plugin builds for **88.2 kHz** output. For 44.1 kHz the decimation ratio is 64, which is greater than 32, so the shipped code takes the `fir1_16` branch instead. The numbers here use the real 44.1 kHz chain. It moves the incumbent's result by a few dB, and it is the kind of thing you only catch by reading the source rather than your own notes about the source.

## Two Releases That Happened Because the Corpus Arrived

The last article shipped against **v0.1.0**, and if you look at the chain in that table you will notice names that were not in it. Two things happened in the twelve hours between publishing that article and starting this measurement, and both were caused by the corpus rather than by any plan of mine.

**v0.2.0 — DSD512 input.** The corpus I had assembled contained DSD512 material. The library did not decode DSD512. That is an embarrassing sentence and it was also a five-hour fix, because the stage-1 family was already parameterised by rate: `fir1_64m` is a libdsddpcm-original constrained-least-squares stage-1 extending the `fir1_8/16/32` family exactly one further octave, N = 640, carrying the *same* ~156.6 kHz physical corner as every other member. One analog spec, now four rates. Quantized ×2³⁰ — the doubled length halves the tap magnitudes, so the two extra bits of headroom come for free — giving **−139.4 dB stopband** after int32 quantization against a −140.9 dB float design. Composite DSD512 → 44.1 kHz: worst fold **−139.7 dB**, passband flat to ±3×10⁻⁵ dB.

The API change is purely additive: one new enum value, `DSDDPCM_DSD512 = 512`, no ABI break, SONAME unchanged. Every existing coefficient table is byte-identical to v0.1.0, and the new one comes out of the same clean-room recipe pipeline with the design recorded next to the coefficients. `lut_verify.py` gained a DSD512 random-stream test; the C kernel matches an independent numpy reference decode to 2.8 × 10⁻¹⁶, which is float summation order and nothing else.

**v0.2.1 — the bottleneck the last article admitted to.** That article's honest list included this item: *`fir1_8` is now the composite bottleneck at ~141 dB. Deepening it to 150+ is provably possible — dsd2pcm's stage-1 gets 149.9 — and it is queued.*

It is no longer queued.

{{< notice info >}}
**`fir1_8d`** — a libdsddpcm-original CLS design superseding the incumbent-recipe `fir1_8` for the DSD64 multistage chain. Same physical corner, eight more taps (N = 88), stopband constraint deepened from −141 to **−160 dB** and met exactly in float; quantized ×2³⁰ it delivers **−157.4 dB in the alias fold bands**.

Composite worst fold-band attenuation, DSD64 → 44.1 kHz: **138.9 → 149.7 dB.** Stage 1 no longer caps the chain. The 26 kHz fold spur — the audible-aliasing criterion, aliasing to 18.1 kHz — improves to **−166.0 dBFS** against the incumbent multistage engine's −120.6.

Cost: group delay moves from 103.99 to 104.05 output samples. Passband deviation < 10⁻⁴ dB. No API change.
{{< /notice >}}

`fir1_8` stays in the tables, unused by the shipping chain, exactly as `fir2_2` did after the middle-halfband replacement — because it is the incumbent recipe, and the generator gates that prove the provenance of everything else still need to regenerate it. Deleting the artifact you validated against is deleting your own evidence.

Note what actually forced this. The last article's comparison showed Gesemann's wide-transition 96-tap stage-1 reaching 149.9 dB when given my tail, against my own `fir1_8`'s ~141. I published that, called it "I am not going to hide that," and then left it sitting there. The number that eventually made me fix it was not a new insight; it was the same number, in print, under my name, where I had to keep looking at it. There is a lesson about publishing your weaknesses that I did not intend to learn.

**Everything measured in this article is v0.2.1.** Where I compare against the last article's figures, I will say which version produced which number.

## The Yardstick Problem

Here is the thing that makes this measurement awkward, and it is a thoroughly familiar problem to anyone who has tried to measure a small quantity: **there is nothing to compare against.**

For the synthetic work I had ground truth. I generated a 1 kHz tone, modulated it, decoded it, and I knew what the answer was supposed to be to the last decimal because I had written the tone. Real music has no analytic form. There is no "correct" 44.1 kHz rendering of `01 I Robot` sitting anywhere that I can diff against.

So the reference has to be constructed, and it has to be *so much better* than everything it is judging that its own error is irrelevant. That is the same argument as using a −300 dB analysis window: you do not need the ruler to be perfect, you need its errors to be far below the thing you are trying to resolve.

{{< notice info >}}
The reference here is a float64 Kaiser cascade built specifically for this measurement, whose composite attenuation is **≥ 208 dB into every band that can fold into 0–20 kHz** — 215.8 / 215.6 / 214.9 / 208.2 dB at DSD64 / 128 / 256 / 512 respectively, printed per rate by the tool rather than asserted.

The best contender in this comparison measures around −150 dBFS. The reference sits 55–65 dB below that. So the difference between a decoder and the reference **is** that decoder's own error, to within a rounding error of a rounding error.
{{< /notice >}}

The cascade is generated rather than hand-designed: while the ratio to the output rate is above 2, take a ÷8, ÷4 or ÷2 step depending on how far there is left to go, and design each stage's stopband to kill everything that could fold into 0–20 kHz *of the final rate*, not of the intermediate rate. Then a final 88.2 → 44.1 kHz stage, which is where things get interesting.

Two metric choices make the residual honest rather than alignment-limited. Both of them are the fix for a trap I fell into first, so let me tell it in that order.

## Four Ways to Measure Nothing

Every one of these produced numbers that looked entirely plausible. None of them threw an exception, printed a warning, or produced an obviously broken plot. Each of them just made some decoder look worse than it is, and I only found them by being suspicious of results I liked.

I am recording all four, because anybody repeating this work will hit them, and because the failure mode — *quiet* wrongness — is the interesting part.

### Trap 1: Aligning by resampling the decoded signal

Different decimation chains have different group delays, and those delays are not integers. `kaiser4095` sits at 1032 samples; the multistage chain reports 104.0; the incumbent chains land wherever their taps put them, frequently at a half-integer.

The obvious move is to resample one signal to align it with the other. Shift by the fractional part, subtract, measure what's left.

The obvious move puts a floor of roughly **−90 dBFS** under every single residual, because your alignment resampler is itself a filter with its own error, and its error is *larger than the errors you are trying to measure*. What you then see is a table in which every decoder scores about the same, which — if you are not paying attention — reads as "they're all fine, this whole project was unnecessary."

The fix is to never touch the decoded signal. The reference's final 88.2 → 44.1 kHz stage is a windowed sinc **sampled off-centre** by an offset $\tau$:

$$c = \frac{n-1}{2} + 2\tau, \qquad h[k] = \mathrm{sinc}\!\left(\frac{2 f_c}{f_s}(k - c)\right) w(k - c)$$

and $\tau$ is fitted per decoder by golden-section search on residual energy. The fractional delay lives in the design of the reference filter, where it costs nothing, instead of in a post-hoc resampling of the signal, where it costs 90 dB. Nothing but the reference is ever resampled.

This is the single most important line in the entire harness, and it is three lines of code.

### Trap 2: Fitting the gain broadband

To compare levels fairly you fit a scale factor between decoder and reference before measuring the residual. Fit it least-squares over the whole band and the fit is dominated by 20–22.05 kHz — the transition region, where the chains *legitimately* differ and where nobody should care. The "optimal" gain that comes back then *increases* the in-band error it was supposed to remove.

Fix: fit the gain over 20 Hz–20 kHz only, in the frequency domain, over the band you are actually reporting.

### Trap 3: The ragged last window

For the whole-track measurement the audio is chopped into windows. A window that runs past the end of the file leaves the long-group-delay chains — `kaiser4095` and its 1032 samples again — with almost nothing left after the crop guards are applied. The residual of a 40-sample sliver against a 40-sample sliver is meaningless, and in this case it came back as a cheerful **+11 dB "error"**, which then dominated the power-average for the whole track.

Fix: skip short windows, and make the crop function *raise* rather than politely return a sliver. A function that silently returns something useless when it should refuse is a function that will eventually cost you a day.

### Trap 4: Estimating the lag per window

This is my favourite, because it is the one that actually behaves like physics.

Integer lag between decoder and reference is recovered by cross-correlation. On a loud, broadband window the correlation peak is sharp and `argmax` finds it instantly. On a **fade-out** the signal becomes quiet and narrowband, the correlation peak goes broad and ambiguous, and `argmax` lands hundreds of samples away — mis-scoring that one window by about 100 dB.

In this corpus, exactly **one window in 82** did it. One. That was sufficient to wreck an entire track's power-average, because a power-average is dominated by its worst element by construction.

The fix is conceptual rather than numerical. The integer lag, like $\tau$, is a **constant property of the chain** — it is the chain's group delay, and group delay does not vary with programme material. So fit it once, on a loud window, and reuse it everywhere. Do not estimate per window. Estimating a constant repeatedly does not average out the error; it just gives the error more chances to be catastrophic.

There is a related guard: the cross-correlation search is bounded to ±0.25 s around the lag we already know it must be near. Repetitive programme material — a loop, a steady groove, most of Boney M. — correlates just as strongly a whole bar away as it does at zero offset. An unbounded search will happily lock onto the wrong bar and report a beautifully confident answer.

### The tell

There is one diagnostic that catches this entire class of failure, and I offer it as the most portable thing in this article:

{{< notice note >}}
**When two genuinely different decoders report bit-identical error, it is the harness, not the decoders.**
{{< /notice >}}

When `swr` and `soxr` — different resamplers, different code, different authors — came back with the same number to the last digit, that was not a coincidence about resampler design. That was my own alignment floor being the only thing either measurement could see. Identical results from non-identical inputs mean you are measuring your instrument.

`--selftest` now covers the alignment and gain path against a signal with known delay and known gain, which is the version of this lesson that survives contact with future me.

## The Headline Numbers

Mean over three tracks at each rate, residual integrated 20 Hz–20 kHz, in dBFS:

| decoder | DSD64 | DSD128 | DSD256 | DSD512 |
|---|---|---|---|---|
| libdsddpcm eq383 (DEFAULT) | −145.0 | −143.5 | −146.7 | −145.3 |
| libdsddpcm firls767 (LEASTSQUARES) | **−151.6** | −148.5 | −149.6 | −149.8 |
| libdsddpcm kaiser4095 (KAISER) | **−151.6** | **−148.7** | **−149.6** | **−149.8** |
| libdsddpcm DIRECT (`fir1_64`) | −82.9 | — | — | — |
| dsd_lut.hpp (foobar) | −128.2 | −122.5 | −122.4 | −119.3 |
| ffmpeg (dsd.c + swr) | −95.0 | −87.5 | −88.0 | −89.4 |
| ffmpeg (dsd.c + soxr) | −128.5 | −129.6 | −133.1 | −133.3 |

The same thing expressed as **dB below the programme material** of that excerpt — how far under the music each decoder's error is sitting:

| decoder | DSD64 | DSD128 | DSD256 | DSD512 |
|---|---|---|---|---|
| libdsddpcm eq383 (DEFAULT) | −120.2 | −120.3 | −120.5 | −119.1 |
| libdsddpcm firls767 (LEASTSQUARES) | −126.8 | −125.3 | −123.4 | −123.6 |
| libdsddpcm kaiser4095 (KAISER) | **−126.9** | **−125.4** | **−123.4** | **−123.6** |
| libdsddpcm DIRECT (`fir1_64`) | −58.1 | — | — | — |
| dsd_lut.hpp (foobar) | −103.4 | −99.2 | −96.2 | −93.1 |
| ffmpeg (dsd.c + swr) | −70.3 | −64.3 | −61.9 | −63.2 |
| ffmpeg (dsd.c + soxr) | −103.7 | −106.4 | −107.0 | −107.0 |

![Decode error against real DSD material, 20 Hz – 20 kHz, all four rates](/images/libdsddpcm/corpus_error_summary.png "Real-corpus decode error, 20 Hz – 20 kHz. Lower bar = cleaner. The three libdsddpcm multistage variants cluster around −120 dB; the incumbents sit 20–60 dB above them.")

So the ordering is what the synthetic work said it would be, on real music, at every rate from DSD64 to DSD512:

- The multistage libdsddpcm variants sit **17 to 24 dB** below `foo_input_sacd`'s chain and **50 to 60 dB** below what `ffmpeg -i x.dsf -ar 44100` gives you today.
- `ffmpeg` with `soxr` explicitly requested is a completely different animal from `ffmpeg` by default — a ~40 dB gap between two invocations of the same binary. More on why below.
- The gap holds across a factor of eight in input rate, which is the part I actually cared about, because it means the result is a property of the filter design rather than an accident of DSD64.

### An honest reconciliation with the last article

The previous post led with a **44 dB** improvement — 45 dB as of v0.2.1. This one leads with 17–24 dB against the same incumbent. Those are not in conflict, and I want to be explicit about why before anyone else points it out.

The 44 dB was a *single fold spur*: an undithered 26 kHz tone aliasing to 18.1 kHz, rejected to −165.0 dBFS at v0.1.0 and −166.0 dBFS at v0.2.1, against the incumbent's −120.6. It is a clean, narrow, worst-case number and it is real.

The number in this article is a *broadband error integral over real programme material*. It bundles together the fold-back, the level error, the passband ripple, the arithmetic — everything the decoder does wrong, weighted by what the music happens to contain. Real music does not put a full-scale tone at 26 kHz. It puts most of its energy below 2 kHz, where the fold-band advantage matters far less and other error mechanisms matter more.

Two different quantities, both true, and the smaller one is the one to quote when someone asks what libdsddpcm does for their actual records.

## Where Each Decoder Is Wrong

The integrated numbers say *how much*. The spectra say *where*, and the where is more informative than the how much.

![Residual spectra for every decoder at all four input rates](/images/libdsddpcm/corpus_residual_spectra.png "Residual spectra against the reference, with the programme material in grey for scale. libdsddpcm's error is a flat floor; the incumbents' error follows the shape of the music.")

Three distinct signatures, and they are diagnostic:

**libdsddpcm's error is a flat floor** at roughly −200 dBFS per bin. It does not follow the music. That is what you want, because it means the error is *additive* — an absolute floor set by the arithmetic and the filter, independent of what is playing.

**Both incumbents' error tracks the shape of the programme material** at low frequencies. An error proportional to the signal is a scale or rounding error, not an aliasing error, and the level-accuracy section below identifies exactly which coefficients are responsible down to the part-per-million.

**ffmpeg with default swresample adds a broad 1–20 kHz component** on top of that. It is not proportional to the music and it is not a flat floor; it is fold-back of DSD noise the resampler failed to reject, redistributed across the audio band.

Three error mechanisms, three shapes, and you can read which one you are looking at off the plot before you compute a single number. This is the part where I would like to point out that a residual spectrum is doing exactly what a residual plot does in a fit: the *structure* of what is left over tells you which term in your model is missing.

## Whole Tracks, Both Channels

The tables above are 8-second excerpts taken 40 % into each track, which is to say near the loudest part. That flatters every decoder in the comparison, including mine. The conservative measurement walks entire tracks in windows, both channels: 24 track-channels, 708 windows.

Two numbers per rate — the power-average of error-to-programme over all windows, and the **worst single window**, which is the figure to quote:

| decoder | DSD64 | DSD128 | DSD256 | DSD512 |
|---|---|---|---|---|
| libdsddpcm eq383 (DEFAULT) | −120.1 / −113.6 | −119.7 / −113.3 | −119.9 / −113.8 | −115.5 / −100.8 |
| libdsddpcm firls767 (LEASTSQUARES) | −126.2 / −114.7 | −123.2 / −114.1 | −122.2 / −113.9 | −115.5 / −100.8 |
| libdsddpcm kaiser4095 (KAISER) | −126.2 / −114.6 | −123.2 / −114.1 | −122.2 / −113.7 | −116.2 / −100.7 |
| dsd_lut.hpp (foobar) | −101.9 / −92.6 | −99.1 / −98.1 | −96.3 / −95.5 | −92.9 / −89.7 |
| ffmpeg (dsd.c + swr) | −69.6 / −60.8 | −65.1 / −59.3 | −59.2 / −52.2 | −55.3 / −38.9 |
| ffmpeg (dsd.c + soxr) | −104.8 / −103.1 | −106.5 / −105.8 | −107.2 / −106.5 | −107.1 / −106.4 |

Reading it properly:

**Our error tracks the programme absolutely, not relatively.** The relative figure therefore degrades wherever the music is quiet, and the worst windows are — reliably, at every rate — fade-outs and intros. `kaiser4095` measures −122.5 dB below programme in the loud body of a track and −107.5 dB in its fade. That is the *same absolute error floor* measured against 15 dB less music. It is not a decoder behaving differently in quiet passages; it is a ratio with a shrinking denominator. If you have read my article on the sausage waveform epidemic, this will be a familiar shape of argument: what changes is not the noise, it is what you are dividing it by.

**Left and right agree to within 0.9 dB for every decoder**, and to within 0.07 dB for the incumbents. That is not a result about audio; it is a check that nothing in the harness is channel-dependent. Free consistency checks that you did not design for are the good kind, and this one would have caught an entire class of indexing bug.

**The ranking survives the conservative measurement, and so do the gaps.** At DSD512 — the hardest case, the highest rate, the deepest decimation — our worst window at −100.8 still sits 11 dB below foobar's worst at −89.7 and 62 dB below stock ffmpeg's at −38.9.

### The DSD512 column is telling me something

Look down our three rows at DSD512 in that table: −115.5 / −100.8, −115.5 / −100.8, −116.2 / −100.7. At DSD64 the same three rows differ by six dB. At DSD512 they are **the same number**, to within fit noise, across three completely different final-stage filters.

When swapping the component you are ranking stops changing the result, you are no longer measuring that component. Something upstream and common to all three has become the limit.

I have a candidate and I want to be clear that it is a hypothesis rather than a measurement. `fir1_64m`, the new DSD512 stage-1, quantizes to −139.4 dB, and the composite worst fold at DSD512 → 44.1 kHz is −139.7 dB. At DSD64, post-v0.2.1, `fir1_8d` sits at −157.4 dB and the composite at −149.7. So DSD512's chain is a full 10 dB shallower than DSD64's, and it is shallower *at stage 1* — precisely the position that no choice of final filter can compensate for.

{{< notice note >}}
If that is right, then this measurement has just done to `fir1_64m` exactly what the last article's comparison did to `fir2_2`: found the next bottleneck by exposing a ceiling that several different configurations were all sitting on.

The tell is the same tell both times. **When variants that should differ report the same number, the thing they share is the limit.** It was a −109.7 dB plateau in the fold band last time. It is a −115.5 dB plateau at DSD512 this time.
{{< /notice >}}

I have not confirmed it, and confirming it is cheap: rerun the DSD512 rows with a deepened `fir1_64m` and see whether the three filter variants separate again. If they do, the diagnosis is correct and there is a v0.2.2 in it. If they stay glued together, the limit is somewhere else and I have learned something more interesting. Either outcome is worth the afternoon, which is the property a good next experiment should have.

## The Thing the Synthetic Sweep Could Not See

Now for the finding that made this whole exercise worth doing, and which is a small correction to my own previous conclusions.

In the last article I wrote, with some amusement at my own expense, that **equiripple won and I had predicted it wouldn't**. My filter-methods document had argued that equiripple's defining property — uniform passband ripple $\pm\delta_p$ — *is* in-band coloration, a frequency-dependent gain error across the entire audio band, and that Kaiser or `firls` should therefore be preferred for a measurement decoder. The sweep ran `eq383` with a tight passband weight, it hit 152.6 dB with a flat passband, and it won on the joint metric at half the taps of `firls767`. Prediction falsified, document's escape clause vindicated, `eq383` shipped as DEFAULT.

Look at what real material says. Residual by sub-band, in dB below programme:

| decoder | 20 Hz – 2 kHz | 10 – 20 kHz | gain err (ppm) |
|---|---|---|---|
| libdsddpcm eq383 (DEFAULT) | −122.5 | −126.6 | 0.47 |
| libdsddpcm firls767 (LEASTSQUARES) | **−143.9** | −126.7 | 0.04 |
| libdsddpcm kaiser4095 (KAISER) | **−143.6** | −126.8 | 0.04 |

At high frequencies the three are indistinguishable — −126.6, −126.7, −126.8, which is a common floor rather than three separate results. At low frequencies, where music actually lives, `firls767` and `kaiser4095` sit **21 dB deeper** than `eq383`. And `eq383` carries an order of magnitude more gain error.

That is the passband ripple. It was there all along. My original prediction was *right*, and the synthetic sweep could not see it, for a reason that is obvious in hindsight and which I think generalises well beyond DSD:

{{< notice info >}}
**A single-tone fixture cannot measure passband ripple.** A tone at 1 kHz probes the response at exactly one frequency. Ripple is an error that varies *across* the passband, so a tone sees one arbitrary sample of it and reports whatever it happens to find there. Broadband programme material excites the whole passband at once, and the ripple integrates into the residual as an error proportional to the signal.

The synthetic sweep's objective saturated at the oracle-visibility knee ($L_{sb} \approx 150$ dB) because it was scoring *stopband leakage*, which is exactly what tones and ultrasonic stress vectors are good at exciting. The passband term was in the objective. Nothing in the fixture could make it move.
{{< /notice >}}

So which filter should ship as DEFAULT? I have thought about this for longer than the size of the effect deserves, and I am leaving `eq383` where it is:

- It is still **120 dB below the programme material**. Twenty-one dB of headroom on a number that is already 120 dB down is not a listening experience, it is a bookkeeping preference.
- `eq383` runs at 187 MS/s against `firls767`'s 138 and `kaiser4095`'s 42. For a library that wants to be embedded in players and meters, that difference is real in a way the residual is not.
- `LEASTSQUARES` is one enum away for anyone who wants it, and it is now documented as the variant to pick when the answer is going into a measurement rather than a DAC.

What has changed is the *documentation*, which now says which variant to use for what and can point at real-material evidence for the claim. That is the actual deliverable. The point was never that `eq383` is perfect; it is that you can find out how imperfect it is without taking my word for anything.

I also note, with the sting fully intact, that the escape clause in my filter-methods document — "*unless* the equiripple design is run with a tight passband-ripple weight, at which point its tap-count advantage typically erodes" — was the part I leaned on to justify shipping it. The tap-count advantage did not erode. The ripple did not disappear either. Both halves of the document were right and I quoted the convenient half.

## Level Accuracy, and Predicting foobar's Error from Its Coefficients

This is the section where the measurement stops being a comparison and starts being an explanation, and it is the most satisfying result in the article.

Mean gain error per rate, in parts per million, sign meaning decoded output relative to reference:

| decoder | DSD64 | DSD128 | DSD256 | DSD512 |
|---|---|---|---|---|
| libdsddpcm eq383 (DEFAULT) | −0.52 | −0.47 | −0.36 | −0.51 |
| libdsddpcm firls767 | −0.07 | +0.05 | +0.02 | +0.01 |
| libdsddpcm kaiser4095 | −0.06 | +0.05 | +0.03 | +0.02 |
| dsd_lut.hpp (foobar) | −4.38 | −7.30 | −10.78 | −15.66 |
| ffmpeg (dsd.c + swr) | +0.91 | +3.16 | +6.30 | +10.78 |
| ffmpeg (dsd.c + soxr) | +3.86 | +3.31 | +3.15 | +3.14 |

Look at the foobar row. The level error is not constant — it **grows with input rate**, roughly doubling-ish as you go up. That is not noise and it is not a coincidence; it is a structural property of the chain, and the shipped coefficient tables predict it exactly.

The fixed-point tables have DC gains of **+2.056 ppm** (`fir1_16`), **+3.510 ppm** (`fir2_2`) and **−1.919 ppm** (`fir3_2`). The multistage converter inserts one more `fir2_2` for every doubling of the DSD rate — that is how it eats the extra factor of two. So the composite DC error should accumulate as

$$\varepsilon(\text{rate}) = \varepsilon_{16} + n\,\varepsilon_{2} + \varepsilon_{3}, \qquad n = 1, 2, 3, 4$$

giving a predicted **+3.6 / +7.2 / +10.7 / +14.2 ppm** across the four rates.

Measured: **4.4 / 7.3 / 10.8 / 15.7 ppm.**

Three of the four agree to within a few percent; the DSD512 case runs about a ppm and a half high, which is around where I would expect the composite of four stacked stages to start showing second-order terms. I did not expect this to work as cleanly as it did. Predicting a measured quantity from the coefficient tables alone, across a factor of eight in rate, is the strongest possible evidence that you have correctly identified the mechanism rather than merely observed a correlation.

And this is exactly the "convention versus contract" distinction from the last article, now with a number attached to it and a slope. The incumbent's DC gain is a *convention* — whatever the fixed-point tables happen to sum to — and conventions compound. libdsddpcm renormalises every stage by $1/\sum h$ in double precision, so unity DC is **exact by construction at every rate**, and its gain error row is flat at a few hundredths of a ppm regardless of how many stages the chain has.

The ffmpeg + soxr row is a constant ≈ 3.2 ppm, and `dsd.c`'s own filter accounts for it: its 96 taps sum to 0.999996958, i.e. a 3.04 ppm DC error, carried through unchanged because there is no renormalisation anywhere downstream. The swr row's growth with rate I do not currently have a clean single-mechanism explanation for, and I would rather leave that as an open observation than invent one.

DC offsets, for completeness, are negligible everywhere — 0.000 to 0.011 LSB at 24 bits, which is to say nobody is broken in that particular way.

{{< details summary="Is any of this audible? No." >}}
A 15.7 ppm gain error is 0.00014 dB. Nobody has ever heard that, and nobody ever will.

It matters for exactly one reason: if you are building a *measurement* tool, a level error is a systematic bias in every number your tool prints. crête reports dynamic range, and a decoder that quietly scales the signal is a decoder that quietly biases the result. The point of an exact unity-DC contract is not fidelity, it is that the meter's reading is about the music.
{{< /details >}}

## Why ffmpeg Lands Where It Does

The most useful thing this corpus produced is not a ranking. It is a diagnosis, and it exonerates the code everyone would blame first.

`dsd.c` is **not** the problem. Its 96-tap filter is fine for what it claims — flat to 48 kHz, alias-free below 70 kHz after ÷8 — and the previous article showed that, given a proper tail, Gesemann's stage-1 at 149.9 dB measured *deeper* in the worst fold band than my own `fir1_8` at ~141. (That is the comparison `fir1_8d` was written to answer, and at −157.4 dB it now answers it. The point stands regardless: his stage-1 was never the weak link.) The problem is what it leaves behind, and what the next stage does with it.

Energy at ffmpeg's native output rate ($f_{\text{dsd}}/8$), by band, in dB:

| source | native rate | 20 Hz–20 kHz | 22–40 kHz | 40–80 kHz | 80–176 kHz | > 176 kHz |
|---|---|---|---|---|---|---|
| DSD64 | 352.8 kHz | −32.9 | −77.7 | −42.9 | −33.7 | — |
| DSD128 | 705.6 kHz | −21.9 | −68.5 | −76.2 | −35.4 | −29.0 |
| DSD256 | 1411.2 kHz | −24.5 | −64.4 | −62.9 | −65.3 | −27.2 |
| DSD512 | 2822.4 kHz | −28.3 | −82.8 | −82.4 | −82.2 | −31.5 |

Read the last two columns against the first. The residual noise-shaper energy above 80 kHz is **as loud as the music** — −27 to −35 dB, against −22 to −33 dB for the audio band itself.

That is the whole story. A DSD stream at 8fs is not a signal with some noise on top; it is a signal sitting next to an equal-magnitude pile of shaped ultrasonic noise. Handing that to a generic resampler and asking for 44.1 kHz means asking that resampler for about **120 dB of stopband rejection** just to keep the fold-back 150 dB under the programme. Default swresample does not have it. soxr comes much closer, which is precisely the ~40 dB gap between the two ffmpeg rows in every table in this article.

{{< notice note >}}
This is the measured justification for a design decision I made on theory alone: **libdsddpcm ships the decimation tail** rather than handing an 8fs stream to somebody else's resampler.

The last article put it as "dsd2pcm's stage-1 is not the weak link — its missing tail is." I believed that from the response-domain analysis. This is what it costs on real music: 50–60 dB, in the default configuration, on material people actually own.
{{< /notice >}}

There is a practical corollary worth stating plainly for anyone who is not going to link a new library today: if you are converting SACD rips with ffmpeg right now, `-af aresample=resampler=soxr` buys you roughly 35–45 dB for the price of one command-line flag. It is still 15–20 dB behind a proper decimation chain and it still carries a 3 ppm level error, but it is free and it is enormous. I would rather everyone's rips got better than that everyone used my library.

## The 48 kHz Family: The Least-Evidenced Path

libdsddpcm reaches 48/96/192 kHz with a rational up-80/down-147 stage hung off the neighbouring 44.1-family rate — one shared Kaiser-150 prototype, 17455 taps, DEFAULT filter only. Until this corpus that path had **no end-to-end measurement behind it at all**, only the prototype filter's designed response. It was the thing in the library I was least able to defend.

`foo_input_sacd` is absent from this comparison on purpose, and its absence is informative rather than convenient: its multistage converter divides $f_{\text{dsd}}$ by $f_{\text{pcm}}$, and $2822400/48000 = 58.8$ is not an integer chain, so the plugin has **no 48 kHz-family path at all**. ffmpeg does, via the same generic resamplers as before.

Nine excerpts across all four input rates, dB below programme:

| decoder | 48 kHz | 96 kHz | 192 kHz |
|---|---|---|---|
| libdsddpcm (rational up-80/down-147) | **−123.6** (worst −119.8) | **−123.7** (worst −119.8) | **−119.9** (worst −112.0) |
| ffmpeg (dsd.c + swr) | −93.2 (worst −86.5) | −104.3 (worst −102.3) | −105.3 (worst −103.2) |
| ffmpeg (dsd.c + soxr) | −106.0 (worst −102.1) | −106.4 (worst −102.5) | −106.3 (worst −102.3) |

And level accuracy on the same runs:

| decoder | mean abs gain error (ppm) | worst |
|---|---|---|
| libdsddpcm | **0.03** | 0.14 |
| ffmpeg (dsd.c + swr) | 1.50 | 3.46 |
| ffmpeg (dsd.c + soxr) | 3.09 | 3.72 |

The least-evidenced shipped path turns out to be **as good as or better than the 44.1 kHz results** — −119.9 to −123.7 average — beating stock ffmpeg's 48 kHz output by 20–30 dB with a gain error two orders of magnitude smaller. The 17455-tap prototype is not the weak link I had privately been bracing for.

Two honest caveats, because this section is the one where I am most tempted to declare victory:

**ffmpeg's swr does much better at 96/192 kHz (−104, −105) than at 48 kHz (−93) or 44.1 kHz (−70).** Its bad case is specifically the *low* output rates — where the resampler's stopband has to do the most work — which is also exactly what most people ask for from SACD material. So the gap is widest precisely where it is most often encountered, which is either damning or unlucky depending on how charitable you feel.

**This is our slowest path**, at 4–70 MS/s against 70–350 MS/s for the 44.1 family, because of that 17455-tap stage. Still real-time by a comfortable margin at every rate, but by the smallest margin anywhere in the library.

One methodological note, because a good number from an unvalidated reference is worth nothing. The 48 kHz reference was built **two independent ways** — via 88.2 kHz with up-80/down-147, and via 176.4 kHz with up-40/down-147. They agree to **0.01 dB**. This is the same discipline as running an xAct-free notebook against an xAct one, or a hand-ported `remez.c` against scipy's: one tool tells you a number, two tools tell you whether to believe it. I have yet to regret building the second oracle, and I have repeatedly regretted not building it sooner.

## About the DIRECT Chain

`DIRECT (fir1_64)` measures ≈ −83 dBFS, which looks catastrophic in a table where everything else is at −150, and it is **not a defect**.

DIRECT is a byte-exact reproduction of the incumbent's single-stage filter: a gentle ~30 kHz corner that deliberately passes an attenuated top octave rather than brickwalling at Nyquist. Measured against a brickwall reference, it "fails" in 20–22 kHz *by design* — the reference and the filter disagree about what should happen up there, and the filter is doing what it was asked to do.

The em-dashes in its row at DSD128 and above are not missing measurements either. `fir1_64`'s 30 kHz corner is a DSD64-specific analog spec, so the Direct chain is DSD64-only, and asking for it at any other rate returns `DSDDPCM_ERR_UNSUPPORTED` rather than silently substituting a chain you did not request. This is the same principle as `BLACKMAN_HARRIS` returning an explicit error instead of quietly handing back something adjacent: a library that cannot do what you asked should say so at the API boundary, not in the output.

Its low-frequency residual, −100 dB below programme, is the meaningful figure. The rule stands as it did in the last article: the two chains are not interchangeable for top-octave content, and if you are measuring anything at 44.1 kHz, use MULTISTAGE.

I am including DIRECT's number rather than quietly dropping it, because a comparison that excludes results it finds inconvenient is not a comparison. The right response to a number that needs an explanation is to publish the explanation.

## Throughput, and Every Shipped Rate on Real Files

Single-threaded, one channel, warm cache, on this machine. ffmpeg's figures include process start-up and container demux, which is not entirely fair to ffmpeg, and I am reporting it anyway with the caveat attached:

| decoder | throughput (MS/s) |
|---|---|
| libdsddpcm DIRECT (`fir1_64`) | 837 |
| ffmpeg (dsd.c + soxr) | 272 |
| ffmpeg (dsd.c + swr) | 267 |
| libdsddpcm eq383 (DEFAULT) | 187 |
| libdsddpcm firls767 (LEASTSQUARES) | 138 |
| dsd_lut.hpp (foobar) | 68 |
| libdsddpcm kaiser4095 (KAISER) | 42 |

DSD64 is 2.8224 MS/s, so DEFAULT is running at about 66× real time and even the deliberately extravagant `kaiser4095` clears 14×. Nobody is waiting on this library.

The rate sweep — every shipped output rate, decoded from real files at every input rate — is in the repository's `CORPUS_ANALYSIS.md` in full. The structural thing to note from it is the `decim = 0` column: those are the rational 48 kHz-family outputs, where the DSD-to-PCM ratio is not an integer and the up-80/down-147 stage is doing the work. Group delay is reported through the API for all of them, which is what lets a caller compensate latency and trim pre/post-ring for true-peak alignment.

## What This Does and Does Not Prove

{{< notice warning >}}
**This measures decoder error. It does not measure mastering, musical content, or whether DSD was worth it.** 44 GB of source material sounds like a lot and it is twelve tracks from eight albums. It is enough to establish that the ranking is stable across rates, genres and eras. It is not a survey of the format.
{{< /notice >}}

The rest of the honest list:

- The headline tables are **8-second excerpts, left channel, 40 % into each track** — near the loudest part, which flatters everybody. The whole-track section is the conservative measurement and its worst-window column is the number to quote.
- The corpus is commercial material of **unknown provenance**, and several titles are near-certainly DSD transfers of PCM masters. Irrelevant to the comparison, as every decoder sees the identical bitstream — but it does mean this corpus cannot tell you anything about DSD-as-a-format.
- The reference is my own construction. It is validated two independent ways at 48 kHz and its depth is printed per rate rather than asserted, but it is not somebody else's reference and I would be delighted for someone to measure against theirs.
- **Everything here is measured against v0.2.1**, not the v0.1.0 the last article described. The DSD64 stage-1 bottleneck that article admitted to is fixed; the DSD512 stage-1 that replaced it as the likely limit is not.
- The DSD512 bottleneck diagnosis above is a **hypothesis supported by a coincidence of numbers**, not a measurement. I have said so where it appears and I am saying so again here.
- The throughput figures are one machine, one thread, warm cache. Treat them as ratios, not as specifications.
- `tables.npz` (LGPL-derived reference data) is required to reproduce the foobar rows, and it is used **only as an analysis oracle**. The LGPL firewall from the last article holds: no `dsd_lut` coefficient has ever entered the shipped library.

Everything here reproduces:

```sh
P="PATH=$PWD/dsp/bin:$PATH ./dsp/bin/python3 tools/corpus_compare.py"
$P --corpus /path/to/DSD_TestCorpus --per-rate 3 --dur 8   # excerpt tables + plots
$P --full     --per-rate 3 --workers 4                     # whole tracks, both channels
$P --family48 --per-rate 3 --dur 6                         # 48/96/192 kHz
$P --selftest                                              # check the measurement path
```

Nothing in this article is hand-transcribed. Every table is printed by that script, and the script is in the repository[^2].

## What I Actually Learned

**The harness is the hard part.** I wrote a DSD decoder in C in a few weeks. I spent longer than that learning to measure one. Four separate bugs, every one of which produced numbers that were plausible, self-consistent, and wrong — and *not one of which raised an error*. The library was correct throughout. My knowledge of whether it was correct was the thing under construction.

**The fixture determines what your objective function can see.** This is the finding I will carry furthest. The passband-ripple term was in my sweep's objective. It was correctly weighted. It was mathematically fine. It could not move, because a single-tone fixture cannot excite passband ripple, and so a filter with 21 dB more low-frequency error than its competitor scored identically. I did not have a scoring bug. I had a *stimulus* bug, which is much harder to see, because everything downstream of it is working perfectly on the wrong data. When an optimisation lands on an answer you had predicted against, check whether your fixture is capable of expressing the thing you predicted.

**Constants should be fitted once.** The per-window lag bug is the tidiest illustration I have ever produced of something I already believed. Group delay is a constant property of a chain. Re-estimating a constant on every window does not average the error down — it hands the error 82 independent opportunities to be catastrophic, and it only needs one.

**A prediction that lands is worth more than a measurement that agrees.** Computing foobar's level error from its coefficient tables — +3.6 / +7.2 / +10.7 / +14.2 ppm predicted against 4.4 / 7.3 / 10.8 / 15.7 measured, across a factor of eight in rate — is the moment this stopped being a bake-off and became an explanation. Anyone can rank decoders. Predicting *how wrong* one will be, from its published coefficients, before running it, is the difference between observing an effect and understanding it. That is not an audio lesson. That is the whole method.

And the one from last time, which came back around: **choosing the right observable matters as much as measuring carefully.** In the last article the wrong observable was DR, which rewards the failure it should punish. This time it was the residual against a deep reference — the right observable, measured through four consecutively wrong instruments. Getting the observable right is necessary and it is nowhere near sufficient.

The warning notice is paid off. libdsddpcm decodes real commercial DSD, at every rate it claims to support, with an error that sits 120 dB below the music and does not follow the music's shape — and now there is a published methodology, a reproducible tool, and a set of numbers that anyone can go and disagree with.

That last part remains the entire point of the project. Every DSD decoder ships coefficients. This one ships the argument.

---

*Written on a Fedora Sway desktop, to Patricia Barber's* Café Blue *— a track I have now heard approximately four hundred times in eight-second increments, forty percent of the way in, and which I would like to note is still excellent.*

[^1]: [libdsddpcm: I Wrote a DSD Decoder Because Nobody Would Show Me Their Homework](/posts/libdsddpcm-decoder/) — the first article in this series, covering generator forensics, the LGPL firewall, the delta-sigma test fixture, the filter sweep, and the library architecture.

[^2]: [libdsddpcm on Codeberg](https://codeberg.org/abksh/libdsddpcm) — `tools/corpus_compare.py` and `docs/CORPUS_ANALYSIS.md`.

[^3]: Philips, *SACD System Description (Scarlet Book), Annex D — Audio Signal Requirements (Normative)*, March 2003; transcribed in the Saracon manual, Appendix C.

[^4]: [dsd2pcm](https://github.com/clivem/dsd2pcm) — Sebastian Gesemann's BSD decoder, whose 96-tap stage-1 is the ancestor of FFmpeg's `dsd.c`.

[^5]: [foo_input_sacd](https://github.com/maxim-v4s/foo_input_sacd) — the foobar2000 SACD input lineage, source of the `dsd_lut.hpp` tables.

[^6]: [SoX Resampler (soxr)](https://sourceforge.net/projects/soxr/) — the higher-quality resampler backend available to FFmpeg via `aresample=resampler=soxr`.
