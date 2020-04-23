# Dockerfile kali-light

# From the Kali linux base image
FROM kalilinux/kali-rolling

# For faster package downloads install transport https & certificates
RUN apt update -y && apt install apt-transport-https -y && apt install ca-certificates -y

# Update kali repo
RUN echo "deb https://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
echo "deb-src https://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list

#  noninteractive – You use this mode when you need zero interaction while installing or upgrading the system via apt. It accepts the default answer for all questions.
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm-256color

# System update
RUN apt-get update -y && apt-get clean all && apt -y upgrade && apt -y autoremove && apt clean
RUN echo 'VERSION_CODENAME=kali-rolling' >> /etc/os-release

# Some system tools
RUN apt-get install -y git colordiff colortail unzip vim tmux xterm curl telnet strace ltrace tmate less build-essential wget python3-setuptools python3-pip tor proxychains proxychains4 zstd net-tools iputils-ping bash-completion iputils-tracepath yarnpkg procps htop lsof iptables


# Tools
RUN apt-get install -y --no-install-recommends --allow-unauthenticated \
crunch \
dirb \
dirbuster \
dnsenum \
dnsrecon \
dnsutils \
dos2unix \
enum4linux \
exploitdb \
ftp \
git \
gobuster \
hashcat \
hydra \
impacket-scripts \
john \
joomscan \
masscan \
metasploit-framework \
ncat \
netcat-traditional \
nikto \
nmap patator \
php \
powersploit \
recon-ng \
samba \
smbclient \
smbmap \
sqlmap \
sslscan \
vim \
wafw00f \
whois \
wordlists \
wpscan \
openssh-server \
set \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install python FTP server module
RUN pip3 install pyftpdlib

# Tor refresh every 5 requests
RUN echo MaxCircuitDirtiness 10 >> /etc/tor/torrc && \
    update-rc.d tor enable

# Use random proxy chains / round_robin_chain for pc4
RUN sed -i 's/^strict_chain/#strict_chain/g;s/^#random_chain/random_chain/g' /etc/proxychains.conf && \
    sed -i 's/^strict_chain/#strict_chain/g;s/^round_robin_chain/round_robin_chain/g' /etc/proxychains4.conf


# Alias
RUN echo "alias ll='ls -al'" >> /root/.bashrc
RUN echo "alias nse='ls /usr/share/nmap/scripts | grep '" >> /root/.bashrc
RUN echo "alias pip='pip3'" >> /root/.bashrc
RUN echo "alias python='python3'" >> /root/.bashrc
RUN echo "alias scan-range='nmap -T5 -n -sn'" >> /root/.bashrc
RUN echo "alias http-server='python3 -m http.server 8080'" >> /root/.bashrc
RUN echo "alias php-server='php -S 127.0.0.1:8080 -t .'" >> /root/.bashrc
RUN echo "alias ftp-server='python3 -m pyftpdlib -u \"admin\" -P \"S3cur3d_Ftp_3rv3r\" -p 2121'" >> /root/.bashrc
RUN source /root/.bashrc

# Create known_hosts for git cloning
RUN mkdir -p /root/.ssh/ && touch /root/.ssh/known_hosts

# Add host keys
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Set entrypoint and working directory
WORKDIR /root/

# Indicate we want to expose ports 80 and 443
EXPOSE 80/tcp 443/tcp 8080/tcp 2121/tcp 9050/tcp

# Welcome message
RUN echo "echo 'Welcome to Kali Light Container !\n\n- If you need proxychains over Tor just activate tor service with:\n$ service tor start\n'" >> /etc/profile

CMD ["/bin/bash", "--init-file", "/etc/profile"]
