+++
title = 'Audiocheckr Deep Dive'
date = '2025-11-29T14:55:15+01:00'
draft = false
useAlpine = false
loadNerdFont = true
tags = ["rust", "audio", "dsp", "ci-cd", "jenkins", "testing", "fft", "spectral-analysis"]
+++

## Introduction

Over the past few weeks, I've been developing **audiocheckr** - an advanced audio analysis tool designed to detect fake lossless files, transcodes, upsampled audio, and various audio quality issues. Unlike many audio analysis tools that rely on machine learning, audiocheckr uses pure digital signal processing (DSP) algorithms to identify subtle artifacts left behind by lossy compression.

The project has evolved significantly, currently sitting at **v0.2.1** with a comprehensive test suite, Jenkins CI/CD pipeline, and detection capabilities spanning multiple codec types including MP3, AAC, Opus, and Vorbis.

## What Problem Does audiocheckr Solve?

The audiophile community faces a persistent problem: files marketed as "lossless FLAC" or "high-resolution audio" that are actually transcoded from lossy sources. These fake lossless files waste storage space, bandwidth, and money, while providing no quality improvement over the original lossy source.

audiocheckr addresses this by analyzing audio files for telltale signs of lossy compression:
- **Spectral cutoffs**: MP3/AAC files have characteristic "brick wall" frequency cutoffs
- **Bit depth padding**: 16-bit audio padded to appear as 24-bit
- **Upsampling artifacts**: CD-quality audio upsampled to 96kHz or 192kHz
- **Codec artifacts**: Pre-echo, phase discontinuities, and joint stereo encoding patterns

## Core Detection Capabilities

### Spectral Analysis

The heart of audiocheckr is its multi-frame FFT spectral analysis engine. Unlike simple single-window analysis, it examines **30 frames spread across the entire track** to avoid being fooled by quiet passages or transients.

{{< figure src="/images/input96_spectrogram.png" alt="Spectrogram of genuine lossless file" caption="Spectrogram of a genuine 24-bit/96kHz FLAC file showing full frequency content up to 48kHz Nyquist" >}}

The detection algorithm looks for:
- **Derivative-based cutoff detection**: Finds where the spectrum "falls off a cliff"
- **Rolloff steepness measurement**: Calculates dB/octave decline rate
- **Brick-wall detection**: Sharp cutoffs characteristic of transform codecs
- **Shelf pattern detection**: AAC's characteristic frequency shelf before cutoff
- **Encoder signature matching**: Compares against known codec patterns

{{< figure src="/images/test96_mp3_v4_upscaled_spectrogram.png" alt="Spectrogram of MP3 transcode" caption="Spectrogram of the same audio transcoded through MP3 320k and re-encoded to FLAC - note the sharp cutoff at ~20.5kHz" >}}

### Codec-Specific Detection

Each codec leaves distinct fingerprints:

| Codec | Cutoff Range | Rolloff Characteristics | Detection Method |
|-------|--------------|------------------------|------------------|
| **MP3** | 15-20.5 kHz | Brick-wall, >50 dB/oct | Steep cutoff + brick-wall |
| **AAC** | Variable | Shelf pattern before cutoff | Shelf detection algorithm |
| **Opus** | 8/12/20 kHz | Very sharp at mode boundaries | Specific frequency matching |
| **Vorbis** | 12-19 kHz | Soft rolloff (15-45 dB/oct) | No brick-wall, quality estimation |

{{< figure src="/images/input96_spectrogram.png" >}}
{{< figure src="/images/test96_mp3_v4_upscaled_spectrogram.png" >}}
{{< figure src="/images/test96_aac_128_upscaled_spectrogram.png" alt="Codec comparison spectrograms" caption="Side-by-side comparison showing genuine lossless (top), MP3 320k (center), and AAC 256k (bottom) - note the different cutoff characteristics" >}}

### Bit Depth Analysis

One of the more sophisticated detections involves identifying 16-bit audio padded to appear as 24-bit. This uses **four independent methods** with weighted voting:

1. **LSB Precision Analysis**: Examines trailing zeros in 24-bit scaled samples
2. **Histogram Analysis**: True 24-bit has ~256× more unique values
3. **Quantization Noise Analysis**: Measures noise floor (-144 dBFS for 24-bit vs -96 dBFS for 16-bit)
4. **Value Clustering**: 16-bit padded samples cluster on multiples of 256

### The High Sample Rate Challenge (v0.2.1 Fix)

A critical issue emerged during testing: **massive false positive rates on high-resolution files**. The problem was ratio-based detection - a genuine 96kHz file with musical content up to 20kHz has a cutoff ratio of only 42%, well below the old 85% threshold.

The v0.2.1 solution uses **absolute frequency thresholds** for files ≥88.2kHz:
- Content up to 22kHz is considered **normal** regardless of sample rate
- Requires **positive codec identification** (brick-wall + steepness pattern) before flagging
- No default fallback assumptions
- Maintains ratio-based detection only for standard sample rates (44.1/48kHz)

