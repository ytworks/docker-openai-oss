#!/bin/bash

# Docker GPT-OSS CLI - Run Script

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"
# Cache directory on host
HOST_CACHE_DIR="${HOME}/.cache/huggingface"

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

# Create cache directory if it doesn't exist
mkdir -p "${HOST_CACHE_DIR}"

# Run container with volume mount
echo "Starting container..."
echo "Cache directory: ${HOST_CACHE_DIR}"
docker run --gpus all -it --rm \
    -v "${HOST_CACHE_DIR}:/app/cache" \
    ${IMAGE_NAME}