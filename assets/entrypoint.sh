#!/bin/sh

# Exit script on any error
set -e

# Start services
echo " "
echo "Starting services :"
service ssh start

echo " "
echo "Switching to user $ENTRYPOINT_DEFAULT_USER..."
echo " "
su - "$ENTRYPOINT_DEFAULT_USER"
