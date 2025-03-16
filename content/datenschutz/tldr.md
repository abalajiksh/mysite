+++
date = '2025-02-12T13:33:41+01:00'
draft = false
title = 'TL;DR'
+++

*Last edited: 03/13/25*

This site uses a little scoop of vanilla JavaScript, a dash of CSS, and the blending power of Hugo. It is just a bunch of HTML pages with no annoying pop-ups or site-wide tracking. It’s also **tiny** and **privacy conscious**. No JavaScript frameworks, icon packs, or Google fonts. No ads or trackers polluting your console window. If the webpage you visit have Math and/or Flowcharts then those specific pages have Katex and/or Mermaid Javascript rendering libraries loaded respectively.

{{< notice info >}}
Don't wanna take my word for it? Do a privacy inspection yourself [here](https://themarkup.org/blacklight?url=ashwinbalaji.xyz&device=mobile&location=us-ca&force=false).

If you are more tech saavy, then head to Mozilla HTTP Obeservatory Report [here](https://developer.mozilla.org/en-US/observatory/analyze?host=ashwinbalaji.xyz).
{{< /notice >}}

[Alpine.JS](https://alpinejs.dev/) a lightweight and open-source JavaScript framework, simplifies the creation of blog posts featuring complex calculations and interactive examples for enhanced comprehension. The beauty of this framework is such that you can do all computations right in the middle of the blog, in your browser, and use your own hardware for it. No data upload, no spying on your personal data. Heck, I don't have any-way to send back that data for myself! Not just normal calculations, let’s say I write a series of cascading calculations, then just changing the data at the beginning will reactively change the whole blog to fit that data, making it more personal. This tiny JS framework will load only on pages that require it, and there is a warning in the beginning about it's existence. No scripts will execute on it's own unless you click/interact on it.


Readers are offered the choice to read in light or dark mode. The user’s preference is remembered and saved in local storage. Dark mode is the default for first time visitors.

The pages are served from CloudFlare Pages service, so Cloudflare will get some basic analytics like the time and URL opened, geolocation and other basic information your browser attaches to it's `GET` request.

{{< notice info >}}
**Coming Soon:** [Remark42](https://remark42.com/) is a lightweight, open source commenting engine that doesn’t spy on you, the user. I am hosting it in a private server provided by Hetzner cloud in Nuremberg, Germany. You don't have to login to comment on any article. Just say hi or comment away your views.
{{< /notice >}}