# Base Ubuntu Server Image based on Ubuntu 20.04 LTS
#
# 2020-05-01 by Yank555.lu

FROM ubuntu:focal
MAINTAINER Jean-Pierre Rasquin <yank555-lu@gmail.com>

# Build Arguments
ARG USER_NAME="unset"
ARG USER_ID="unset"
ARG GROUP_ID="unset"
ARG USER_PASSWD="unset"
ARG ROOT_PASSWD

# Define Setup Environment
USER root
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Unminimize Ubuntu image
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes ; \
    apt-get update ; \
    apt-get upgrade ; \
    apt-get install apt-utils apt-transport-https ; \
    dpkg -S /usr/share/man/ |sed 's|, |\n|g;s|: [^:]*$||' | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y ; \
    dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {print $2}' | sed 's|/[^/]*$||' | sort |uniq \
         | xargs dpkg -S | sed 's|, |\n|g;s|: [^:]*$||' | uniq | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y ; \
    rm -f /usr/bin/man ; \
    dpkg-divert --quiet --remove --rename /usr/bin/man ; \
    apt-get install --reinstall -y man-db manpages ; \
    rm -f /etc/update-motd.d/60-unminimize ; \
    rm -f /usr/local/sbin/unminimize

# Install additional dependencies
RUN apt-get install -y --no-install-recommends \
    gnupg \
    net-tools \
    iputils-ping \
    dnsutils \
    iproute2 \
    traceroute \
    openssh-client \
    openssh-server \
    openssl \
    ca-certificates \
    curl \
    wget \
    git \
    zip \
    unzip \
    rsync \
    vim \
    python \
    python3 \
    runit \
    less \
    dialog \
    cifs-utils \
    nfs-client \
    cpio \
    ethtool \
    ftp

# Setup users and folders
RUN echo "root:$ROOT_PASSWD" | chpasswd

COPY assets/bashrc /tmp/build_image-bashrc
COPY assets/ssh-config /tmp/build_image-config

RUN if [ "$USER_NAME" = "unset" ] ; \
    then \
        rm /tmp/build_image-bashrc ; \
        rm /tmp/build_image-config ; \
    else \
        addgroup --gid $GROUP_ID $USER_NAME ; \
        adduser --home /home/$USER_NAME --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME ; \
        echo "$USER_NAME:$USER_PASSWD" | chpasswd ; \
        rm /home/$USER_NAME/.bashrc ; \
        mv /tmp/build_image-bashrc /home/$USER_NAME/.bashrc ; \
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/.bashrc ; \
        chmod 644 /home/$USER_NAME/.bashrc ; \
        mkdir /home/$USER_NAME/bin ; \
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/bin ; \
        chmod 755 /home/$USER_NAME/bin ; \
        mkdir /home/$USER_NAME/.ssh ; \
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh ; \
        chmod 700 /home/$USER_NAME/.ssh ; \
        mv /tmp/build_image-config /home/$USER_NAME/.ssh/config ; \
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/config ; \
        chmod 600 /home/$USER_NAME/.ssh/config ; \
    fi

# Setup my_init
COPY assets/my_init /sbin/my_init
RUN chmod 700 /sbin/my_init ; \
    mkdir -p /etc/my_init.d ; \
    mkdir -p /etc/my_init.pre_shutdown.d ; \
    mkdir -p /etc/my_init.post_shutdown.d

# Setup setuser
COPY assets/setuser /sbin/setuser
RUN chmod 700 /sbin/setuser

# Setup ssh server
COPY assets/sshd.runit /etc/service/sshd/run
RUN chmod 700 /etc/service/sshd/run ; \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config ; \
    rm /etc/ssh/ssh_host*key* ; \
    touch /etc/service/sshd/never_run

# Set Timezone to Luxembourg
RUN ln -sf /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime

# Start services
ENTRYPOINT ["/sbin/my_init"]
