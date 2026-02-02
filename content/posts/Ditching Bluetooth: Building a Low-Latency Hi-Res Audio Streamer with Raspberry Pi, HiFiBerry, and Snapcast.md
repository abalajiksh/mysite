---
title: "Ditching Bluetooth: Building a Low-Latency Hi-Res Audio Streamer with Raspberry Pi, HiFiBerry, and Snapcast"
date: 2026-02-02T10:00:00+01:00
draft: false
tags: ["audio", "raspberry-pi", "snapcast", "pipewire", "hifiberry", "network-streaming", "low-latency"]
description: "How I built a multi-room audio system using a Raspberry Pi with HiFiBerry Digi+ Pro, replaced unreliable AirPlay with Snapcast, and optimized latency from 500ms down to 100ms."
---

## The Goal: Hi-Res Audio Without Bluetooth Limitations

I wanted to stream hi-res audio from my Fedora desktop to my living room soundbar—without the compression, dropouts, and latency of Bluetooth. Bluetooth's bandwidth limitations (especially with A2DP) cap quality, and the 200-300ms latency makes it unusable for video.

The solution: a **Raspberry Pi 4 with HiFiBerry Digi+ Pro hat** feeding my soundbar via S/PDIF, using **Snapcast** for network streaming. This setup gives me:
- **Uncompressed PCM audio** (no codec limitations)
- **100ms latency** (5x better than Bluetooth)
- **Future expandability** to multi-room and headless Plexamp streaming

## Why Not Bluetooth?

Bluetooth audio has fundamental limitations:

| Issue | Bluetooth A2DP | My Setup |
|-------|----------------|----------|
| **Codec** | SBC, AAC, aptX (lossy) | PCM (lossless) |
| **Bandwidth** | ~1 Mbps max | ~1.5 Mbps (uncompressed) |
| **Latency** | 200-300ms typical | 100ms achieved |
| **Range** | ~10m | Network-wide |
| **Dropouts** | Common on 2.4GHz WiFi | Rare on Ethernet/5GHz |

Bluetooth is convenient for portable devices. For a stationary soundbar, it's a bottleneck.


## Hardware Stack

- **Source**: Fedora Sway desktop with PipeWire
- **Streamer**: Raspberry Pi 4 with HiFiBerry Digi+ Pro hat
- **Output**: Soundbar via S/PDIF (TOSLINK)
- **Software**: Snapcast server/client, PipeWire `pw-cat`, `socat`

## The AirPlay Problem

Initially, I tried AirPlay (RAOP) using `shairport-sync`. It worked, but:

- **Dropouts** on congested WiFi
- **250-500ms latency** with no easy way to reduce it
- **No multi-room sync** without complex configurations
- **Apple ecosystem lock-in**—no easy Linux-to-Linux streaming

AirPlay was designed for convenience, not for low-latency, reliable streaming. I needed something better.

## Enter Snapcast

