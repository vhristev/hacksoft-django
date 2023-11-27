#!/bin/bash
set -e

# Install Docker
wget -qO- https://get.docker.com/ | sh

sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl restart docker
sudo usermod -aG docker $(whoami)
newgrp docker
echo 'Docker installed successfully. Adding current user to "docker" group. Now you can use docker without "sudo"'
