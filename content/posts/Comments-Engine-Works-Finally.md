+++
date = '2025-10-15T15:18:05+02:00'
draft = false
title = 'Comments Engine Works Finally; After I Fixed My Stupidity'
useAlpine = false
tags = ["CSP", "CORS", "Server Setup", "Internal Documentation", "Remark42"]
series = "Self-Hosting a Comments Engine: Remark42"
+++
## Story Continued ...

As mentioned in the previous post in this series, I ran into `CSP` issues and was struggling to fix them. Here I am, trying to explain the stupidity that caused all these problems. What stupidity you ask? It boils down to not reading the documentation. However, not so fast, I have a de-tour story to tell you guys.

Turns out, I was adding `CORS` headers from Remark42, NGINX and CloudFlare at the same time. What is `CORS` you ask? It is an abbreviation for Cross-Origin-Resource-Sharing[^1], which is essential if multiple applications running in different domains or sub-domains need to work together. It is a security feature. If this doesn't exist, you might use my server to host your comments and flood it with data, or more malicious things can be done. Anyway, all I had to do was disable the feature from Remark42 using it's config file, remove it from CloudFlare and only use NGINX to do the heavy-lifing. I had to set `PROXY_CORS=true` in the configuration file, remove the custom header rule in CloudFlare, and add the below lines to NGINX configuration for the site.

```nginx
add_header 'Access-Control-Allow-Origin' 'https://ashwinbalaji.xyz' always;
add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-XSR>
add_header 'Access-Control-Allow-Credentials' 'true' always;
```

This way, NGINX will process the request only if the request originates from my domain, and you guys can't add it to your website. With all these setup, I pushed the commit to GitHub, and see them work auto-magically.

## The Promised Detour

Turns out I forgot the access credentials for my server at Hetzner Cloud and lost access. So I had to delete the server, create a new one and set up all over again. This time, as I realized lately, I need an internal documentation, just like my company uses Confluence, to maintain all this crazy stuff I do for fun. So, I installed LogSeq and stored all critical information there. However, sooner I will move to a self-hosted application to do the same as I jump between computers and platforms to work on these things. I don't want to run Syncthing everywhere just to keep them synced. I am looking at Outline[^2] and Bookstack[^3], and quite confused with one to opt-for. Let me know in the comments!!

## More Setup

By default, Remark42 only allows anonymous usage, and if I use an anonymous name today, someone else can use that name in another article to comment. So, I had to add GitHub and Google OAuth, and asked Mistral about how to do it. Followed some boring steps, restarted my Remark42 service on my server, and everything seems to work fine. Anonymous comments are still available for you to use if you wish. With that, take care and see you in the next article.

[^1]: [Cross-Origin Resource Sharing (CORS) - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)

[^2]: https://www.getoutline.com/

[^3]: https://www.bookstackapp.com/