# Base Ubuntu Server Image based on Ubuntu 20.04 LTS
#
# 2020-05-01 by Yank555.lu

FROM ubuntu:focal
MAINTAINER Jean-Pierre Rasquin <yank555-lu@gmail.com>

# Build Arguments
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
ARG USER_PASSWD
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

RUN addgroup --gid $GROUP_ID $USER_NAME
RUN adduser --home /home/$USER_NAME --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME
RUN echo "$USER_NAME:$USER_PASSWD" | chpasswd

RUN rm /home/$USER_NAME/.bashrc
COPY assets/bashrc /home/$USER_NAME/.bashrc
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/.bashrc
RUN chmod 644 /home/$USER_NAME/.bashrc

RUN mkdir /home/$USER_NAME/bin
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/bin
RUN chmod 755 /home/$USER_NAME/bin

# Setup ssh client config
RUN mkdir /home/$USER_NAME/.ssh
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
RUN chmod 700 /home/$USER_NAME/.ssh

COPY assets/ssh-config /home/$USER_NAME/.ssh/config
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/config
RUN chmod 600 /home/$USER_NAME/.ssh/config

# Setup ssh server config (permit root password login)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set Timezone to Luxembourg
RUN ln -sf /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime

# Setup entrypoint shell script
COPY assets/entrypoint.sh /etc/entrypoint.sh
RUN chmod 700 /etc/entrypoint.sh

# Start services
ENTRYPOINT ["/etc/entrypoint.sh"]
