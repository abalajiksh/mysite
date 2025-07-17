+++
date = '2025-07-14T15:55:58+02:00'
draft = false
title = 'Comments Are Here! Sort of'
useAlpine = false
tags = [
    "Remark42",
    "Self-Hosting",
    "Server Administration",
    "CSP Issues",
    "Cloudflare",
    "Web Development"
]
series = "Self-Hosting a Comments Engine: Remark42"
+++

## Preface
If you have visited my site before, and navigated to `Datenschutzerklärung > TL;DR`, you would have noticed this information box:

{{< notice info >}}
**Coming Soon:** [Remark42](https://remark42.com/) is a lightweight, open source commenting engine that doesn’t spy on you, the user. I am hosting it in a private server provided by Hetzner cloud in Nuremberg, Germany. You don't have to login to comment on any article. Just say hi or comment away your views.
{{< /notice >}}

You won't find it anymore, because I have set up the comments system for this website. Well - sort of. Here is what I have done (so far) to get it working on this site.

## Server Setup

I rented a Virtual Private Server (VPS) from Hetzner Cloud running `Ubuntu Server 24.04 LTS` specifically for this purpose. Here are the specifications:

![](/images/hetzner.png)

{{< notice warning >}}
In this article, there are a lot of commands to follow through. Any place you see a `\`, that is directory specification for Windows only. If you wanna do this in a Linux pc or a Mac, just replace it with `/` and it should just work fine. Still doesn't work? Ask a GPT model to fix it for you. `scp` is Windows specific command, AFAIK.
{{< /notice >}}

After server initialization, I `ssh` into the server as `root` from my Windows terminal. The first thing to do is create a new user account with administrative privileges and disable remote `root` access, for enhanced security. To create a new user, run the following commands:

{{<highlight text>}}adduser abksh{{</highlight>}}

{{<highlight text>}}usermod -aG sudo abksh{{</highlight>}}

With the first line of command, it will ask for password, name, room, etc. The password is mandatory, but other details don't matter. After running these commands, open a new Terminal window and try `ssh`ing into the server as this user. Mine looked like `ssh abksh@remark42`. Of course you have to give your server's IP address instead of `remark42`or you can tell windows to know that the `hostname` called `remark42` points to the server's IP address. Then the above command will work just fine. I am lazy and didn't care to do it, FYI. Once you can login, setup `ssh` keys on your windows pc, then copy the PUBLIC key (the one with `.pub` extension) to the server, specifically to the location `~/.ssh/authorized_keys`. Here, `authorized_keys` is a text file, not a folder. Here is the list of commands as I described what I was doing:

{{<highlight text>}}ssh-keygen -t ed25519 -C "your_email@example.com"{{</highlight>}}

Here we are using ECDSA algorithm to generate keys. Setup the password for the keys when it asks you to, do not skip this step. Other algorithms available are RSA and ECDSA. Quantum computers can crack RSA, which relies on prime multiplication. ECDSA and EDDSA are algorithms using Elliptic Curves. I am going to pretend you know what that means, cause I don't. All I know (for now) is that they are more difficult to crack and have smaller key sizes that are faster to check the signatures. Especially the EDDSA algorithm has small computational footprint to verify key signatures compared to the other two. Now copy the PUBLIC key to the server using the below commands:

{{<highlight text>}}scp ~\.ssh\id_ed25519.pub abksh@remark42:~/.ssh/authorized_keys{{</highlight>}}

If the above command doesn't work, most probably this file and folder doesn't exist. Henceforth, if any command cannot run, just add `sudo` in front of the command provided. It will ask for user password to execute, provide it, and you are ready. So, go to the server terminal and run:

{{<highlight text>}}cd ~
mkdir /.ssh
cd /.ssh
touch authorized_keys{{</highlight>}}

{{<highlight text>}}chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys{{</highlight>}}

Now, go back to windows, and collect the contents of `id_ed25519.pub` file. Easiest way to achieve that is to do:

{{<highlight text>}}cd ~\.ssh

notepad id_ed25519.pub{{</highlight>}}

{{< notice note >}}
Instead of typing `notepad` in the terminal, you can type `cat` to display the contents of the file directly in terminal. This works on all operating systems, but `notepad` will work only on Windows.
{{< /notice >}}

Copy the contents of the file, go back to the server terminal and run this command:

{{<highlight text>}}cd ~/.ssh

sudo nano authorized_keys{{</highlight>}}

A new window will open. Just follow my lead, `Ctrl + V`, `Ctrl + X`, `Y` and `Return`. Press those keys, and you got the key copied into the server. Now, we edit the `ssh` config file to use this key for login, and remove using user password to login. Run the following commands:

{{<highlight text>}}sudo nano /etc/ssh/sshd_config{{</highlight>}}

Now scroll down the file using down arrow key on your keyboard, and remove the `#` for the following commands and change `yes` or `no` based on what you see below:

{{<highlight text>}}PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30{{</highlight>}}

Now, the same routine, `Ctrl + V`, `Ctrl + X`, `Y` and `Return`. If you noticed there is `.ssh/authorized_keys` and `.ssh/authorized_keys2`. This is one way of adding more keys to your server and sharing it with others for them to login and help you with something (can't think of anything). When they are done, you can just remove the key, and they can't login again. Proper cool if you ask me. Now, in the server terminal, type the following:

{{<highlight text>}}sudo systemctl reload sshd
sudo systemctl restart sshd{{</highlight>}}

Now, don't logout from the server terminal, open another and try logging in with the same user, if you can login, then you did it right, if not you did something wrong and it is time for you to retrace all steps and double-check them. Now, you can close the first window by running the command `exit`. Now, nobody but you can login to the server who has the `ssh` keys, knows the password to the `ssh` keys and the password of the user. Now, we do some updating and set security updates to automatic updates, so we can forget about it after we set it up now. Run the following commands:

{{<highlight text>}}sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt install unattended-upgrades{{</highlight>}}

Now, time to secure all the ports that aren't in use. Run the following:

{{<highlight text>}}sudo apt install ufw -y
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing{{</highlight>}}
{{<highlight text>}}
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw limit ssh{{</highlight>}}

Now, we blocked all the ports except the ones used by `HTTP`, `HTTPS` and `SSH`. We will set a `HTTP` redirect to `HTTPS` later. We also limited the attempts to try `SSH` severely, so that nobody can try to brute-force their way in. This is quite secure, in my opinion, if you are skeptical, you may go ahead and setup `fail2ban` and `apparmor` for further enhanced security.

## Application Setup

### Remark42

This is fairly straightforward. Follow along the documentation for the setup [here](https://remark42.com/docs/getting-started/installation/). I setup the binary instead of using a docker container. Why you ask? It is because I hate docker, and it just adds overhead and more maintenance work. I downloaded the latest binary from the GitHub releases and unpacked the file. Login to the server and then run the following commands. If you are reading this article at-least a month after its publication, update the URL to the latest release. If you went with an ARM CPU for your server, use the `arm64` version, else `amd64` will do.

{{<highlight text>}}wget https://github.com/umputun/remark42/releases/download/v1.14.0/remark42.linux-amd64.tar.gz{{</highlight>}}

{{<highlight text>}}
tar -xvzf remark42.linux-amd64.tar.gz
{{</highlight>}}

We have now unpacked the contents. Let us move it to a working directory for ease of management for future purposes. Ideally executables in Linux systems are loaded up in `/usr/local/bin` directory. We will not do that. We copy to a directory where this binary generates files and does other stuff. Execute the following commands:

{{<highlight text>}}cd /var/www{{</highlight>}}

{{<highlight text>}}mkdir remark42 && cd ~{{</highlight>}}

{{<highlight text>}}cp remark42.linux-amd64 /var/www/remark42{{</highlight>}}

If these command don't work (they usually don't), prefix `sudo` to these commands and then they would work just fine. Now, we setup directory ownership, permissions and executability of this binary. Execute:

{{<highlight text>}}sudo chown -R www-data:www-data /var/www/remark42{{</highlight>}}

{{<highlight text>}}sudo chmod -R 755 /var/www/remark42{{</highlight>}}

{{<highlight text>}}sudo chown www-data:www-data /var/www/remark42/remark42.linux-amd64{{</highlight>}}

We are changing the binary executable to a user named `www-data`. Wait, we didn't create an user like that. How does it exist? `www-data` is the user that runs stuff in your server every time someone tries to access the webpage, and is available by default. To check the executable runs perfectly fine, run the following command:

{{<highlight text>}}sudo -u www-data /var/www/remark42/remark42.linux-amd64 server --secret=12345 --url=http://127.0.0.1:8080{{</highlight>}}

Change that 12345 to some other number for security reasons. I am not sure what that number does, need to check documentation. Keep the number safe. `Ctrl + C`to end the process. We can't keep this server connection open and run this command every time. What if the server updates, or something crashes in the system? What is there is a DDoS attack crashing this application on the server? We want it to turn on automatically so we don't have to worry about it. So, we create a system service that does this for us. Most Linux systems ship with `systemd` as process manager. There are exceptions, but if you land with those exceptions, you don't need this article; you know enough to follow the documentation and set it up yourself.

First let us create a environment variables file that contains the `SECRET` and `URL` data. Run this:

{{<highlight text>}}touch /etc/remark42.env{{</highlight>}}

{{<highlight text>}}nano /etc/remark42.env{{</highlight>}}

Now copy the below stuff, changing 12345 to some other secure number that you used earlier.

{{<highlight text>}}
SECRET=12345
REMARK_URL=http://127.0.0.1:8080
{{</highlight>}}

Now, the same routine, `Ctrl + V`, `Ctrl + X`, `Y` and `Return`. Again, change the `12345`to the number you used before; do this just after the `Ctrl + V` step. Let us ensure `www-data` can read this file.

{{<highlight text>}}chown www-data /etc/remark42.env && chmod 664 /etc/remark42.env{{</highlight>}}

`662` means the user and their usergroup `www-data` can read and write to the file and other users can only read the file. What it means is `7` signifies read, write and execute properties, `6` signifies read and write and `4` signifies read only access. Or in other words `4`+`2`+`1` is read+write+execute in Linux.

Now, we create a `systemd` file that says where to find all the bits and pieces are and how to execute it. Execute the below commands:

{{<highlight text>}}sudo touch /etc/systemd/system/remark42.service{{</highlight>}}

{{<highlight text>}}sudo nano /etc/systemd/system/remark42.service{{</highlight>}}

Now copy and paste the below configuration:

{{<highlight text>}}
[Unit]
Description=Remark42 Commenting Server
After=syslog.target
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/remark42.env
ExecStart=/var/www/remark42/remark42.linux-amd64 server
WorkingDirectory=/var/www/remark42       
Restart=on-failure
User=www-data                              
Group=www-data

[Install]
WantedBy=multi-user.target
{{</highlight>}}

Again, `Ctrl + V`, `Ctrl + X`, `Y` and `Return`. Note in line 9, change to arm-64, just after the `Ctrl + V`, if using an ARM server. Execute these commands to enable and run the server as a service.

{{<highlight text>}}systemctl enable remark42{{</highlight>}}

{{<highlight text>}}systemctl start remark42{{</highlight>}}

Now Remark42 is running in the background, and you can check by loading `SERVER_IP_ADDRESS:8080` if you didn't do the `ufw` step. Unfortunately for us, we blocked that port. You can release the port and check it in action, but we aren't doing that. Do you know why? 'cause I am lazy. Now, we need to set up a proxy-pass-through or reverse-proxy to serve this in `HTTP` and `HTTPS`.

### Interlude

You will have to setup the domain for this server and obtain SSL certificates for the next section to be a breeze. To setup domain, you have to edit the DNS records, simply add a `A` record, with name value as comment and IPv4 as the IP address of your server. This will take upto 48 hours to get into effect; however, it happens in the matter of minutes. Here is my setup (sensitive information is redacted of course).

![](/images/dns-records-cf.png)

And obtain Origin server certificates from Cloudflare if you are also using the same. Here is where you get it, in case you don't know where the option is:

![](/images/origin-server-ssl-cf.png)

### `NGINX`
This section will fly like a breeze. Execute this command to install `NGINX`.

{{<highlight text>}}sudo apt install nginx -y{{</highlight>}}

{{<highlight text>}}sudo systemctl enable nginx && sudo systemctl start nginx{{</highlight>}}

Next, we upload SSL certificates to our web server. I believe you already have a blog set up with SSL certificates. Use the same if this is going to be in the same domain. If not you can get a free one using `Lets Encrypt SSL` which is free. I am not going to do that either. I am going to proxy the server through Cloudflare's edge servers, so Cloudflare gives free SSL certificates. I generated them (you want Origin Certificates, because server is the origin in Cloudflare's terminology) and uploaded them to a directory I know where. Once you have this ready, execute the below commands:

{{<highlight text>}}sudo touch /etc/nginx/sites-available/remark42.conf{{</highlight>}}

{{<highlight text>}}sudo nano /etc/nginx/sites-available/remark42.conf{{</highlight>}}

Now copy and paste the below configuration:

{{<highlight text>}}
server {
    listen 80;
    server_name comment.ashwinbalaji.xyz www.comment.ashwinbalaji.xyz;
    return 301 https://comment.ashwinbalaji.xyz$request_uri;
}

server {
    listen 443 ssl;
    server_name comment.ashwinbalaji.xyz;

    ssl_certificate /path/to/public/key;
    ssl_certificate_key /path/to/private/key;

    # Enforce TLS 1.2 and above
    ssl_protocols TLSv1.2 TLSv1.3;

    # Cipher suite to enhance security
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';

    # Enable HSTS to enforce HTTPS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
{{</highlight>}}

Now, `Ctrl + V` to paste the contents. change `comment.ashwinbalaji.xyz` to whatever domain name you choose to use. Add the proper location for SSL certificates. Next few lines make sure we use only TLS1.2 and above, and corresponding ciphers that make sure we have good security standards. The first server block will redirect all `HTTP` requests to `HTTPS` using a 301 redirect. We could simply not have it, but that will affect your SEO ratings if half the time your website is unreachable. That is what I choose to believe, maybe there are better reasons, I don't know.

Once you have done that, follow our gold standard routine to save the file, yet again, `Ctrl + X`, `Y` and `Return`.

Now execute the following command, so `NGINX` knows that such a configuration file exists. This is called symlinking. It is like creating a shortcut to an original file. So, if you edit the original, the symlinked one will also update automatically.

{{<highlight text>}}sudo ln -s /etc/nginx/sites-available/remark42.conf /etc/nginx/sites-enabled/{{</highlight>}}

Now, time to test if we configured everything correctly. Execute the below command to check:

{{<highlight text>}}sudo nginx -t{{</highlight>}}

You will know if there are errors, or if it is alright, based on the output you get. Now, we reload NGINX and see if everything went just fine.

{{<highlight text>}}sudo systemctl reload nginx{{</highlight>}}

Now, you can access the Remark42 from the browser. It would say 404 not found, but that is fine. It means it is working.
## Website Setup

In case you haven't noticed, my [hugo](https://gohugo.io/) powered site uses [poison](https://github.com/lukeorth/poison) theme. I just followed the steps provided in the documentation to enable it on my website. It is simply adding these below lines, editing the URL for the server hosting Remark42, and giving my site, an ID. After some difficulties setting it up, it worked on my testing computer. Time to push online; a place where all of the hell breaks loose.

{{<highlight text>}}
[params]
    remark42 = true
    remark42_host = "https://yourhost.com"
    remark42_site_id = "your_site_id"
{{</highlight>}}

However, it is quite simple to add to your website, if you use Hugo, you just have to add the HTML code, change the credentials and make a `archetypes/layouts/partials`, say `comments.html` and import it to your `posts.html` partial file in you r theme folder. If you use Gatsby or Jekyll, the process is very similar. My best suggestion is to paste the link to the documentation, ask a GPT model of your choice, cloud or [local](https://ashwinbalaji.xyz/series/local-llms/), and you will get a step-by-step instructions on how to do so.

## Further Problems
The chat section isn't there online. I checked the webpage's source code, as shown below, it is present, but it is not working.

![](/images/further-problems-1.png)

Next, I checked the Network tab in Developer tools in the browser. The `embed.mjs` file sourced from `comment.ashwinbalaji.xyz` is not loading. Why? `Content-Security-Policy` header or CSP in short, doesn't have the values that recognize my sub-domain as part of the parent domain. I have to add the sub-domain by hand to make the browser load the one file that will help the comments section to work properly. Unfortunately, I ran into a lot of problems trying to add the values to CSP. Took a decision to write all of this down and save all those troubles for another post.

![](/images/further-problems-2.png)
![](/images/further-problems-3.png)

This is a screenshot of the webpage running locally in my website.
![](/images/commet-box-render.png)
I haven't typewritten the whole article, and you can see some more draft articles linked here. But the chat just works fine, except for the CSP issues that keeps it from working on this site in production.
