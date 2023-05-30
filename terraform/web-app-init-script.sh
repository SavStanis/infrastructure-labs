#!/bin/bash

IMAGE_NAME=savstanis/infrastructure-project

if [ -z "$IMAGE_NAME" ]; then
    echo "The IMAGE_NAME environment variable is not set."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    
    # Update the package index
    sudo apt update
    
    # Install necessary packages to use HTTPS
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Add the Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add the Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update the package index again
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Add the current user to the 'docker' group to run Docker without sudo
    sudo usermod -aG docker $USER
    
    echo "Docker has been installed successfully."
else
    echo "Docker is already installed."
fi

docker run -p 80:80 --detach "$IMAGE_NAME"

docker run --detach \
    --name watchtower \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower

