+++
date = '2025-08-03T12:21:42+02:00'
draft = true
title = 'Self Hosting Music Library and DSEE Shenanigans'
useAlpine = false
tags = [

]
+++

## Introduction

Recently, I have been hoarding music libraries and adding them to my Plex Server (self-hosted, and I already use it for Movies and TV Shows): Vodafone Internet sucks because of the frequent network outages in Germany. I am ensuring they are good-quality source files with either `16-bit FLAC` or `24-bit FLAC`. A downside of that is that it hogs a lot of storage space. Here is a screenshot of current music library I have hoarded so far.

![](/images/plexMusicLibraryStats.png)

Can you guess how much storage space this takes up?
{{< details summary="Here is the answer" >}}
Approximately 450GB.
{{< /details >}}


A big problem with self-hosting a media library is storage; and it fills up pretty fast. And storage is not cheap; it gets expensive pretty quickly. Why do I need high-quality files when streaming services[^1][^2] do media compression? Does it matter that low audio quality makes the listening experience bad?

![](/images/spotify.png)
![](/images/apple.png)

The short answer is the experience doesn't change with compression. We cannot distinguish the quality between lossless and lossy transcoding with normal headphones and sound bars. However, few of my friends and I have gone down the rabbit hole of audiophiles and love listening to music in high-resolution. How do we do that, you ask? We use IEMs (In-Ear-Monitor); these amplify all parts of the sound, so we can listen to every single instrument and audio track the artist has mastered for their audio.

If you have been to a live concert, you can see the singers or DJ using a special earphone or headphone; these are IEMs. Crazy enough, the fact is that you can acquire these devices for a fraction of flagship headphones or earphones, and these sound astronomically better than the aforementioned flagships. What fraction, you ask? You can acquire a cheap IEM for around 20 euros, and good quality ones cost around 100 euros. I admit there are IEMs that cost around 500 euros to 4k euros, but in my belief, those are catering to marginal gains; and I am half-deaf to notice them. I own a Sennheiser Momentum True Wireless 4 (4th Gen) and an LG sound bar (2.1; stereo plus subwoofer) that has a combined price of 350 euros (an estimate). The IEM I own just cost around 90 euros (Truthear Hexa: in case you are wondering). This IEM sounds much better than the aforementioned devices, provided with a Hi-Res Audio. However, I saw something in the playback settings of my Sony Xperia 1 V, and got me curious.

![](/images/audioSettings.png)

I see DSEE Ultimate[^3], Sony's proprietary up-scaling technology for music. So, I set out to do an experiment. I want to know if this up-scaling can make compressed audio formats sound close to Hi-Res Audio.

## Generating Formats

I picked up a song I have been listening in repeat for a couple of weeks now to do this test: [Save Your Tears - song and lyrics by The Weeknd | Spotify](https://open.spotify.com/track/5QO79kh1waicV47BqGRL3g?si=5d6f27649ff74b8e). I bought the lossless version of the song online and loaded it onto my Plex server. Here is the information:

![](/images/plexMediaInfo.png)

Now, I want to generate other lossless and lossy files, namely: `16-bit FLAC`, `AAC`, `OGG VORBIS` and everyone's favourite `MP3` . I use the legendary `ffmpeg` to transcode the original sourcefile I named as `24bit_sample.flac` to the abovementioned formats.

![](/images/beforeTranscode.png)

### Convert 24-bit FLAC to 16-bit FLAC:

{{< highlight text >}}
ffmpeg -i 24bit_sample.flac -c:a flac -sample_fmt s16 -map_metadata 0 output_16bit.flac
{{< /highlight >}}

### Convert 24-bit FLAC to AAC:

{{< highlight text >}}
ffmpeg -i 24bit_sample.flac -c:a aac -b:a 192k -map_metadata 0 output.aac
{{< /highlight >}}

### Convert 24-bit FLAC to MP3:

{{< highlight text >}}
ffmpeg -i 24bit_sample.flac -c:a libmp3lame -q:a 2 -map_metadata 0 output.mp3
{{< /highlight >}}

### Convert 24-bit FLAC to OGG:

{{< highlight text >}}
ffmpeg -i 24bit_sample.flac -c:a libvorbis -q:a 6 -map_metadata 0 output.ogg
{{< /highlight >}}

### Explanation:

- `-i 24bit_sample.flac`: Specifies the input file.
- `-c:a`: Specifies the audio codec to be used.
  - `flac`, `aac`, `libmp3lame`, and `libvorbis` are the codecs for FLAC, AAC, MP3, and OGG respectively.
- `-sample_fmt s16`: For FLAC conversion, this option specifies that the output should be in 16-bit format.
- `-b:a 192k`: Sets the audio bitrate to 192 kbps for the AAC output (adjustable as needed).
- `-q:a`: Sets the quality for MP3 and OGG formats. Higher values generally indicate better quality.
- `-map_metadata 0`: This option ensures that metadata from the input file is mapped to the output file.

![](/images/afterTranscode.png)

![](/images/fileSizes.png)

As you can see, from the original `43MB` the file sizes reduced drastically. A quick note: DSEE Ultimate is a CPU-intensive algorithm and so is transcoding the audio.

## Setup - Hardware and Software

Sony smartphones come with a preloaded music player, just like the old Google Music Player that turned into YouTube Music. I could play the audio-files via Spotify as well for this experiment; however, I used the music player.

![](/images/sonyMusicPlayer.png)

The Sony Xperia 1 V comes with a decent DAC (Digital-to-Analog Converter), unlike the current flagship Sony Xperia 1 VII (which has a Walkman DAC, so much better than mine) and a `3.5mm` audio jack. So, I connected my IEM to this audio jack. If you don't have an audio-jack like mine does (you probably don't have one), you may try a Lightning/USB-C to `3.5mm` audio jack adapter based on the smartphone you own. Or if you are crazier than that, you may try this setup[^4] by connecting an external DAC to your smartphone. If you try this, it will melt your battery; I have warned you. Now we are ready to do the testing.