## Test Infrastructure

### Comprehensive Test Suite

The project includes an extensive regression test suite with **279 test cases** across 24 categories:

- **Control_Original**: 37 genuine lossless files (various genres, bit depths, sample rates)
- **MP3 variants**: 128k, 192k, 320k, V0 VBR, V4 VBR, 64k edge cases
- **AAC variants**: 128k and 256k
- **Opus variants**: 64k, 128k, 192k
- **Vorbis variants**: Q3 (low) and Q7 (high)
- **Bit depth tests**: 16-bit padded to 24-bit
- **Sample rate tests**: 44.1→96kHz, 48→96kHz upsampling
- **Generation loss**: Multiple generation transcodes
- **Edge cases**: Multiple resampling, low bitrate stress tests

{{< figure src="/images/histogram.png" alt="Test results heatmap" caption="Heatmap visualization showing detection success rates across all 24 test categories" >}}

### Current Test Results

The latest regression run shows:

```text
Total Tests: 279
Passed: 237 (84.9%)
Failed: 42
False Positives: 36
False Negatives: 6
```


**Results by Category** (top performers):
- ✅ Opus_192_High: 8/8 (100%)
- ✅ BitDepth_16to24: 21/21 (100%)
- ✅ Vorbis tests: 4/4 (100%)
- ✅ MP3_V0_VBR: 3/3 (100%)
- ⚠️ Control_Original: 1/37 (3%) - **major area for improvement**
- ✅ MP3_320_HighQuality: 36/37 (97%)
- ✅ AAC_256_High: 36/37 (97%)

The high false positive rate on genuine files is a known issue being actively addressed in the next version.

### Diagnostic Analysis

Beyond pass/fail testing, I've implemented diagnostic tools that compare spectral characteristics between genuine and transcoded files:

```text
Cutoff Ratio (% of Nyquist):
Control average: 57.9%
MP3 128k average: 25.3%
Difference: 32.5 percentage points

Rolloff Steepness (dB/octave):
Control average: 17.5 dB/oct
MP3 128k average: 65.3 dB/oct
Difference: -47.7 dB/oct
```


These metrics help tune detection thresholds and understand edge cases where genuine files have naturally limited bandwidth.

## Jenkins CI/CD Pipeline

### Pipeline Architecture

The project uses a sophisticated Jenkins pipeline with multiple test modes:

#### Test Types:
- QUALIFICATION: Full test suite on every push
- REGRESSION: Standard regression tests
- REGRESSION_GENRE: Genre-specific comprehensive testing
- DIAGNOSTIC: Deep analysis and threshold tuning


**Build Configuration**:
- Parallel setup: Tools installation + Source checkout
- Rust 1.91.1 with Cargo build system
- MinIO (mc) integration for test asset storage
- Optional ARM cross-compilation support
- 90-minute timeout for long-running test suites

### Pipeline Stages

1. **Pre-flight**: Determine test type (push vs manual trigger)
2. **Setup & Checkout**: Parallel tool setup and git checkout
3. **Build**: Compile x86_64 and optionally ARM64 targets
4. **Test Execution**: Run selected test suite with parallel execution
5. **Artifact Collection**: Store binaries and test results
6. **SonarQube Analysis**: Code quality and security scanning

Recent builds show stable compilation times around **13-17 seconds** for the full Rust project.

### Test Execution

The regression genre suite runs with **8 parallel threads**, processing all 279 test files in approximately **36 minutes**:

```text
Progress: 10/279 tests completed
Progress: 20/279 tests completed
...
Progress: 270/279 tests completed
```


This parallelization is critical for rapid iteration during algorithm development.

## Technical Implementation

### Technology Stack

- **Language**: Rust (edition 2021, v1.91.1)
- **Audio I/O**: Symphonia (comprehensive codec support)
- **DSP**: Custom FFT-based analysis with rustfft
- **Spectrograms**: Image processing with imageproc
- **CLI**: Clap for argument parsing
- **Testing**: Custom test harness with parallel execution
- **CI/CD**: Jenkins with GitHub webhook integration
- **Code Quality**: SonarQube Community Edition

### DSP Concepts Applied

The implementation leverages advanced signal processing techniques:

1. **Short-Time Fourier Transform (STFT)**: Time-frequency analysis across multiple windows
2. **Mel Filterbank**: Perceptually-motivated frequency scaling for spectrograms
3. **Windowing Functions**: Hann and Blackman-Harris windows for spectral leakage reduction
4. **Sinc Interpolation**: Band-limited upsampling for true peak detection
5. **Hilbert Transform**: Envelope extraction for transient detection
6. **Phase Vocoder**: Instantaneous frequency analysis for codec artifact detection
7. **ITU-R BS.1770**: Standards-compliant true peak measurement

### Performance Characteristics

- Typical analysis: **20-25 seconds per file**
- Phase analysis adds: ~1-2 seconds
- Spectrogram generation: ~1-3 seconds
- Memory usage: ~100MB for a 5-minute track
- Supports parallel batch processing

