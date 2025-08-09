#!/bin/bash

# Script to start Transformers Chat API server container

set -e

# Configuration
IMAGE_NAME="gpt-oss-cli"
CONTAINER_NAME="transformers-chat-server"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Set default model path if not provided
MODEL_PATH="${MODEL_PATH:-$PROJECT_ROOT/cache}"

echo "Starting Transformers Chat API Server..."
echo "Model path: $MODEL_PATH"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if model path exists
if [ ! -d "$MODEL_PATH/models/openai/gpt-oss-20b" ]; then
    echo "Error: Model not found at: $MODEL_PATH/models/openai/gpt-oss-20b"
    echo "Please ensure the model files are in the specified location."
    echo "You can specify a custom path with: MODEL_PATH=/path/to/cache ./start.sh"
    exit 1
fi

# Stop existing container if running
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "Stopping existing container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Build Docker image
echo "Building Docker image..."
docker build -t "$IMAGE_NAME" "$PROJECT_ROOT"

# Create cache directory if it doesn't exist
mkdir -p "${MODEL_PATH}"

# Run container
echo "Starting container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --gpus all \
    --dns 8.8.8.8 \
    --dns 8.8.4.4 \
    -p 8000:8000 \
    -v "${MODEL_PATH}:/app/cache" \
    -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
    "$IMAGE_NAME"

# Wait for container to start
echo "Waiting for server to start..."
sleep 5

# Check if container is running
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✓ Server started successfully!"
    echo "API endpoint: http://localhost:8000"
    echo ""
    echo "To test the API, run: ./scripts/test_api.sh"
    echo "To stop the server, run: ./scripts/stop.sh"
    echo ""
    echo "Container logs:"
    docker logs --tail 10 "$CONTAINER_NAME"
else
    echo "✗ Failed to start server"
    echo "Check logs with: docker logs $CONTAINER_NAME"
    exit 1
fi