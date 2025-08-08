#!/bin/bash

# Docker GPT-OSS CLI - Run Script

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"
# Cache directory on host - use project's cache directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOST_CACHE_DIR="${PROJECT_ROOT}/cache"

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

# Run container with volume mount and DNS settings
echo "Starting container..."
echo "Cache directory: ${HOST_CACHE_DIR}"
echo "Using Triton backend with CUDA memory optimization"
docker run --gpus all -it --rm \
    --dns 8.8.8.8 \
    --dns 8.8.4.4 \
    -v "${HOST_CACHE_DIR}:/app/cache" \
    ${IMAGE_NAME}