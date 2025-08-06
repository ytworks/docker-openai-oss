#!/bin/bash

# Docker GPT-OSS CLI - Run Script

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"

echo "Docker GPT-OSS CLI"
echo "=================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if image exists
if ! docker image inspect ${IMAGE_NAME} &> /dev/null; then
    echo "Image not found. Building..."
    "$(dirname "$0")/build.sh"
fi

# Run container
echo "Starting container..."
docker run --gpus all -it --rm ${IMAGE_NAME}