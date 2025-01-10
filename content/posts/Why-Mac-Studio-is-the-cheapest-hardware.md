+++
title= "Why Mac Studio Is the Cheapest Hardware"
date= 2023-07-11T11:08:41+02:00
draft= false
tags= ["Computers", "Apple", "Server", "Technology", "Linux"]
+++

{{< details summary="Warning!" >}}
This article is one among many salvaged from my previous blog! It is not on par with my demands of quality but I didn't feel like abandoning it.
{{< /details >}}

![](https://github.com/abalajiksh/gifabxyz/raw/main/mac-studio.png)

## Backstory

I started working on a project in my free time to cater to curiosity. This project requires extensive use of AI Models that utilizes huge system resources. The details of the project's scope are not in my authority to discuss here. People traditionally train and run AI models on GPUs or TPUs, which contain VRAM memory to process the data.. Consumer hardwares from NVIDIA and AMD Systems have a maximum of 24 GB of VRAM memory and commercial ones from NVIDIA have around 80 GB. However, the models I have in use require 90+ GB of memory. The model I have in mind is Falcon-70B-instruct[^1]. How is it achieved? Use multiple GPUs like NVIDIA A100 Tensor Core-GPU. Here, 2 units that give us barely 160 GB of memory. It is not a plug-and-play solution either. Methods like model quantization let us use multiple hardware to execute AI Models. 

I neither have the budget nor the resources to test these to develop a prototype of my project. But how much would the budget be to deploy such a solution?

## Budgeting

In the far future, the hardware requirements would be close to a speced-out Comino grando Liquid-cooled multi-gpu workstation / server [^2]. An estimate of cost for the totally speced-out version would cost:

| Component              | Cost    |
|------------------------|---------|
| CPU x2                 | $16000  |
| GPU x4                 | $20800  |
| RAM                    | $1900   |
| Overall Minimum Budget | $38700+ |

38700 USD just for server. The Electricity costs and networking costs will pile up. In an enterprise setting, this is not costly.

## Enter Mac Studio

The developers constantly optimize AI tools like Pytorch and Tensorflow for the ARM processors of Apple Devices. A fully speced-out Mac Studio[^3] costs 8800 USD only. The one I might require only costs 6700 USD. Now that is one order-of-magnitude reduction of costs. This Mac Studio has 192GB RAM that is shared by both CPU and GPU. Not to mention, dedicated AI cores available in the SOC also shares it. This implies that the CPU and GPU can work simultaneously and efficiently. Not to mention the power efficiency of the machine, it saves the costs of running a server multifold. The power consumption of Mac Studio is 370 Watts only. Whereas the Linux Server from Comino is around 2.5kW. So, Mac Studio as a server is very cost effective and climate friendly.

## Issues

Mac Studio comes pre-installed with MacOS Ventura or Sonoma, which is a desktop OS. To turn it into a server, we can use NGINX or Apache and deploy the software we wish to use. The Graphical User Interface and Mac programs would run in the background, reducing the performance of the hardware. One solution is to install Asahi Linux[^4], which is an Arch-based distro specific to Apple Silicon Macs. However, Arch-based systems are upstream and have unstable packages and still require heavy development. To host a server, one needs a downstream OS with stability and security battle-tested.


[^1]: https://huggingface.co/tiiuae/falcon-40b-instruct
[^2]: https://www.grando.ai/
[^3]: https://www.apple.com/mac-studio/
[^4]: https://asahilinux.org/