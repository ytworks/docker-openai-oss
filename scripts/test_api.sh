#!/bin/bash

# Script to test Transformers Chat API

set -e

# Configuration
API_URL="http://0.0.0.0:8000"
TEST_PROMPT="Please explain how PAC1 receptor works in cell in detail"

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

# Make API request and format response
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
        "max_tokens": 512
    }' 2>&1)

# Check if request was successful
if [ $? -ne 0 ]; then
    echo "✗ Error: API request failed"
    echo "$response"
    exit 1
fi

# Check if response contains error
if echo "$response" | grep -q '"error"'; then
    echo "✗ API returned an error:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    exit 1
fi

# Extract and display the response content
if command -v jq &> /dev/null; then
    # If jq is available, use it for pretty formatting
    content=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    if [ $? -eq 0 ] && [ "$content" != "null" ]; then
        echo "$content"
    else
        echo "$response"
    fi
else
    # Fallback: display raw response
    echo "$response"
fi

echo ""
echo "========="
echo "✓ Test completed successfully!"