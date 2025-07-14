+++
date = '2025-07-14T15:55:58+02:00'
draft = true
title = 'Comments Are Here! Sort of'
useAlpine = false
tags = [
    "dunno",
    "letsee"
]
series = "Comments"
+++

## Preface
If you have visited my site before, and navigated to `Datenschutzerklärung > TL;DR`, you would have noticed this information box:

{{< notice info >}}
**Coming Soon:** [Remark42](https://remark42.com/) is a lightweight, open source commenting engine that doesn’t spy on you, the user. I am hosting it in a private server provided by Hetzner cloud in Nuremberg, Germany. You don't have to login to comment on any article. Just say hi or comment away your views.
{{< /notice >}}

You won't find it anymore, because I have set up the comments system for this website. Well - sort of. Here is what I have done (so far) to get it working on this site.

## The Server Setup

I rented a VPS from Hetzner Cloud specifically for this purpose. Here are the specifications:

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

A new window will open. Just follow my lead, `Ctrl + V`, `CTRL + X`, `Y` and `Return`. Press those keys, and you got the key copied into the server. Now, we edit the `ssh` config file to use this key for login, and remove using user password to login. Run the following commands:

{{<highlight text>}}sudo nano /etc/ssh/sshd_config{{</highlight>}}

Now scroll down the file using down arrow key on your keyboard, and remove the `#` for the following commands and change `yes` or `no` based on what you see below:

{{<highlight text>}}PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30{{</highlight>}}

Now, the same routine, `Ctrl + V`, `CTRL + X`, `Y` and `Return`. If you noticed there is `.ssh/authorized_keys` and `.ssh/authorized_keys2`. This is one way of adding more keys to your server and sharing it with others for them to login and help you with something (can't think of anything). When they are done, you can just remove the key, and they can't login again. Proper cool if you ask me. Now, in the server terminal, type the following:

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

## The Application Setup

## Further Problems
This is a screenshot of the webpage running locally in my website. I haven't typewritten the whole article, and you can see some more draft articles linked here. But the chat just works fine, except for the CSP issues that keeps it from working on this site in production.
![](/images/commet-box-render.png)