## Spectrum Analysis

Prior to sharing the results with you; which are not scientific, and if you remember everything I wrote in this article, I am half-deaf, I would like to do an analysis that can show the differences to the different formats of audio we transcoded so far.

Out of all the bad financial decisions I make every year, here is one. I own a copy of Presonus Studio One 6 Artist[^5]. I also have a copy of SNAP - A Spectrum Analyzer[^6] pre-installed on my computer.

![](/images/DAWSetup.png)

As you can see above, I have set up all the audio files in the workspace and connected individual sources to the Spectrum Analyser (did I mention that this is free? Also, you can do this in GarageBand if you own a Mac).

### First Test

Here, the Frequency is smoothed out to 1/6th of the Octave; can't observe granular details, but good enough to show distinctions.

![](/images/smoothSpecAnalysisSetting.png)

Here is the playback: I attached the GIF file to display, but you can download the screen recording [here](/downloads/smoothSpecAnalysis1.mkv).

![](/images/smoothSpecAnalysis1.gif)

With keen eyes, you can observe the lower-end and the high-end frequencies being clipped in the `AAC`, `OGG VORBIS` and `MP3` formats. Here is the screenshot for better clarity.

![](/images/smoothSpecAnalysis.png)

In this, we can't visually tell the difference (at-lest for me) between `24-bit FLAC` and `16-bit FLAC`. We proceed with the second test.

### Second Test

Now, I have switched off smoothing, as you can see below:

![](/images/rawSpecAnalysisSetting.png)

Here is the output:

![](/images/rawSpecAnalysis1.gif)

Again, video file is available [here](/downloads/rawSpecAnalysis1.mkv).

![](/images/rawSpecAnalysis.png)

I can't distinguish between `24-bit FLAC` and `16-bit FLAC`. One reason is that we have set the average time to smooth the graph to 2500ms and our block size is smaller. Let us maximize the block size and reduce the average time to 100ms.

![](/images/highBitrateCompSetting.png)

Here is the result, comparing only `24-bit FLAC` and `16-bit FLAC`. Again, [here](/downloads/highBitrateComp.mkv) is the video file.

![](/images/highBitrateComp.gif)

Only difference I can spot is, frequencies with low `dB` is clipped more in `16-bit FLAC` than `24-bit FLAC`.

![](/images/highBitrateComp.png)

Time for a revelation: I am no audio engineer. Differences between `24-bit FLAC` and `16-bit FLAC` are present in noise floor, quantization round-offs, dynamic range and dithering. I am not experienced enough to spot such differences. So much for the scientific approach to distinguishing the differences.

## DSEE Ultimate

DSEE Ultimate[^7][^8] is a technology developed by Sony that stands for Digital Sound Enhancement Engine Ultimate. It is designed to upscale compressed audio files to near high-resolution audio quality. This technology aims to restore the high-frequency sounds lost during the compression process, providing a richer and more detailed audio experience. It is often featured in Sony's audio products, such as headphones and portable music players, to enhance the listening experience.

![](/images/dseeUltimate.png)

## Differences in Hearing

Now, I played all the audio formats in a lot of permutations and combinations to hear for differences. With lossy audio, I can tell differences in instrument loudness and some parts completely clipped out. My ears can't differentiate between `24-bit FLAC` and `16-bit FLAC`. When I turn on DSEE Ultimate in my mobile playback settings, the lossy compression sounds very similar to `24-bit FLAC`.

## What I Want To Do?

After this brief experiment, I have decided to keep hoarding `24-bit FLAC` for my favourite music, and only settle for `AAC` or `MP3` when there is no lossless format available to purchase (NNWW). Since DSEE Ultimate is capable to up-scale the lossy-compressed audio file, I am going to rely on that for cases when I can't have the best quality. I thought I am not gonna like to hear music with all instruments audible clearly; clearly I was wrong. If you made it this far, I hope this article is of some use to you.

[^1]: https://support.spotify.com/us/article/audio-quality/
[^2]: https://support.apple.com/en-us/118295
[^3]: https://www.sony.co.uk/electronics/support/articles/00230269
[^4]: https://www.reddit.com/r/DigitalAudioPlayer/s/kmHtVrzyX9
[^5]: https://www.presonus.com/pages/studio-one-pro
[^6]: https://www.voxengo.com/product/span/features/#nav-tabs
[^7]: https://www.reddit.com/r/sony/comments/j604yi/what_is_the_difference_between_dsee_extreme_dsee/?rdt=61105
[^8]: https://www.audiosciencereview.com/forum/index.php?threads/what-does-dsee-hx-ai-dsee-ultimate-dsee-extreme-do.14832/