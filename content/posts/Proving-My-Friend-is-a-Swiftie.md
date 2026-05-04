+++
date = '2026-05-04T13:30:00+02:00'
draft = false
title = "Trial by ListenBrainz: How I Used 13,477 Scrobbles to Prove My Friend is a Swiftie"
tags = ["Data Analysis", "ListenBrainz", "Python", "Music", "Friendship", "Taylor Swift", "Privacy", "Surveillance"]
useAlpine = false
+++

## The Allegation

My friend Colin has, for several months now, maintained the position that he is "*just a casual listener*" of Taylor Swift. The standard pop-culture-deniability claims: he only knows the hits, he just hears her on shuffle, he certainly does not know the deep cuts, and absolutely does not have an opinion on the Taylor's Version re-recordings, thank you very much.

I had my suspicions. He has the entire repertoire of evasions: a too-casual shrug when *Cruel Summer* comes on; the claim that "song of the summer" tracks do not count; the appeal to ironic listening. The kind of pop-culture deniability men of a certain age extend to themselves like a privacy curtain.

Today, **May the Fourth, 2026**, while the rest of the internet pretends to be Jedi, I am publishing the dossier. The Force may be strong, but ListenBrainz is stronger.

{{< notice info >}}
For anyone unfamiliar: ListenBrainz[^1] is the open-source, MusicBrainz-backed alternative to Last.fm. Every song a user plays gets *scrobbled* — recorded in their public listening history with a timestamp, an artist name, a track name, and (if the metadata gods are kind) a MusicBrainz ID. Colin has a public ListenBrainz profile. He has been scrobbling since around September of last year. By May 2026 he has accumulated 13,477 listens, all of them in principle accessible via a JSON API.

This was, with hindsight, an unforced error on his part.
{{< /notice >}}

## The Plan

ListenBrainz exposes a per-user listens endpoint: `GET /1/user/{username}/listens`. It returns up to 1,000 listens per request, sorted by `listened_at` descending, and paginates backwards via a `max_ts` query parameter. So the strategy is straightforward: fetch the most recent 1,000, take the oldest timestamp from the batch, set that as the next request's `max_ts`, repeat until the response runs dry.

For 13,477 listens, that is about fourteen requests. Comfortably within the rate limits. Polite people respect `X-RateLimit-Remaining` and `X-RateLimit-Reset-In` in the response headers anyway, and I am, on a good day, polite.

The harder problem is correctly identifying Taylor Swift listens. Free-text artist name matching is brittle: what about "Taylor Swift feat. Bon Iver", or scrobbles from a music app that lowercased the name, or the cursed `,` vs `&` joiner debates that haunt multi-artist credits? The right way is to match against Taylor Swift's MusicBrainz Artist ID:

```
20244d07-534f-4eff-b4d4-930878889970
```

What is an MBID you ask? It is a MusicBrainz Identifier — a stable, opaque, globally unique handle for an entity in the MusicBrainz database. It is the same across every release, every featured credit, every regional spelling and re-recording. ListenBrainz includes MBIDs in its `mbid_mapping` metadata when it can, so I match on that first and fall back to a case-insensitive name match for unmapped scrobbles. Belt and braces.

I wrote a single Python script to do the scrape, the dossier analysis, and emit ten plots covering the comparison from every angle that occurred to me. Caching to disk so subsequent analytics runs do not re-hit the API. The post-processing is `pandas` and a fistful of `matplotlib`.

{{< details summary="A note on what counts as a 'listen'" >}}
ListenBrainz, like Last.fm, registers a scrobble after a song has been played for at least half its duration (or four minutes, whichever is shorter). So we are not counting accidental skips. Every datum in this analysis represents a song Colin chose to let play. *Caveat lector*. The data is, in this sense, more honest than the listener.
{{< /details >}}

## The Headline Numbers

In 8 months of scrobbles:

