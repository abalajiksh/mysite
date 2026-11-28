+++
date = '2025-02-12T13:33:41+01:00'
draft = false
title = 'TL;DR'
+++

*Last edited: 28 November, 2026, 14:30*

This site uses a little scoop of vanilla JavaScript, a dash of CSS, and the blending power of Hugo. It is just a bunch of HTML pages with no annoying pop-ups and no site-wide tracking. It’s also **tiny** and **privacy conscious**: no JavaScript frameworks, no icon packs, no Google fonts, and no ads or trackers polluting your console. If a page has math and/or flowcharts, then that specific page loads the KaTeX and/or Mermaid JavaScript rendering libraries respectively — and nothing more. It’s also built to modern security standards: everything (fonts, scripts, math rendering) is self-hosted, nothing loads from third-party CDNs, and the site ships a strict Content-Security-Policy plus HSTS. So you don’t have to worry about browsing here.

{{< notice info >}}
Don’t want to take my word for it? Run a privacy inspection yourself [here](https://themarkup.org/blacklight?url=ashwinbalaji.xyz&device=mobile&location=us-ca&force=false).

If you are more tech-savvy, head to the Mozilla HTTP Observatory report [here](https://developer.mozilla.org/en-US/observatory/analyze?host=ashwinbalaji.xyz) or Google’s PageSpeed Insights [here](https://pagespeed.web.dev/analysis/https-ashwinbalaji-xyz/9vw78s5iyk?form_factor=desktop).
{{< /notice >}}

[Alpine.js](https://alpinejs.dev/), a lightweight, open-source JavaScript framework, powers the occasional interactive blog post: every calculation runs right in your browser, on your own hardware. No data upload, no spying — I have no way to receive that data even if I wanted to. It is self-hosted here in its CSP-friendly build (no `eval()` anywhere), and loads only on the pages that actually need it.

Readers can choose to read in light or dark mode. Your preference is remembered in local storage, and dark mode is the default for first-time visitors.

The pages are served from Cloudflare Pages, so Cloudflare receives some basic analytics — the time and URL opened, your geolocation, and other basic information your browser attaches to its `GET` request. For example, when you opened this page, this is the information your browser sent to Cloudflare automatically.

![](/images/request-headers.png)

[Remark42](https://remark42.com/) is a lightweight, open source commenting engine that doesn’t spy on you, the user. I am hosting it in a private server provided by Hetzner cloud in Nuremberg, Germany. You don’t have to log in to comment on any article. Just say hi, or comment away with your views.