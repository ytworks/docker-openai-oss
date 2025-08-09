#!/bin/bash

# Script to test Transformers Chat API

set -e

# Configuration
API_URL="http://0.0.0.0:8000"
TEST_PROMPT="hi"

echo "Testing Transformers Chat API..."
echo "Endpoint: $API_URL"
echo ""

# Skip health check and proceed directly to API test
echo "Proceeding to API test..."
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
    echo "Received streaming response. Extracting content..."
    # Extract content from streaming response
    content=""
    while IFS= read -r line; do
        if [[ $line == data:* ]]; then
            # Remove "data: " prefix
            json_data="${line#data: }"
            # Skip empty data lines
            if [ "$json_data" != "" ] && [ "$json_data" != "[DONE]" ]; then
                # Extract delta content if available
                delta_content=$(echo "$json_data" | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
                if [ -n "$delta_content" ]; then
                    content="${content}${delta_content}"
                fi
            fi
        fi
    done <<< "$response"
    
    if [ -n "$content" ]; then
        echo "$content"
    else
        echo "(No content in response)"
    fi
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