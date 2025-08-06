#!/bin/bash

# Docker GPT-OSS CLI - Build Script

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"

echo "Docker GPT-OSS CLI - Build"
echo "=========================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running"
    exit 1
fi

echo "Building Docker image..."
echo "Note: First build downloads ~40GB model (may take time)"
echo ""

# Get project root directory (parent of scripts)
PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"

# Build image from project root
docker build -t ${IMAGE_NAME} "${PROJECT_ROOT}"

echo ""
echo "Build completed!"
echo "Run with: ./scripts/run.sh"