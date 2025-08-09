#!/bin/bash

# Script to test Transformers Chat API

set -e

# Configuration
API_URL="http://0.0.0.0:8000"
TEST_PROMPT="hi! What is PAC1"

echo "Testing Transformers Chat API..."
echo "Endpoint: $API_URL"
echo ""

# Check available models
echo "Checking available models..."
models_response=$(curl -s "$API_URL/v1/models" 2>&1)

if [ $? -eq 0 ]; then
    echo "Available models:"
    # Extract model IDs using sed
    echo "$models_response" | grep -o '"id":"[^"]*"' | sed 's/"id":"\([^"]*\)"/  - \1/'
    echo ""
    
    # Extract first model ID for use in chat request
    model_id=$(echo "$models_response" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"\([^"]*\)"/\1/')
    if [ -z "$model_id" ]; then
        model_id="gpt-oss-20b"
        echo "Warning: Could not extract model ID, using default: $model_id"
    else
        echo "Using model: $model_id"
    fi
else
    echo "Warning: Could not fetch models list"
    model_id="gpt-oss-20b"
    echo "Using default model: $model_id"
fi
echo ""

# Send test request
echo "Sending test request..."
echo "Prompt: $TEST_PROMPT"
echo ""
echo "Response:"
echo "========="

# Make API request with streaming disabled
response=$(curl -s -X POST "$API_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "gpt-oss-20b",
        "messages": [
            {
                "role": "user",
                "content": "'"$TEST_PROMPT"'"
            }
        ],
        "temperature": 0.8,
        "max_tokens": 512,
        "stream": false
    }' 2>&1)

# Check if request was successful
if [ $? -ne 0 ]; then
    echo "✗ Error: API request failed"
    echo "$response"
    exit 1
fi

# Check if response is streaming (SSE format)
if echo "$response" | grep -q "^data: "; then
    echo "Received streaming response."
    echo ""
    echo "Raw response:"
    echo "---"
    echo "$response"
    echo "---"
    echo ""
    
    # Extract and display content
    echo "Assistant's response:"
    echo "---"
    # Extract content using sed
    echo "$response" | grep '"content":' | sed 's/.*"content":"\([^"]*\)".*/\1/' | tr -d '\n'
    echo ""
    echo "---"
elif echo "$response" | grep -q '"error"'; then
    echo "✗ API returned an error:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    exit 1
else
    # Try to extract content from standard response
    if command -v jq &> /dev/null; then
        content=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
        if [ $? -eq 0 ] && [ "$content" != "null" ] && [ -n "$content" ]; then
            echo "$content"
        else
            echo "$response"
        fi
    else
        echo "$response"
    fi
fi

echo ""
echo "========="
echo "✓ Test completed successfully!"