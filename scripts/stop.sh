#!/bin/bash

# Script to stop Transformers Chat API server container

set -e

# Configuration
CONTAINER_NAME="transformers-chat-server"

# Parse command line arguments
REMOVE_CONTAINER=false
if [ "$1" = "--rm" ] || [ "$1" = "-r" ]; then
    REMOVE_CONTAINER=true
fi

echo "Stopping Transformers Chat API Server..."

# Check if container exists
if ! docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "Container '$CONTAINER_NAME' not found."
    exit 0
fi

# Stop container if running
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Stopping container..."
    docker stop "$CONTAINER_NAME"
    echo "✓ Container stopped"
else
    echo "Container is not running"
fi

# Remove container if requested
if [ "$REMOVE_CONTAINER" = true ]; then
    echo "Removing container..."
    docker rm "$CONTAINER_NAME"
    echo "✓ Container removed"
else
    echo ""
    echo "To remove the container, run: $0 --rm"
fi

echo "Done!"