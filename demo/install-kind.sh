#!/bin/bash
# Determine the system architecture
ARCH=$(uname -m)

# Define the latest version of kind
KIND_VERSION=$(curl -sI https://github.com/kubernetes-sigs/kind/releases/latest | grep -i "location" | awk -F '/' '{print $NF}' | tr -d '\r')

# Check if the architecture is AMD64 / x86_64
if [ "$ARCH" = "x86_64" ]; then
	KIND_URL="https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64"
# Check if the architecture is ARM64
elif [ "$ARCH" = "aarch64" ]; then
	KIND_URL="https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-arm64"
else
	echo "Unsupported architecture: $ARCH"
	exit 1
fi

# Download kind binary
curl -Lo ./kind "$KIND_URL"

# Make the downloaded binary executable
chmod +x ./kind

# Move kind binary to /usr/local/bin for system-wide access (requires sudo)
sudo mv ./kind /usr/local/bin/kind

# Verify the installation
kind version
