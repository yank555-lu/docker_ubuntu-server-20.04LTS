## Create Image ##

The following Dockerfile will build an Ubuntu server image based on Ubuntu 20.04 LTS.

It will include a container user that matches the user and group IDs and names of the host user. This ensures correct file system permissions if you bind mount local filesystems when running the image.

    docker build -t ubuntu-server:focal \
        --build-arg USER_NAME=$USER \
        --build-arg USER_ID=$(id -u) \
        --build-arg GROUP_ID=$(id -g) \
        --build-arg USER_PASSWD='user' --build-arg ROOT_PASSWD='root' .

## Run Image ##

Use following command to simply run the image :

    docker run --rm -it \
        -h volatile-ubuntu-server \
        ubuntu-server:focal

Use following command to create a container from the image :

    docker run -it \
        -h ubuntu-server \
        ubuntu-server:focal
