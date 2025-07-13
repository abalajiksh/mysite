+++
title= "WaveGuide Mode Visualizer"
date= 2022-02-23T02:37:28+01:00
draft= false
tags= ["Physics", "Electrodynamics", "Visualization", "Simulation", "Computation"]
useAlpine = false
+++
![WaveGuide-Mode-Visualizer](/images/WaveGuide-Mode-Visualizer.png)

{{< notice warning >}}
This article is one among many salvaged from my previous blog! It is not on par with my demands of quality but I didn't feel like abandoning it.
{{< /notice >}}



## Warmup
A few years back, I was in a rush to visualize some fields (electromagnetic to be precise) using computers. I asked my professor what could be a good starter; him being an astrophysicist specializing in solar studies, told me about the dark spots on the surface of the sun; which was not very exciting for me. That felt like a lot, so I asked for a simpler one. He thought for a moment, then said Waveguides.

What? was the only thing that came out of my mouth when things inside my head kicked in. I realised how infuriating it was when he was teaching about Waveguides in Electrodynamics-II. I didn't get why we are doing that in the first place -first, I didn't understand the concept of radiation; second, a lot of approximations made it awful-I hate approximations and would like to avoid them as much as possible. He then broke the awkward silence and said I should try to visualize the electric and magnetic fields travelling in the waveguide.

I said that doesn't sound cool (in retrospect, I realise that wasn't the way to do things), give me something more difficult. He replied, "You will know this is difficult enough to accomplish once you get started; once you are done with this, we can move to more complicated ones". Little did I know he was right, studying physics from an engineering school has taught me a wide variety of things; and that came to my rescue.

## Meantime
I had no idea where to start, which tools should I use or learn to use etc. This is where the rudimentary engineering skills dive in. I researched the plotting libraries and frameworks, the load this program might take to run on a PC, programming language of choice etc. That was a lot of shopping for such simple visualization work! Being a scientist is not this overwhelming as being an engineer!! We have a lot of limits set by nature, experiments and previous successful and unsuccessful theories. Most of the choices are made for us, we just have to move further with them, and that is the reason I believe I went down the theoretical physics rabbit hole. Engineering is another name for shopping for your next recipe. It goes like this, a gourmet recipe or blend-all-what-you-got, stir-fry or bake, simple dish or complex infusions etc. You have a tiresome job of choosing before getting started.

I did all the choosing and ended up using `mayavi` and `python3` for the same. I opened up the famous book in Electrodynamics which I have referring to for almost 4 years back then. Griffiths. Ask any physics student his choice of Electrodynamics book for undergraduate, this is it. But it wasn't enough. I went back to him and said I have difficulties, he gave me a copy of "Field and wave electromagnetics by David K Cheng". This book was down to earth full of nitty-gritty calculations and fine details I was exactly looking for. This set me up in the path and what happened afterwards was ...

I procrastinated for a long time, hoping for that surge of energy to kick in to start implementing and working on it. There I came across a contest for scientific visualization. I don't want to mention details about the contest, but this helped me crank up those knobs in me to full and start working. I did it all in just a couple of hours, it was such an intense session. All seemed perfect and I showed my prof thinking that he needs to verify. Of course, he was stuck due to dependency issues.

I shared with him some screenshots from my side and told him, he needs to install certain packages before he can run that. When he did that, this is what he was looking at ...

{{< details summary="Video and Source" >}}
[Video](https://player.vimeo.com/video/424267794?h=c9bb7e4047) and [GitHub](https://github.com/ashwinbalaji0811/WaveGuide-Mode-Visualizer?ref=ashwin-balaji)
{{< /details >}}





## Finale
I never wanted to bring this simple thing into my writing, until I hit the tip of an iceberg. I was browsing through all the old stuff, and when I stumbled upon this, I thought I would record this for the posterior. They started speaking to me about something I missed but I couldn't comprehend.

It was saddening that such a sudden surge in inspiration goes uncomprehended and irrecoverable, then when I also looked at the email correspondence I had with my professor, the muses spoke back, only this time very clearly. They made me realize the fact that theory is like poetry, it floats in our minds and not ourselves. The calculations and hard effort to realistically simulate the whole thing inside a computer may further enhance our understanding. I understood that the first experimentation ground for theoretical physics is simulations. This is where I departed to look into some serious topics to dwell in. Cosmic Microwave Background Radiation, Lattice Gauge Theory and a few more popped up. If you know me in person, you know that I'm obsessed with the concept of time as it appears in physics and philosophy. It makes me not sleep and dig for more.

The simulation exercise has also given me ground and reason to keep moving forward the way I see things. I hope in future if I revisit this article again, I would have learnt more about the time.