## Usage Examples

### Basic Detection

#### Analyze a single file

```shell
audiocheckr -i audio.flac
```
{{< figure src="/images/Console-Logs-Minimal.png" >}}


### Full Analysis with Spectrogram

```shell
audiocheckr -i suspicious.flac -s -u --stereo --transients -v
```

Generates:
- Detailed console report
- Spectrogram PNG image
- Upsampling analysis
- Stereo width analysis
- Pre-echo detection
{{< figure src="/images/Console-Logs.png" >}}
{{< figure src="/images/input96_spectrogram.png" >}}

### Batch Analysis

#### Scan entire music library

```shell
audiocheckr -i /music/library/ --json > results.json
```
To process results:

```shell
jq '.[] | select(.is_likely_lossless == false) | .path' results.json
```
or just use your favourite tool like `grep` or `Select-String` depending on which shell you are using.


## Roadmap and Future Development

### Short Term (v0.3.0)

**Algorithm Improvements**:
- ✅ Address false positive rate on Control_Original files
- ⬜ Improve AAC 256k detection (currently 1 false negative)
- ⬜ Better handling of naturally band-limited content (jazz, classical, ambient)
- ⬜ Enhanced Opus detection for lower bitrates

**Testing**:
- ⬜ Expand test suite to 500+ files
- ⬜ Add more genre diversity
- ⬜ Blind listening validation for borderline cases

### Medium Term (v0.4.0)

**Web UI**:
- ⬜ Browser-based interface for analysis
- ⬜ Real-time spectrogram visualization
- ⬜ Batch upload and processing
- ⬜ Historical result tracking
- ⬜ Export reports as PDF/HTML

**Automated Scanning**:
- ⬜ File system watcher for continuous monitoring
- ⬜ Music library integration (Navidrome, Airsonic, Plex)
- ⬜ Scheduled batch scans
- ⬜ Email notifications for suspicious files

### Long Term

**Advanced Features**:
- ⬜ DSD (Direct Stream Digital) support
- ⬜ Machine learning augmentation for edge cases
- ⬜ Perceptual quality scoring beyond technical metrics
- ⬜ Codec identification (not just "lossy" but "MP3 from LAME 3.100")
- ⬜ Restoration recommendations for damaged files

**Platform Expansion**:
- ⬜ Docker container for easy deployment
- ⬜ REST API for integration with other tools
- ⬜ Plugin architecture for custom detectors

## Lessons Learned

### DSP Challenges

**The Ratio Trap**: Early versions used simple ratio-based detection (cutoff frequency / Nyquist frequency), which failed catastrophically on high-sample-rate files. The fix required understanding that **absolute frequency content matters** - a 96kHz file with 20kHz content is perfectly normal, even though that's only 42% of Nyquist.

**False Positive Whack-a-Mole**: Improving one detection category often creates false positives in another. The solution has been multi-signal requirements - never flag based on a single indicator, always require corroborating evidence.

**Edge Case Hell**: The test suite revealed countless edge cases: files with legitimately limited bandwidth, live recordings with unusual spectral characteristics, and mastering techniques that mimic codec artifacts.

### Testing Philosophy

**Test Everything**: The 279-file test suite has been invaluable. Every algorithm change is immediately validated against the entire corpus.

**Diagnostic Tools**: Creating comparison tools that visualize why files pass or fail has been crucial for tuning thresholds.

**Parallel Execution**: 36-minute test runs would be unbearable in serial - 8-thread parallelization keeps iteration times reasonable.

### CI/CD Integration

**Automation Saves Sanity**: Jenkins automation means every push gets tested immediately. No more forgetting to run tests before committing.

**SonarQube Integration**: Static analysis caught several potential bugs and code quality issues early.

**Build Artifacts**: Automatic binary publishing to GitHub Releases means users always have access to the latest version. **TO BE IMPLEMENTED SOON!!!**

## Conclusion

audiocheckr has evolved from a simple spectral analyzer into a comprehensive audio quality detection tool with sophisticated DSP algorithms, extensive testing, and production-ready CI/CD. The current **84.9% accuracy** on the test suite shows promise, but the **36 false positives** on genuine files highlight areas needing improvement.

The project demonstrates that **pure DSP approaches can compete with machine learning** for audio quality detection, with the advantages of transparency (you can see exactly why a file was flagged) and no training data requirements.

For audiophiles and music archivists, tools like audiocheckr provide essential quality assurance in an era where fake lossless files proliferate across music stores and torrent sites.

## Resources

- **Source Code**: [github.com/abalajiksh/audiocheckr](https://github.com/abalajiksh/audiocheckr)
- **Test Suite**: 279 files across 24 categories (not publicly distributed due to copyright)
- **License**: GNU AGPL v3.0

---

*Have you encountered fake lossless files in your music library? Try audiocheckr and let me know the results! Contributions and bug reports are always welcome.*