- **Total listens:** 13,477
- **Distinct artists listened to:** 1,688
- **Taylor Swift listens:** 426 (3.2%)
- **Distinct Taylor Swift tracks played:** 151
- **Distinct Taylor Swift albums in rotation:** 12

That last number is the problem. A casual listener might be able to name three Taylor albums. Colin has played songs from twelve. *Lover*, *Midnights*, *reputation*, *1989* (twice — once the original, once *Taylor's Version*), *folklore*, *The Tortured Poets Department*, *The Life of a Showgirl*, *Fearless (Taylor's Version)*, *Red*, *Red (Taylor's Version)*, *Speak Now*, plus singles and remixes. That is a reasonable approximation of her entire commercial output to date.

![Pie chart showing Taylor Swift's 3.2% slice of total listens.](/images/swiftie-pie.png "Taylor Swift listens (pink) vs. all 1,687 other artists combined (grey).")

The 3.2% slice in the pie chart looks deceptively small. It is not. The other 96.8% is split among **1,687 different artists**. There is no human's-share-of-listening that 3.2% to a single artist is "casual." A genuinely casual listener distributes attention more evenly. A 3.2% concentration on one artist, when the alternative is 1,687 others, is fandom.

![Top 20 artists, with Taylor Swift highlighted in pink at #2.](/images/swiftie-top-artists.png "Of all 1,688 artists Colin has listened to, Taylor Swift is #2.")

Across all 1,688 artists he has scrobbled, **Taylor is #2**. The only artist beating her is one Gibran Alcocer, a lo-fi pianist whose tracks are titled things like *Idea 15* and *Idea 22* and which is, transparently, what he leaves on as background music while studying. Among artists Colin actively chooses to listen to as foreground music — that is, as music — Taylor Swift is uncontested number one.

## The Trend

The volume tells a story.

![Monthly Taylor share with global Spotify average reference line.](/images/swiftie-monthly-share.png "Taylor's share of monthly listening. The dotted line is the global Spotify average user.")

Monthly share fluctuates between 0.8% and 6.3%. February 2026 peaks at **6.3%** — roughly eight times the typical Spotify user's Taylor exposure. May 2025 was 4.9%. October 2025 was 5.3%. There is no month below the global average. Even the "quiet" months, November and December 2025, hover right at the typical user's *peak*.

![Weekly listening stacked: Taylor in pink atop the rest in grey.](/images/swiftie-weekly-stacked.png "Weekly listens, Taylor stacked atop everything else.")

Stacked weekly, the pink ribbon is small in any given week — but it is *always there*. There is no week where the ribbon disappears. He is not on, off, on, off. He is always on, just at varying intensities.

![Cumulative Taylor listens over 8 months, with a marked Swiftie Awakening date.](/images/swiftie-cumulative.png "Cumulative Taylor listens. The dashed line marks the largest 14-day acceleration.")

The cumulative curve is the cleanest evidence of a trend. The slope is gentle through autumn 2025, plateaus through December (the holidays apparently trumped Taylor for a brief window), and then around late February 2026 the curve hinges upward. I marked the largest 14-day acceleration on the chart. **The Swiftie Awakening: 27 February 2026.** That is the day his Taylor listening reached its highest sustained intensity. We will return to this date.

## The Smoking Gun: Album Playthroughs

This is the evidence that ends the trial. I went looking for runs where Colin played sequential album tracks of Taylor Swift, in correct numerical order, within a few minutes of each other. The threshold was generous: four tracks in a row, same release, increasing track numbers, gaps under thirty minutes.

He cleared it **eight separate times**.

The standout: on **23 February 2026, at 15:39 local time**, he played *Lover* tracks 2 through 17, in order, finishing at 18:22. That is sixteen songs across nearly three hours, played in album sequence, beginning to end.

![A timeline of Colin's listens on 23 February 2026, with the Lover album playthrough highlighted.](/images/swiftie-lover-playthrough.png "Each dot is one scrobble on 23 February 2026. Bright pink dots are Lover tracks; the shaded band is the 16-song in-order run.")

This is not what shuffle does. This is not what a recommendation algorithm does. This is what someone does when they sit on the couch, put on an album, and let it play.

Other album sessions on the docket:

- **25 October 2025, 21:09** — *The Life of a Showgirl*, tracks 1 through 9 in order
- **26 February 2026, 21:33** — *Midnights* tracks 1–4, then immediately *folklore* tracks 1–5 starting at 23:20. He went from one Taylor album straight into another, on the same evening.
- **7 January 2026, 05:05** — *reputation*, tracks 1–5 in order. At five in the morning. Voluntarily.

If a defense attorney told me their client had played the *Lover* album in track order on a Monday afternoon, I would advise that attorney to plead.

## The Calendar of Omnipresence

When you rasterise his daily Taylor listens onto a calendar grid, the conclusion is immediate.

![Calendar heatmap of daily Taylor listens, with album-playthrough days outlined in black.](/images/swiftie-calendar.png "Each cell is one day. Pinker = more Taylor that day. Black borders mark days with confirmed album playthroughs.")

He scrobbled Taylor on **125 of his 251 active listening days**. Exactly half. Of every day he listened to anything, half had a Taylor song. There is no Taylor-free quarter, no Taylor-free month, no Taylor-free fortnight. His longest stretch of active days without a single Taylor scrobble is **eleven days**. Eleven. In eight months. The black-bordered cells are the days I confirmed were album playthroughs — they cluster, predictably, around the late-February awakening, with one outlier in October.

## When and Where

Two more views, for completeness.

![Three-week rolling average of weekly listens for the top 5 artists, Taylor highlighted.](/images/swiftie-top-artists-weekly.png "Top-5 artist weekly listens, smoothed. Taylor (thick pink) versus the other top artists.")

The smoothed top-5 chart shows what happens when you compare Taylor against the rest of his rotation. The lo-fi piano background dominates, as it does for anyone who works with music on. But around February 2026, **Taylor's pink line crosses every other top-5 artist** for several weeks. She was, briefly but unambiguously, his most-listened *foreground* artist.

![Heatmap of Taylor listens by hour of day and day of week.](/images/swiftie-hour-heatmap.png "When the Taylor listening actually happens. Hour-of-day on the x-axis, day-of-week on the y.")

The hour-by-day heatmap is interesting because of what it does *not* show. There is no concentrated late-night blob. The Taylor listens are scattered across the day, with hotspots around lunch (12:00–14:00) and Sunday afternoons. This is meaningful: the "I only listen to Taylor when I'm sad at 2 AM" defence is unavailable to him. He plays Taylor at lunch on a Tuesday. He plays Taylor on a Sunday afternoon. This is *integrated* listening, the kind a fan does, not the kind a casual listener does.

## Receipts in Brief

A few more findings from the dossier, presented mostly without commentary because the commentary writes itself:

- **The median time between two consecutive Taylor listens is 12 minutes.**
- **Taylor was the most-played artist of the week in 5 separate weeks.** Out of all 1,688 artists. The week of 23 February he had 45 Taylor listens; nobody else came close.
- **26% of his listens to TV-eligible albums (Fearless, Speak Now, Red, 1989) were of *Taylor's Versions*.** He owns and plays *both* the original *1989* and *1989 (Taylor's Version)*. Casual listeners do not care about who owns the masters. Swifties do.
- **Gateway artists** — what was playing immediately before he switched to Taylor: Justin Bieber (6×), One Direction (3×), Katy Perry (3×), Selena Gomez (3×), Carly Rae Jepsen (3×). He is in the *exact* corner of pop where Taylor lives.

The most-played Taylor songs in his library, with counts: *Style* (22 plays), *Cruel Summer* (17), *Lavender Haze* (17), *Lover* (16), *The Fate of Ophelia* (16), *Delicate (Seeb remix)* (15), *Anti-Hero* (15). The *Delicate (Seeb remix)* one is particularly damning, because nobody encounters that remix accidentally; you have to go looking for it.

![A four-panel dossier: top tracks, top albums, the awakening curve, and the 27 February timeline.](/images/swiftie-dossier.png "The dossier in one image.")

The four-panel dossier above is the TL;DR. Top-left: the songs he literally cannot stop replaying. Top-right: every Taylor era he has visited. Middle: the daily Taylor listens with the Awakening date marked. Bottom: a single-day timeline of 27 February 2026, the day immediately after the Awakening, when he played **seventeen Taylor songs in unbroken sequence between 11:36 AM and 12:31 PM**, with no other artist between them. The shaded band on the bottom panel is that hour.

## A 5-σ Aside

There is a convention in particle physics where, before claiming the discovery of a new particle, the statistical evidence is required to clear a 5-σ threshold. That corresponds to roughly a 1-in-3.5-million probability of the result being a chance fluctuation. It is strict, and it is reasonable: extraordinary claims, et cetera.

The claim "Colin is a Swiftie" is, by comparison, an extremely *ordinary* claim. The combined evidence — eight album playthroughs in correct track order, twelve different albums in rotation, *Taylor's Version* loyalty, five weeks as artist-of-the-week, the seventeen-Taylor-songs-in-a-row session on 27 February, the *Lover* album sit-down on 23 February — clears the bar by a margin for which I am not certain there is a clean name.

Colin is, in the cinematic sense, buried. There is no Beatrix Kiddo move available. The Bride got out of Paula Schultz's grave by punching through pine — a few centimetres of soft wood, with technique inherited from Pai Mei in the *one-inch punch* sequence Tarantino lingers on for half an act of *Kill Bill Vol. 2*[^kb]. The training pays off in the dirt. Pine is breakable. So is wood. So is, in principle, the desert above.

A JSON file is not pine. An MBID match is not a coffin lid you can punch through with the right wrist mechanics. The data does not yield to technique. There is no Pai Mei for ListenBrainz. The null hypothesis "Colin is not a Swiftie" is rejected with extreme prejudice, and there is no escape.

## The Verdict

Colin is a Swiftie. He has, in the manner of ancient kings and modern professional athletes, an entire era he prefers (*1989*, with 72 listens across both editions). He has favourite remixes. He sits down with full albums. He follows the re-recording political project. He listens to *reputation* at five in the morning. He has, in the privacy of his own scrobble log, *cared*.

The only honest move from here is to embrace it. Put on *folklore*, get a cardigan, accept that the Force was not, in this particular instance, with you. Happy May the Fourth.

## A More Sobering Note

I would like to step out of the joke for a moment, because the joke has a serious lining.

I built this entire dossier in an afternoon. The ingredients: a free open-source API, fourteen HTTP requests, a Python script that fits in a single file, and a friend who chose to make his ListenBrainz profile public. Total compute: minutes. Total cost: zero. The output: a deeply specific behavioural portrait of one person — what they listen to, when, for how long, in what order, on which days, in which moods, and how those preferences have evolved over time. From a public data source they consented to using.

Now consider Spotify. Spotify has all of this and *vastly* more about every one of its 600+ million monthly active users. They know the song you skipped thirty seconds in. They know the song you replayed twice in a row at 2 AM on a Tuesday. They know which playlist you were on when you paused, what you switched to, how long you stayed there, what you searched for at 3 AM, what you queued up before a workout, and how your taste shifts with the weather. None of that data is public. All of it is internal training signal.

Liz Pelly's *Mood Machine: The Rise of Spotify and the Costs of the Perfect Playlist* (One Signal, 2025) is the best long-form treatment I've read of what this data architecture actually does[^mm]. The argument, briefly: Spotify does not so much *reflect* listener taste as *shape* it — pushing users toward passive, mood-based listening (the ubiquitous *Chill Vibes*, *Lo-Fi Beats to Study To*, *Deep Focus* playlists), which keeps people listening longer while paying out less in royalties. Pelly documents the rise of what Spotify internally calls *Perfect Fit Content* — production music commissioned in bulk from a small stable of composers, sometimes published under fake artist names, slotted into mood playlists in place of the human artists those listeners think they are supporting.

The plumbing for all of that is granular behavioural surveillance. Every skip, replay, pause, and time-of-day is a signal. Every signal goes into the recommendation model. The model nudges; the listener responds; the listener's responses become training data; the model nudges harder. Over time the listener's "taste" is downstream of, rather than upstream of, the model's gradients.

I built a Swiftie audit. The same primitives, applied at scale by a company with a profit motive, build a system where your taste is a downstream function of someone else's quarterly revenue targets. The data flows are not symmetric: I had to ask Colin's permission (implicitly, by his choice to use a public ListenBrainz profile) and the surface I could probe was small and well-defined. Spotify did not ask, the surface is total, and the extracted signal feeds directly back into what you are offered next.

This is — and I am genuinely not joking, despite the previous two thousand words — one of the better arguments I know for self-hosting your music library, owning your scrobble data, and using open infrastructure like MusicBrainz and ListenBrainz wherever possible. Pelly's book is worth your time even if you have no intention of leaving Spotify. It will at minimum change what you notice about the playlists.

I run my own Plex/Navidrome stack[^plex] for music for exactly the reason this post demonstrates in miniature. The data my listening generates should be mine. It should be on my hardware, in my house, on storage I own, exposed via APIs I control. If a friend wants to roast me with it, they can ask.

## Reproducibility

The full Python script — a single file that handles the scrape (with proper rate-limit handling and disk caching), the dossier analysis, and all ten plots in this post — is in a small repo I will link to in a follow-up post once I have tidied it. If you want to run a similar audit on a willing[^2] friend, the only ingredients are their ListenBrainz username and an afternoon. The script handles pagination, MBID-based artist matching, album-playthrough detection, and rate limiting, and produces every figure here.

A quick checklist of what it generates, in case you want to extend it:

1. A pie chart of target vs. everyone else
2. Top-N artists with the target highlighted
3. Stacked weekly listens (target vs. rest)
4. Smoothed weekly trends for the top-5 artists
5. Cumulative target listens with a derived "awakening date"
6. Hour-of-day × day-of-week heatmap for the target
7. A four-panel summary dossier
8. Monthly target share with a global-average reference line
9. Calendar heatmap of daily target listens, with album-playthrough days outlined
10. A track-level timeline of the most extensive single-day album playthrough

If you run this on a friend and they turn out *not* to be a Swiftie, please let me know in the comments. I would like to confirm that such people exist.

[^1]: https://listenbrainz.org/

[^2]: Or, in the case of public ListenBrainz profiles, willing-by-default.

[^kb]: For the uninitiated: in Quentin Tarantino's *Kill Bill Vol. 2* (2004), The Bride / Beatrix Kiddo (Uma Thurman) is captured by Budd, sealed in a wooden coffin, and buried alive in the desert grave of one Paula Schultz. She escapes by employing the *one-inch punch* technique drilled into her under the brutal tutelage of the master Pai Mei — striking the coffin lid from a few centimetres away with enough force to crack the wood, then digging her way out through the dirt. The grave's headstone, inscribed PAULA SCHULTZ, is briefly visible. It is one of the great escapes in cinema. It is not available to people whose imprisonment is in a JSON file.

[^mm]: Liz Pelly, *Mood Machine: The Rise of Spotify and the Costs of the Perfect Playlist*, One Signal Publishers, January 2025. A long-running thread of Pelly's reporting on the same subject is also at *The Baffler* and *Harper's*.

[^plex]: An older post on my self-hosted music setup is [here](/posts/self-hosting-music-library-and-dsee-shenanigans/), if you are curious about the stack.
