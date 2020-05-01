## Create Image ##

The following Dockerfile will build an Ubuntu server image based on Ubuntu 20.04 LTS.

    docker build -t ubuntu-server:focal \
        --build-arg ROOT_PASSWD='root' .

Use the following build command if you want to add a separate non-root user that matches the user and group IDs/names of the non-root host user :

    docker build -t ubuntu-server:focal \
        --build-arg USER_NAME=$USER \
        --build-arg USER_ID=$(id -u) \
        --build-arg GROUP_ID=$(id -g) \
        --build-arg USER_PASSWD='user' --build-arg ROOT_PASSWD='root' .

This ensures correct file system permissions if you bind mount local filesystems when running the image.

## Run Image ##

Use following command to simply run the image :

    docker run -d --rm \
        --name volatile-ubuntu-server \
        -h volatile-ubuntu-server \
        ubuntu-server:focal

Use following command to create a container from the image :

    docker run -d \
        --name ubuntu-server \
        -h ubuntu-server \
        ubuntu-server:focal

## Network cofiguration ##

In order to bind the ubuntu server container into your network, bridging it with your physical network interface, you need to create a macvlan docker network for your container :

    docker network create \
        -d macvlan \
        --subnet <your subnet> \
        --gateway <the gateway address in your network> \
        --ip-range <the IP address range available in this docker network> \
        -o parent=<network interface to bind to> \
        <docker network name>

Example :

    docker network create \
        -d macvlan \
        --subnet 192.168.10.0/24 \
        --gateway 192.168.10.1 \
        --ip-range 192.168.10.10/32 \
        -o parent=eth0 \
        my_service

* Note : setting the IP range to "/32" allows for only one IP to be usable by docker, under which the docker container host is reachable by other machines on your network.

## Run Image in a specific docker network ##

Use following command to run the image in the specific docker network :

    docker run -d --rm \
        --name volatile-ubuntu-server \
        --network my_service \
        -h volatile-ubuntu-server \
        ubuntu-server:focal
