#!/bin/bash
# Download the latest release with the command:
ARCH=$(uname -m)

# Install kubectl
if [ "$ARCH" == "x86_64" ]; then
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
elif [ "$ARCH" == "aarch64" ]; then
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
else
	echo "Unsupported architecture $ARCH"
	exit 1
fi

# Change the file mode to executable
sudo chmod +x ./kubectl

# Move the binary in to your PATH.
sudo mv ./kubectl /usr/local/bin/kubectl

# Validate installation
kubectl version
