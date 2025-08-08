#!/bin/bash

# Docker GPT-OSS CLI - Model Download Script

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"
MODEL_ID="openai/gpt-oss-20b"

# Get project root directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOST_CACHE_DIR="${PROJECT_ROOT}/cache"

echo "Docker GPT-OSS Model Downloader"
echo "==============================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if image exists
if ! docker image inspect ${IMAGE_NAME} &> /dev/null; then
    echo "Image not found. Building first..."
    "${SCRIPT_DIR}/build.sh"
fi

# Create cache directory if it doesn't exist
mkdir -p "${HOST_CACHE_DIR}"

# Download model using huggingface-cli in container
echo "Downloading model: ${MODEL_ID}"
echo "Cache directory: ${HOST_CACHE_DIR}"
echo "This may take a while (~40GB)..."
echo ""

docker run --rm \
    -v "${HOST_CACHE_DIR}:/app/cache" \
    -e HF_HOME=/app/cache \
    ${IMAGE_NAME} \
    hf download ${MODEL_ID} \
    --local-dir /app/cache/models/${MODEL_ID}

echo ""
echo "Model downloaded successfully!"
echo "Cache directory: ${HOST_CACHE_DIR}"