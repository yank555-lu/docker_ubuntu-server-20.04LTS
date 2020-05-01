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

# Install dependencies
USER root
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    net-tools \
    dnsutils \
    inetutils-ping \
    traceroute \
    openssh-client \
    openssh-server \
    curl \
    zip \
    unzip \
    rsync \
    vim \
    python \
    python3 \
    && apt-get purge -y --auto-remove \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Setup users and folders
ENV ENTRYPOINT_DEFAULT_USER=$USER_NAME

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

# Setup ssh server config (permit root password login)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set Timezone to Luxembourg
RUN ln -sf /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime

# Setup entrypoint shell script
COPY assets/entrypoint.sh /etc/entrypoint.sh
RUN chmod 700 /etc/entrypoint.sh

# Start services
ENTRYPOINT ["/etc/entrypoint.sh"]