[Snapcast](https://github.com/badaix/snapcast) is a multi-room client-server audio player. The server streams audio to multiple clients, keeping them perfectly synchronized. It's codec-agnostic, network-efficient, and crucially: **configurable**.

### The Architecture
```text
[Fedora Desktop] --PipeWire/pw-cat--> [TCP] --> [Raspberry Pi: Snapserver] --Localhost--> [Snapclient] --ALSA--> [HiFiBerry S/PDIF] --> [Soundbar]
```

The Fedora desktop captures audio from PipeWire and sends it over the network. The RPi runs both snapserver (receiving the stream) and snapclient (playing it locally).

## The Latency Journey

Getting audio working was the easy part. Getting it *fast* was the challenge.

### Initial Setup: 500ms Latency

Default configuration worked immediately, but with noticeable delay:

```bash
# PipeWire service
pw-cat --record --target snapcast_output --format=s16 --rate=48000 --channels=2 - | nc 192.168.178.148 4953

# Snapclient defaults
snapclient --host 127.0.0.1 --stream Network
```

500ms latency—fine for background music, terrible for video sync or interactive use.
### Understanding the Latency Stack
| Component         | Default Setting | Latency Contribution |
| ----------------- | --------------- | -------------------- |
| PipeWire capture  | 100ms buffer    | ~100ms               |
| Network (TCP)     | Buffered        | ~10-50ms             |
| Snapserver buffer | 1000ms          | ~400ms               |
| Snapclient buffer | 1000ms          | ~400ms               |
| Chunk processing  | 26ms (FLAC)     | ~26ms                |

The killers: server buffer and client buffer, both defaulting to 1000ms.
### Optimization Round 1: Codec Change

Switching from FLAC to PCM eliminated encode/decode latency:
```text
# snapserver.conf
codec = pcm
chunk_ms = 20
buffer = 150
```
PCM uses more bandwidth (~1.5 Mbps vs 160 kbps) but has zero codec delay.

Result: ~400ms (mostly from client buffer).
### Optimization Round 2: Client Buffer Reduction

The snapclient buffer was the biggest single contributor. The default is 1000ms, but it's configurable:
```text
# /etc/default/snapclient
SNAPCLIENT_OPTS="--host 127.0.0.1 --player alsa:output=hw:0,0 --stream Network --buffer 50 --latency 0"
```
Result: ~150ms
### Optimization Round 3: PipeWire and Fine-Tuning

Reducing PipeWire latency and server buffer:
```text
# PipeWire service
Environment="PIPEWIRE_LATENCY=10ms"
Environment="PIPEWIRE_QUANTUM=480/48000"

# snapserver.conf
buffer = 50
chunk_ms = 5
```
Final Result: ~100ms
## The Working Configuration
### Fedora Desktop (PipeWire Source)
`~/.config/systemd/user/snapcast-stream.service`:
```systemd
[Unit]
Description=Snapcast Network Stream to Hilbertstream
After=pipewire.service
Wants=network-online.target

[Service]
Environment="PIPEWIRE_LATENCY=10ms"
Environment="PIPEWIRE_QUANTUM=480/48000"
Type=simple
Restart=always
RestartSec=5

# Record from monitor, send via socat for reliability
ExecStart=/bin/sh -c 'pw-cat --record --target snapcast_sink.monitor --format=s16 --rate=48000 --channels=2 - | socat -u - tcp:192.168.178.148:4953,retry=5,interval=1'

[Install]
WantedBy=default.target
```

Key fixes:
- Use `snapcast_sink.monitor` (not `snapcast_sink`)—you record from the monitor source
- Use `socat` instead of `nc` for better connection handling
- Remove `nc -N` flag which caused premature connection close

### Raspberry Pi (Snapserver)
`/etc/snapserver.conf`:
```text
[stream]
source = tcp://0.0.0.0:4953?name=Network&sampleformat=48000:16:2&mode=server&chunk_ms=5
codec = pcm
buffer = 50
chunk_ms = 5
```

### Raspberry Pi (Snapclient)

`/etc/default/snapclient`:
```text
SNAPCLIENT_OPTS="--host 127.0.0.1 --player alsa:output=hw:0,0 --stream Network --buffer 30 --latency 0"
```

## Future Expansion: Plexamp and Multi-Room

This setup is intentionally future-proof:
### Phase 2: Plexamp Headless

The RPi can run Plexamp in headless mode, connecting to your Plex server for hi-res library streaming. The Snapcast integration means:
- Stream from desktop (current setup)
- OR stream from Plexamp (local library)
- OR both, synchronized

### Phase 3: Multi-Room

Adding another room is trivial:
- Add another RPi with snapclient
- Point it to the same snapserver
- Both rooms stay perfectly synchronized

The 100ms latency is room-local; synchronized playback across rooms works regardless of buffer size.

## Debugging Tips

If setting this up yourself:
- Verify the PipeWire target exists: `pw-cli list-objects Node | grep node.name`
- Test network connectivity: `nc -zv <rpi-ip> 4953`
- Check snapserver stream status: `curl -s http://localhost:1780/jsonrpc | python3 -m json.tool`
- Monitor snapclient logs: `sudo journalctl -u snapclient -f`

## Can You Go Lower?

100ms is excellent for multi-room audio. The theoretical minimum with this stack is around 50-60ms, but requires:
- `--buffer 20` on snapclient (risk of dropouts on WiFi)
- `buffer = 30` on snapserver
- Ethernet instead of WiFi
- RT-PREEMPT kernel on the RPi

For my use case, 100ms is imperceptible for video sync and rock-solid reliable.

## Why This Beats Bluetooth
| Feature       | Bluetooth        | This Setup                   |
| ------------- | ---------------- | ---------------------------- |
| Audio quality | Lossy (SBC, AAC) | Lossless PCM                 |
| Sample rates  | 48kHz max        | Any rate (192kHz capable)    |
| Latency       | 200-300ms        | 100ms (tunable)              |
| Reliability   | Dropouts common  | Network-dependent            |
| Range         | 10m              | Unlimited (network)          |
| Expandability | None             | Multi-room, headless sources |

## Lessons Learned
- The client buffer dominates latency—not the server buffer, not the network
- PCM > FLAC for low latency—the codec overhead matters more than bandwidth
- PipeWire monitor sources—always record from `*.monitor`, not the sink itself
- Use `socat`, not `netcat`—better connection handling for streaming
- Snapcast is overkill for one room, but future-proof—the multi-room capability is a bonus

**The result:** hi-res, low-latency audio from any PipeWire source to my soundbar. No Bluetooth compression. No dropouts. Room to grow.


**Hardware used:** Raspberry Pi 4(2GB) with Rpi OS Lite, HiFiBerry Digi+ Pro, Fedora Sway Desktop 43, PipeWire 1.0+, Snapcast 0.31.0


**Next steps:** Plexamp headless setup for local hi-res library streaming
