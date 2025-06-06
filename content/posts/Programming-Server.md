+++
date = '2025-04-24T13:44:51+02:00'
draft = false
title = 'A Programming Server'
useAlpine = false
tags = [
    "Programming",
    "Development Environment",
    "Ubuntu Server",
    "Docker",
    "Remote Development"
]
+++

This semester, I face quite a few programming-based courses. This means having a suitable development environment and seamless experience; not troubleshooting differences in implementing the compilers (or interpreters) in different operating systems. What I am fussing about is that I use a Windows PC, a MacBook Pro and an iPad as I wish. Setting up and using the programming dependencies on each platform is different. I want to focus on debugging errors generated by me, not on the platform. So, I decided it was time I setup a unified programming platform I can access from anywhere and on any of the above devices.

My requirements are quite simple. I need to write algorithms in C/C++ for a course (so I can brush up on this language I have known for a long time) and plot using Python, another course requires me to use Python to do statistical data analysis, I wanna experiment with `openmp` and `mpi` in C/C++, and do some rust application development. I also need to do some heavy Machine Learning to program in Python, but I can use my MacBook Pro to speed up the process specifically for that(you will soon know why this is the case).

A simple solution to all this problem would be to use MacBook Pro for all the programming, however, Apple hates the Fortran/C++ libraries optimized to run on x86-64 platform that is used heavily for HPC, they only support libraries that would make them money; can't blame that. So, I can set up everything on my Windows machine and RDP into that machine from my MacBook Pro or my iPad. But RDP isn't snappy and requires a significant bandwidth, which is doubtful in Germany.

My solution is to set up a programming server with an NUC I have lying around here. So I installed a barebones Ubuntu Server (don't bother me with version, whatever was the LTS version that was recently released). Here is the BTop++ window after I SSH into the system.

![](/images/system-info.png)

Now, to access this within my local network is simple. I have assigned the IP address it currently has to be set permanently in my local network. I can access this device, provided I know the credentials to login, from any device I have. Then, I setup tailscale network so that I can access it if I am at the library or at the university.

![](/images/tailscale.png)

Now, I installed a cockpit (I like webmin, but it is old and apparently has some security issues) to try, and I love it. This is to manage the server, updating the packages, etc. I can do it over the command-line interface, but sometimes a GUI adds a pleasant touch.

![](/images/cockpit.png)

Next, I installed Docker and Portainer to run a lot of docker containers. Currently, I am running a VS-Code server so I can have an IDE to program on the fly, in the browser. To save and synchronize all my work, I logged into my GitHub account.

![](/images/portainer.png)
![](/images/vscode-server.png)

Then I installed `gcc`, `gfortran`, `rustup`, `openmp`and `mpi` libraries to work with. I got the `cmake` to make my life simpler to deal with all these compilers' build processes.

I then setup `miniconda` with `jupyterlab` for Python development. Then I compiled some hello world programs for these to test if I missed any dependencies. This finishes my setup for programming. I have `ollama` running on my Plex server and on my MacBook Pro. I might get the `openwebui` in the docker version in this server to use both these machines to run LLMs locally, more on that [here](https://ashwinbalaji.xyz/series/local-llms/). Currently, I use Amazon's Alexa, but may switch to Home Assistant later. In that case, I would set it up here, alongside Prometheus and Grafana. Or I might just move all the Docker stuff to a proper NAS setup I plan to build in the future, which would run TrueNAS Scale. We cross that bridge when it arrives.

P.S: I am a Dune Nerd and chose `username` and `hostname` for this server from those novels. I quite liked Jessica Atredis influencing the Corrinos' at Salusa Secundus. Hence the choices - if you noticed it! 