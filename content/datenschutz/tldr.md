+++
date = '2025-02-12T13:33:41+01:00'
draft = false
title = 'TL;DR'
+++

*Last edited: 22 July, 2026, 19:30*

This site uses a little scoop of vanilla JavaScript, a dash of CSS, and the blending power of Hugo. It is just a bunch of HTML pages with no annoying pop-ups or site-wide tracking. It’s also **tiny** and **privacy conscious**. No JavaScript frameworks, icon packs, or Google fonts. No ads or trackers polluting your console window. If the webpage you visit have Math and/or Flowcharts then those specific pages have Katex and/or Mermaid Javascript rendering libraries loaded respectively. It’s also compatible with modern security standards — everything (fonts, scripts, math rendering) is self-hosted, nothing loads from third-party CDNs, and the site ships a strict Content-Security-Policy plus HSTS — so you don’t have to worry about browsing this website.

{{< notice info >}}
Don't wanna take my word for it? Do a privacy inspection yourself [here](https://themarkup.org/blacklight?url=ashwinbalaji.xyz&device=mobile&location=us-ca&force=false).

If you are more tech saavy, then head to Mozilla HTTP Obeservatory Report [here](https://developer.mozilla.org/en-US/observatory/analyze?host=ashwinbalaji.xyz) or Google's PageSpeed Insights [here](https://pagespeed.web.dev/analysis/https-ashwinbalaji-xyz/9vw78s5iyk?form_factor=desktop).
{{< /notice >}}

[Alpine.JS](https://alpinejs.dev/), a lightweight and open-source JavaScript framework, powers the occasional interactive blog post: all calculations run right in your browser, on your own hardware. No data upload, no spying — I have no way to receive that data even if I wanted to. It is self-hosted here in its CSP-friendly build (no `eval()` anywhere), and loads only on pages that actually need it.


Readers are offered the choice to read in light or dark mode. The user’s preference is remembered and saved in local storage. Dark mode is the default for first time visitors.

The pages are served from CloudFlare Pages service, so Cloudflare will get some basic analytics like the time and URL opened, geolocation and other basic information your browser attaches to it's `GET` request. For example, when you opened this webpage, this is the information your browser sends to Cloudflare automatically.

![](/images/request-headers.png)

[Remark42](https://remark42.com/) is a lightweight, open source commenting engine that doesn’t spy on you, the user. I am hosting it in a private server provided by Hetzner cloud in Nuremberg, Germany. You don't have to login to comment on any article. Just say hi or comment away your views.