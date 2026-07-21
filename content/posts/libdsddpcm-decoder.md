+++
date = '2026-07-21T18:40:00+02:00'
draft = false
title = 'libdsddpcm: I Wrote a DSD Decoder Because Nobody Would Show Me Their Homework'
useAlpine = false
loadNerdFont = false
tags = [
    "dsd",
    "pcm",
    "sacd",
    "filter-design",
    "signal-processing",
    "delta-sigma",
    "decimation",
    "annex-d",
    "c99",
    "clean-room",
    "measurement",
    "open-source"
]
+++

*On why every open-source DSD decoder ships coefficients without proof, what happens when you try to regenerate someone else's filter tables from first principles, and the 44 dB of aliasing rejection nobody was collecting.*

## The Problem I Actually Had

I have been building [crête](https://codeberg.org/abksh/Crete), a dynamic-range meter. Measurement tools have one obligation above all others: the number they print has to be about the music, not about the tool. So when I pointed it at DSD material, I needed to know what the decode path was doing to the signal before the meter ever saw it.

DSD is one bit at 2.8224 MHz. To measure anything you first decimate it by 64 to 44.1 kHz, and that decimation is a filter. If the filter leaks ultrasonic noise into the audio band, the meter reads a *higher* dynamic range — and reports it confidently. The failure mode of a bad decode filter is not a number that looks wrong. It is a number that looks great.

So I went looking for the correct filter, expecting to find a specification.

There isn't one.

{{< notice note >}}
DSD deliberately leaves decimation to the implementer. There is **no normative decode filter** in the Scarlet Book. Every decoder picks its own coefficients, and none of them publish evidence that theirs are any good.
{{< /notice >}}

What I found instead was an ecosystem of coefficient tables passed hand to hand like folk remedies:

- **dsd2pcm** (Sebastian Gesemann, BSD) — the minimal decoder that almost everything forks: dsd2dxd, dsf2flac, FFmpeg's ancestor code. It ships a single ÷8 stage to 352.8 kHz and stops there. No path to 44.1 kHz exists in it at all.
- **dsd-nexus** (LGPL-2.1) — a full SACD suite whose `libdsdpcm` is a C wrapper over a C++ core with optional Intel IPP/TBB dependencies and bundled container/DST code. Comprehensive, and licensed such that FFmpeg will never link it.
- **`dsd_lut.hpp`** — the foobar2000 `foo_input_sacd` lineage tables, LGPL-2.1, which is what crête itself was using.
- **Saracon** (Weiss, proprietary) — the high-end reference. Genuinely excellent, entirely closed, and its manual explicitly forbids reverse engineering.

Every one of them ships numbers. Not one ships a measurement. The gap wasn't quality — the real decoders are fine — it was that nobody had ever published the proof.

That gap is the whole project.

## What libdsddpcm Is

**libdsddpcm** — `lib` + `dsd` + **d**(ecode) + `pcm` — is a standalone BSD-2-Clause DSD→PCM decode library. Pure C99, zero dependencies beyond libc. Repository: [codeberg.org/abksh/libdsddpcm](https://codeberg.org/abksh/libdsddpcm), currently at **v0.1.0**.

The scope is aggressively narrow, and that was a decision, not an accident:

- **Decode only.** Input is raw DSD bits plus (channels, rate, bit order). Output is PCM.
- **No container parsing.** DSF and DFF demuxing stays with the consumer, who is already doing it.
- **No DST decompression.** That's a separate lossless codec and belongs in its own library.
- **No encoder.** PCM→DSD is unbounded and has no normative reference to validate against, which means I could never prove an encoder correct. Out.

The flat C ABI and pkg-config module exist for a specific reason: FFmpeg links external libraries via pkg-config only. Being adoptable was a design constraint from day zero, not an afterthought.

Guiding principle, written at the top of the plan and kept in view whenever the problem got foggy:

{{< notice info >}}
**Validation is the moat.** No existing DSD decoder publishes proof that its filters are correct. A bit-exact decode, an analytic round-trip, measured stopband and noise per filter, and a published methodology — that is what earns the word "golden."

**And DR is not the objective. Accuracy is.** A filter that reads *higher* DR is usually the *worse* one.
{{< /notice >}}

## Annex D: The Part That Is Normative

Here is the correction to my own earlier thinking, and it mattered enormously.

I had been telling myself "no spec exists at any price." That is true for **coefficients** and false for **measurement**. The Scarlet Book's **Annex D — Audio Signal Requirements (Normative)** fixes the reference level, the legal peak, the HF noise ceiling, and the exact measuring filters. It is transcribed in the Saracon manual's Appendix C and corroborated by both Merging/Pyramix SACD Production Guides.

So: the filter is free, but the **oracle is built to Annex D**.

{{< notice note >}}
**D.1 — Audio level.** Measured after a 50 kHz Butterworth 30 dB/oct (5th-order) low-pass.

**D.2 — 0 dB SACD reference.** A sine at 50% of theoretical max DSD level ⇒ **0 dB SACD = −6.02 dBFS** exactly, at unity gain.

**D.3 — Maximum audio peak.** Set by DSD modulation level $|28 - 2N|/28$, where $N$ is the number of 1-bits in any 28 consecutive DSD bits, with $4 \le N \le 24$. Max legal value $20/28$ ⇒ **+3.10 dB SACD = −2.9 dBFS**.

**D.4 — HF signal + noise.** RMS after a 40 kHz high-pass *and* a 100 kHz low-pass (both BW, 30 dB/oct) is at most the RMS of a −20 dB SACD sine (**−26 dBFS**). RMS averaging = 1st-order unity-gain IIR, coefficient $2^{-19}$ (≈ 0.85 Hz at 2.8224 MHz).

**E.4 — DC offset.** Recommended below −50 dB SACD = **−56 dBFS**.
{{< /notice >}}

Note what D.3 quietly tells you. The bound $4 \le N \le 24$ means bit density stays inside [14.3%, 85.7%] and never saturates. That is DSD's inherent headroom bound, quantified — and it means round-trip testing of true peak near full scale is *physically impossible* for legal DSD. Not a bug in the test. A property of the format. That realization removed an entire class of tests I had planned to write.

D.4 is the one that defines the job. The 40–100 kHz band is exactly what the decimation filter has to reject, because that is the shaped noise that folds into the audio band if you let it.

## Phase 1: Prove the Generator Before You Trust Any Filter

The temptation was to design fresh filters immediately. I didn't, and I think this was the single best sequencing decision in the project.

Before designing anything new, I built a generator and made it **regenerate the five incumbent tables from clean-room design recipes, then byte-compare them against `dsd_lut.hpp`**. If my generator can reproduce someone else's tables from a stated recipe, my generator works. If it can't, nothing downstream is trustworthy.

This also forced a licensing discipline I wanted anyway:

{{< notice warning >}}
**The LGPL firewall.** `dsd_lut.hpp` is LGPL-2.1. Using it as a **test oracle** to prove a generator is fine. Nothing derived from it ships. Every coefficient in libdsddpcm comes from the clean-room generator with the generator version and parameters embedded in the header. The reference file is not in the repository and is gitignored locally.
{{< /notice >}}

### The Forensics

This turned into a small detective exercise, and it is my favourite part of the whole project.

**`fir1_64`** (641 taps) fell first. Stopband lobes equal to ±0.03 dB, passband ripple in $[1, 1+2\delta]$ with the minimum at DC, and a conspicuous endpoint tap spike — 1652 against a 421 envelope. Remez fits plateaued around 2500 LSB with residual confined to the transition band, which falsified minimax. Flat equal lobes plus an endpoint spike is a **Dolph-Chebyshev window** signature. Fitting a chebwin-windowed sinc converged to **integer error exactly 0** at (30 kHz corner, 100 dB attenuation). In MATLAB terms: `fir1(640, 2*30000/2822400, chebwin(641,100))`.

Byte-exact. 641 coefficients, zero disagreement. That is the moment the generator became trustworthy.

The other four resisted. `fir1_8` (80 taps) was ruled out in order: windowed sinc across all standard windows with free scale and DC-normalization options — ≥ 50 000 LSB, no. Taylor window — 43 000 LSB, no. Parks–McClellan — plateau at 24 LSB, tantalizingly close.

That 24 LSB is the honest bit. It looks like tool noise. It isn't. I ported Janovetz's `remez.c` faithfully as an independent PM implementation, and it agrees with scipy to 4e-13 at the fitted spec. All PM tools converge to the *same* unique minimax optimum here. So a 24-LSB gap is **structural, not numerical** — Parks–McClellan is falsified as the design family, decisively, and only because I built a second oracle instead of squinting at one.

What actually fits is **CLS** — constrained least squares, Selesnick–Lang–Burrus, no transition band. It matches the whole phenomenology: flat stopband lobes pinned at a constraint level, smooth spike-free tails, DC exactly on the envelope, no $(f_p, f_s)$ pair to snap to. It fits to 23 LSB with $\delta_p \approx 2.0 \times 10^{-6}$ — a round number, which is what a human types into a design tool.

| Table | N | Identified design | max&#124;Δint&#124; | Gate |
|---|---|---|---|---|
| `fir1_64` | 641 | Dolph-Chebyshev sinc, 30 kHz, 100 dB, unity-DC, ×2³¹ | **0** | **byte-exact** |
| `fir1_8` | 80 | CLS lowpass, wo ≈ 156 486 Hz @ DSD64, ×2²⁸ | 23 | bounded |
| `fir1_16` | 160 | Same family, wo ≈ 156 670 Hz @ DSD128 | 13 | bounded |
| `fir2_2` | 27 | CLS halfband, wo = 0.25, δp = δs ≈ 3.53e−6 (−109.0 dB) | 192 | bounded |
| `fir3_2` | 151 | CLS halfband, wo = 0.25, δp = δs ≈ 1.93e−6 (−114.3 dB) | 148 | bounded |

The halfbands were fitted with *independent* $\delta_p$ and $\delta_s$, and both converged to $\delta_p = \delta_s$ to six digits — the symmetric CLS constraint at wo = 0.25 forces halfband structure automatically. I hadn't imposed that. It fell out. Internal consistency checks that you didn't design for are the good kind.

Cross-check: `fir1_8` and `fir1_16` carry the same physical corner (~156.5 kHz) at DSD64 and DSD128 respectively. One analog spec, two rates, exactly as a stage-1 pair should behave.

The whole upstream toolchain is consistent with two MATLAB Signal Processing Toolbox one-liners: `fir1(..., chebwin(...))` and `fircls1(n, wo, dp, ds)`. The residual ≤ 192 LSB is the class of difference produced by `fircls1`'s internal frequency-grid and quadrature choices versus an exact-integral implementation. Every coefficient agrees to ~1e-7 of fixed-point scale.

{{< details summary="Why 'bounded' is an acceptable gate result" >}}
CLS is a strictly convex QP, so the solution is unique. Identifying the family and parameters to seven significant figures, with relative coefficient accuracy around 1e-7, tells me the design recipe. Byte-exactness would additionally tell me MATLAB's grid size and quadrature rule, which is trivia — and libdsddpcm designs its own filters anyway. Parity mode is a compatibility baseline, not the product.
{{< /details >}}

### Parity Mode vs Golden Mode

Two mutually exclusive normalization contracts, and confusing them wastes a day:

- **Parity mode** reproduces upstream's fixed $2^{-28}$ / $2^{-31}$ scaling byte-exactly. DC gain 1.000002027 for `fir1_8`. This is what the byte-compare checks.
- **Golden mode** forces overall cascade DC gain to exactly 1.0. This is the libdsddpcm shipping contract.

| stage | parity DC gain | golden DC gain |
|---|---:|---:|
| `fir1_64` | 1.000000001 | 1.000000000000 |
| `fir1_8` | 1.000002027 | 1.000000000000 |
| `fir2_2` | 1.000003510 | 1.000000000000 |
| `fir3_2` | 0.999998081 | 1.000000000000 |

The composite multistage cascade in parity mode accumulates **+7.1 ppm** of DC error. Golden mode is exactly 1.0 by construction — one `1/sum` multiply per stage. Small, and it is the difference between a level *convention* and a level *contract*. For a measurement decoder that distinction is the entire job.

Phase 1 also corrected a topology question I had open. **Direct = `fir1_64` alone**, decimating the full ÷64 — that is crête's default, with a 30 kHz −6 dB corner and gentle top-octave roll-off (−0.115 dB at 20 k, −0.908 dB at 24 k). **Multistage** reaches 8fs = 352.8 kHz via `fir1_8`, then three 2:1 halvings to 44.1 kHz, flat to 20 kHz and brickwalled at Nyquist (−88 dB at 24 k).

Those two chains are **not interchangeable for top-octave content**. Direct passes 20–30 kHz attenuated; multistage cuts everything above ~22 kHz. If you are reporting true peak or HF content, that choice changes your answer.

## Phase 2: Building the Ruler

To rank filters whose stopband leakage might reach −150 dBFS, the test signal's own noise floor must sit *below* that. Otherwise the sweep ranks the fixture, not the filters.

So I needed a delta-sigma modulator — as a **test fixture, never an encoder**. Offline, never shipped, frozen and checksummed so its quirks are common-mode across every candidate and cancel in the relative ranking.

### The −150 dBFS Reading That Was Wrong

The plan said "in-band floor ≤ −150 dBFS over 20 Hz–20 kHz." I built the feasibility harness — calibrated to Parseval Σ = 1.000000, with a −6 dBFS tone reading −6.021 — and ran CRFB8 at $H_\infty = 1.4$.

| band | floor (notch) | median | max (worst) | integrated |
|---|---:|---:|---:|---:|
| 0–20k | −236 | −197 | **−143** | −121.3 dBFS |
| 0–24k | −236 | −194 | **−125** | −104.7 dBFS |

Integrated in-band: **−121.3 dBFS**. Which is, to within noise, exactly DSD64's intrinsic ~120 dB audio-band dynamic range.

That is when it clicked: a −150 dBFS *integrated* in-band floor is **physically impossible for the format**. I had been reading a spectral-density spec as an integrated one. The −150 refers to the noise *density* on the PSD — which is the thing that could masquerade as filter stopband leakage in a sweep, and is therefore the number that actually matters here.

Read correctly: spectral floor −197 median, −206 dBFS/Hz in the notch — passing by roughly 50 dB. Worst-case in-band density at the top of the band, −143 to −147 dBFS/Hz — sitting right on the line, 3 to 7 dB short in 15–20 kHz.

Which vindicated the plan's order-8-develop / order-10-rank split for a reason I hadn't originally understood.

![CRFB8 feasibility: shaped-noise PSD from the from-scratch NTF, with the audio band and the −150 dBFS/Hz line marked](/images/libdsddpcm/crfb8_noiseshaping.png "The plot that produced the correction. CRFB8 from the from-scratch NTF synthesis, −150 dBFS/Hz marked. The band-edge hump on the right of the notch is the 3–7 dB shortfall.")

This is the figure that made the units click, and it is worth keeping alongside its replacement because it is also the last artifact of the from-scratch NTF era. That synthesis was faithful enough to fix CRFB8 at $H_\infty = 1.4$ — a stable, well-understood point — and went unstable at order 10, so it could never give the CRFB10 number the ranking tier needed. Below is the same measurement once delsig was running properly, with both orders overlaid:

![CRFB8 and CRFB10 noise shaping from the delsig-grade modulator](/images/libdsddpcm/crfb_noiseshaping.png "The same measurement, done right. CRFB8 and CRFB10 from the resonator-cascade modulator with scaleABCD state scaling. The audio band sits in the notch; everything above it is the ultrasonic energy the decimation filter has to reject.")

### The Limiter That Dissolved

The plan mandated a digital limiter before the 1-bit truncator, on Schreier's §13.2.2 grounds: error-feedback gives NTF = 1 − H(z) and STF = 1 exactly, but overflow **wraparound** is catastrophic. Saturation is acceptable; wraparound is not.

I scaffolded one. It was provably inactive at −6 dBFS (zero clips) and reproduced the exact NTF — and it **clipped spuriously above nominal**. The reason took me embarrassingly long: the controllable-canonical states aren't physical integrator states, so a fixed threshold on them is meaningless. I was limiting a coordinate system, not a signal.

The fix was not a better limiter. It was building the real thing — a resonator-cascade CRFB with delsig-grade `scaleABCD` state scaling. Once the state-space is dynamic-range-scaled, **wraparound is structurally impossible** and no separate limiter is needed.

{{< notice note >}}
The limiter question didn't get solved. It got **dissolved** — by building the structure correctly, the problem stopped existing. The from-scratch NTF synthesis had also gone unstable at order 10, which was the real signal that I should stop reimplementing Schreier and go use Schreier's toolbox.
{{< /notice >}}

`python-deltasigma` is Venturini's BSD port of delsig, and it is a 2015-era package. It installs cleanly from PyPI and does not run at all under modern Python, numpy, or scipy. Seven separate incompatibilities: removed numpy scalar aliases, `fractions.gcd`, `collections.Iterable`, `numpy.distutils`, `scipy.signal.step2`, numpy 2.0's rejection of a *list* of index arrays as per-axis indexing in `stuffABCD`, and `scaleABCD` passing a float `N_sim` to `randn`.

**No file in the installed package is edited.** `dscompat.py` applies every fix at runtime, including a regex source-transform plus module re-exec for `stuffABCD`, delivered via a meta-path import hook so it lands regardless of import order. It no-ops if upstream ever fixes it, because it probes for the behaviour rather than checking a version string.

This is a provenance argument as much as a convenience one: the dependency stays a stock, checksummable PyPI artifact. There is no patched vendor tree to audit. And it was verified against a pristine upstream checkout — frozen vectors reproduce **bit-identical SHA256 payload digests** by both routes.

Final fixture capability floors, the NTF-theoretic integrated in-band noise (immune to the tone-leakage and limit-cycle artifacts that corrupt single-tone simulated SNR):

- **CRFB8 = −138.8 dBFS** → development fixture
- **CRFB10 = −148.1 dBFS** → final-ranking fixture
- $\lVert \mathrm{NTF} \rVert_\infty = 2.92$ dB $= 20\log_{10}(1.4)$ — modified Lee criterion honored

### The Oracle and the Vectors

`annexd.py` implements the normative chain at 352.8 kHz: D.1's 5th-order Butterworth LP at 50 kHz, D.4's paired 40 kHz HP and 100 kHz LP, the 0.85 Hz RMS integrator, and a D.3 modulation meter. Self-test hits every anchor — 0 dB SACD → −6.02, legal peak → −2.90, HF ceiling → −26.15, DC → −56.00, and cross-band rejection clean (D.4 on a 1 kHz tone reads −91 dB).

Seven frozen, checksummed DSD64 vectors, all modulating with zero overloads: `tone_1k_m6` (the 0 dB SACD reference), `tone_1k_m20`, `tone_10k_m6`, `tone_19k_m6` (worst-case top octave), `silence`, `ultrasonic_50k` (out-of-band stress that decode **must** reject), and `twotone_18_20k` for IMD. Payload digests are bit-identical across Python 3.12 → 3.14 at pinned numpy 2.4.4 / scipy 1.17.1.

![Analysis chain validation: coherent sampling with a −300 dB Dolph-Chebyshev window plus Parseval cross-check](/images/libdsddpcm/analysis_chain_validation.png "Analysis chain validation. Coherent sampling, Dolph-Chebyshev-300 dB window, Parseval error 0.0, floor below −340 dB. You validate the ruler before you measure with it.")

The analysis chain itself is validated to Saracon's published THD+N conditions — coherent sampling, Dolph-Chebyshev 300 dB window, Parseval cross-check — so the comparison is apples to apples rather than apples to marketing.

## Phase 3: The Sweep, and What It Falsified

The objective function was locked *before* the sweep ran, in writing, with the non-goals stated explicitly. This matters because it is very easy to let "steepest" or "most tap-efficient" quietly become the objective once you are staring at Pareto fronts.

**Enumerate → gate → score → rank.**

Five hard gates, pass/fail, no partial credit: unity DC gain, passband integrity, stopband rejection across the fold bands, linear phase, and length/latency budget. Survivors are scored on

$$J(h) = w_{pb} \cdot D_{pb}(h) + w_{sb} \cdot L_{sb}(h)$$

where $D_{pb}$ is passband flatness penalty and $L_{sb}$ is **ultrasonic leakage as measured through the Annex-D oracle** — not nominal stopband dB, but leakage as it actually reaches the meter. Transition steepness is never rewarded on its own; it enters only through whatever $L_{sb}$ it buys.

Non-goals, written down so I couldn't drift: not maximizing DR, not minimizing transition width, not favoring equiripple for tap efficiency.

Linear phase is locked, not merely preferred. Minimum-phase and IIR are *excluded from the sweep*. A linear-phase filter has constant group delay, so it preserves waveform shape and does not move peaks. True peak, inter-sample peak, and DR stay physically meaningful. Frequency-dependent group delay smears transients and shifts peak timing — corrupting exactly the metrics crête exists to measure.

![Filter Pareto front: quality versus tap count across four design methods](/images/libdsddpcm/filter_pareto.png "Pareto front, quality against taps, across equiripple / Kaiser / Blackman-Harris / firls.")

![The money plot: DSD PSD with candidate magnitude responses overlaid and the D.4 band marked](/images/libdsddpcm/money_plot.png "The money plot. Shaped DSD noise underneath, candidate |H(f)| on top, D.4's 40–100 kHz band marked. This picture is the whole argument in one frame.")

### Findings

The widened grid ran 75 designs, lengths 127 to 4095, across per-method parameters at both q31 and q15, on the official CRFB10 fixture.

**Equiripple won, and I had predicted it wouldn't.** My own filter-methods document argued that equiripple's defining property — uniform passband ripple ±δp — *is* in-band coloration, a frequency-dependent gain error across the entire audio band, and that Kaiser or `firls` should therefore be preferred for the measurement case. The document did include the escape clause: *unless* the equiripple design is run with a tight passband-ripple weight, at which point its tap-count advantage typically erodes. Run with a passband weight of 30, `eq383` hits 152.6 dB with a flat passband and wins on the joint metric at 383 taps against `firls`'s 767. The caveat was right and the prediction was wrong, which is a good ratio for a document written before the data.

**Parks–McClellan has a convergence boundary between 383 and 511 taps** at this spec. It simply fails to converge above it — a concrete demonstration of the classic Remez limitation, and the reason the extreme-tap end of the sweep uses windowed-sinc and `firls` exclusively.

**int16 caps at 69.2 dB and cannot meet a 90 dB gate.** It stayed in the sweep only to quantify the knee, and it did its job by failing informatively.

**The oracle-visibility knee sits at $L_{sb} \approx 150$ dB.** Beyond that, the decode floor (−159.5 dBFS, common to all candidates) hides any further improvement. The objective saturates at the top of the grid, so tap count becomes the Pareto tiebreak. This is exactly the "additional taps change nothing the oracle can see" prediction the plan asked the sweep to falsify — and it wasn't falsified. Extra taps beyond the knee only lengthen pre- and post-ring at levels nothing can measure, and grow group delay.

![Decode scoring across candidates](/images/libdsddpcm/decode_scoring.png "Decode-domain scoring. Among gate-passers, decoded in-band noise is common-mode rather than filter-set.")

![Decode verification: 50 kHz ultrasonic stimulus rejected rather than folded](/images/libdsddpcm/decode_verify.png "End-to-end decode verification. The 50 kHz ultrasonic stress vector produces −57 dBFS of in-band residual — rejected by the cascade, not folded into the band.")

There was also a **noise-transparency finding** that reframed the ranking: among gate-passers, decoded in-band noise is common-mode (modulator plus dither) and **not** filter-determined. A stopband beyond 90 dB pushes folded ultrasonic noise below the modulator floor entirely. So the ranking isn't noise-limited among survivors — it is decided by passband flatness, worst-case $L_{sb}$, and tap efficiency, kept in the response domain where the metrics stay measurement-clean.

The stopband spot-check by decode is the part that ties the two domains together. An undithered 26 kHz tone folds to 18.1 kHz, and the decoded spur equals $-6.02 + 20\log_{10}|H(26\,\mathrm{kHz})|$. Measured against predicted agree to ≤ 0.3 dB. The deep filters are measurement-floor-limited around −158 dBFS and are correctly flagged as such rather than credited with the floor.

## Phase 4: The Library

The C core lives in `src/dsddpcm.c` behind a locked `include/dsddpcm.h`.

- **Stage 1** is an integer byte-LUT — byte→partial-sum tables, integer coefficients, **bit-exact across platforms**. This is not just correctness hygiene; it passes FFmpeg's `fate` suite trivially and beats every float-based decoder on reproducibility. It is an adoption asset.
- **Stage 2** is double-precision, with golden `1/sum` scaling per stage.
- **Streaming and stateful**, carrying FIR delay-line state across arbitrary block sizes, reentrant, thread-safe per instance, no global mutable state, no allocation in the hot path.
- **Group delay is reported** through the API so callers can compensate latency and trim pre/post-ring for true-peak alignment.

DSD64, DSD128 and DSD256 are supported (`fir1_32` for DSD256 = CLS N=320, wo = 0.013877334, 140.9 dB). The 44.1 family is the primary integer path; 48/96/192 kHz interop rides one shared rational up-80 / down-147 Kaiser-150 prototype (`R48_150`, 17455 taps, 149.3 dB q31) via polyphase push.

Shipped filter enum:

| enum | design | q31 stopband | group delay |
|---|---|---:|---:|
| `DEFAULT` / `EQUIRIPPLE` | `eq383/w30` | 152.6 dB | 104.0 |
| `LEASTSQUARES` | `firls767/w10` | 151.5 dB | 200.0 |
| `KAISER` | `kaiser4095/a150` | 148.9 dB | 1032.0 |
| `BLACKMAN_HARRIS` | — | `ERR_UNSUPPORTED` | — |

The Kaiser entry carries an honest asterisk: 169.1 dB in float, **int32-floored to 148.9**. The coefficient wordlength, not the design, is the wall. Blackman-Harris returns an explicit unsupported error rather than silently substituting something — a design that can't meet the gate should say so at the API boundary.

CMake builds `libdsddpcm.so.0` with `dsddpcm.pc`, a `dsddpcm::dsddpcm` target, and an optional CLI that does raw-DSD→WAV.

### The Bug the Comparison Found

I only found this because I ran the comparison, which is an argument for running comparisons.

The first comparison run exposed a shared **−109.7 dB ceiling** in the 70.3 kHz fold band — which maps to 14–22 kHz of audio, squarely where it matters. The cause was the inherited middle halfband `fir2_2`, whose CLS constraint is −109 dB. Both of my middle 2:1 stages were sitting on a wall I had imported from the incumbent recipe without questioning it, because it had passed the parity gate. Passing a parity gate means you reproduced someone's filter faithfully. It says nothing about whether their filter was good.

`hb43_150` — a 43-tap Kaiser half-band at ≥ 148 dB, a true halfband — replaced `fir2_2` in **both** middle slots. Composite worst fold band: **109.7 → 138.9 dB**, now limited by `fir1_8`'s own ~141 dB stage-1 stopband instead.

## The Measured Comparison

Ground rules first, because a comparison without them is marketing. The **Direct chain is excluded on purpose** — libdsddpcm regenerates `fir1_64` byte-exactly, so Direct decode is *identical* to `dsd_lut.hpp` by construction. And since dsd2pcm ships no path to 44.1 kHz at all, its 96-tap stage-1 is given libdsddpcm's own tail, which isolates its filter and is generous to it. Its stage-1 is normalized to unity DC so levels compare like for like.

**Response domain, composite DSD64 → 44.1 kHz:**

| chain | DC error | passband ripple | worst fold-band atten |
|---|---|---|---|
| libdsddpcm default (`eq383`) | **0.00 ppm** | 0.0000 dB | **138.9 dB** |
| libdsddpcm reference (`kaiser4095`) | **0.00 ppm** | 0.0000 dB | **138.9 dB** |
| `dsd_lut.hpp` multistage (as shipped) | +7.13 ppm | 0.0001 dB | 109.6 dB |
| dsd2pcm stage-1 + libdsddpcm tail | 0.00 ppm | 0.0011 dB | 149.9 dB |

**Decode domain, frozen CRFB10 vectors, Annex-D methodology:**

| chain | 1 kHz level | ultrasonic-50k residual | 26 kHz fold spur (→18.1 kHz) |
|---|---|---|---|
| libdsddpcm default (`eq383`) | −6.02 dBFS | −57.3 dBFS | **−165.0 dBFS** |
| libdsddpcm reference (`kaiser4095`) | −6.02 dBFS | −57.2 dBFS | **−167.9 dBFS** |
| `dsd_lut.hpp` multistage | −6.02 dBFS | −57.3 dBFS | −120.6 dBFS |
| dsd2pcm stage-1 + libdsddpcm tail | −6.02 dBFS | −57.3 dBFS | −166.3 dBFS |

![Composite magnitude responses of all four compared chains](/images/libdsddpcm/compare_response.png "Composite responses. The incumbent multistage ceiling in the fold bands is visible as a plateau.")

![Decoded ultrasonic stress across the compared chains](/images/libdsddpcm/compare_decode.png "Decoded ultrasonic stress. The 26 kHz → 18.1 kHz fold spur is the audible-critical number.")

### Reading These Numbers Honestly

**The audible-critical difference is the first fold band.** An ultrasonic tone at 26 kHz aliases to 18.1 kHz — in-band, audible. libdsddpcm rejects it to −165 dBFS against the incumbent's −120.6. That is a **44 dB improvement exactly where aliasing is audible**, at a comparable tap cost.

**Exact unity DC gain.** +7.13 ppm versus 0.00. Again: convention versus contract.

**dsd2pcm's stage-1 is not the weak link — its missing tail is.** Given a proper tail, Gesemann's 96-tap ÷8 filter performs respectably, and in fact measures *deeper* than my `fir1_8` in the worst fold band (149.9 dB vs ~141) because its ÷8 spec has a very wide transition. I am not going to hide that. The real-world problem the table can't show is that dsd2pcm stops at 352.8 kHz, so every fork improvises its own unvalidated path down to audio rates. *That improvised tail* is where the ecosystem's quality actually goes — and it is precisely what libdsddpcm ships, validates, and proves.

**What no table shows**: byte-exact integer stage-1 across platforms, streaming chunk-invariance, group-delay reporting, an Annex-D oracle, frozen checksummed vectors, and a regeneration gate proving coefficient provenance. None of the incumbents publish any of it.

Verification is green across the board: Direct bit-exact at 0.0, multistage ~1e-15, all filter variants, 48k against `scipy.upfirdn`, DSD256 against reference on a random stream, and chunked output **byte-identical** to one-shot.

## What Is Still Broken, Missing, or Embarrassing

{{< notice warning >}}
**I have not tested this on a single real DSD file.** There is no DSD material on this machine. Every number above comes from synthetic vectors, which are ground truth for *correctness* — but agreement with real material is a separate claim I have not yet earned.
{{< /notice >}}

The rest of the honest list:

- `tools/realdsd.py` is specified (DSF is LSB-first bits, DFF is MSB-first) but unrun. When material arrives: null each filter against the KAISER reference, report true-peak and DR deltas. Agreement evidence only — synthetic vectors stay ground truth.
- The CLI's whole-file RMS reads low against the expected −6.02. This is group-delay transient dilution, not a decode error; steady-state is exact, and the Kaiser variant is worst affected with its 1032-sample delay. Still a bad first impression for anyone who runs the CLI and reads one number.
- `fir1_8` is now the composite bottleneck at ~141 dB. Deepening it to 150+ is provably possible — dsd2pcm's stage-1 gets 149.9 — and it is queued.
- The generator's bounded residuals are float-sensitive at the last LSB across numpy and scipy versions: `fir1_8`'s bound is 23 on Python 3.12 and 24 on 3.14 with numpy 2.4.4. Documented rather than papered over.
- The crête consumer link isn't wired yet. FFmpeg is a post-release lane.

## What I Actually Learned

Three things, and none of them are about DSD specifically.

**Reproduce before you innovate.** The generator gate was the highest-value work in the project and it produced zero shipped code. It bought a trustworthy tool, a falsified hypothesis (Parks–McClellan), an identified design family, and — indirectly — the middle-halfband bug, because I only knew what `fir2_2` cost me once I could regenerate it and read its constraint level off the fit.

**Build the second oracle.** The 24-LSB Parks–McClellan gap looked exactly like tool noise. It took an independent PM implementation agreeing to 4e-13 to prove it was structural. One tool tells you a number. Two tools tell you whether to believe it.

**Read the spec's units before you spend three weeks chasing them.** The "−150 dBFS floor" cost me real time because I read a spectral-density figure as an integrated one, and then went looking for something physically impossible. The moment the integrated number came back at −121.3 and I recognized it as DSD64's own dynamic range, the whole thing resolved. The measurement was never wrong. My reading of the target was.

And the meta-lesson, which is the same one I keep re-learning across audio and physics both: **choosing the right observable matters as much as measuring carefully.** DR is the wrong observable for filter quality — it rewards the failure. Fold-band rejection through an Annex-D-compliant meter is the right one. Everything downstream of getting that straight was, comparatively, just work.

v0.1.0 is tagged, BSD-2-licensed, and builds cold. It decodes DSD to PCM, and — unlike everything else I could find — it shows you why you should believe it did so correctly.

---

*Written listening to Linkin Park's* Hybrid Theory*, Elvis Presley's* Blue Hawaii*, and the Eagles'* Hotel California *— a sequencing decision with roughly as much methodological justification as reading a spectral-density spec as an integrated one.*

[^1]: [libdsddpcm on Codeberg](https://codeberg.org/abksh/libdsddpcm)

[^2]: Philips, *SACD System Description (Scarlet Book), Annex D — Audio Signal Requirements (Normative)*, March 2003; transcribed in the Saracon manual, Appendix C, and corroborated by the Merging/Pyramix SACD Production Guides (2004 and 2009 editions).

[^3]: [dsd2pcm](https://github.com/clivem/dsd2pcm) — Sebastian Gesemann's BSD decoder, the incumbent that most of the ecosystem forks.

[^4]: R. Schreier and G. C. Temes, *Understanding Delta-Sigma Data Converters* — the modified Lee criterion (§4.6) and the error-feedback wraparound warning (§13.2.2).

[^5]: [python-deltasigma](https://github.com/ggventurini/python-deltasigma) — G. Venturini's BSD port of Schreier's Delta-Sigma Toolbox.

[^6]: I. W. Selesnick, M. Lang and C. S. Burrus, "Constrained least square design of FIR filters without specified transition bands" — the CLS family that turned out to be behind four of the five incumbent tables.
