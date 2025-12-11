#!/bin/bash

# 02_get_embeddings.sh
# Get embeddings from OpenAI API
# Supports three mutually exclusive input methods:
#   --text "string"         - Direct text input
#   --text-file FILE        - Read from text file
#   --pdf-file FILE         - Extract from PDF (requires pdftotext)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# OpenAI API configuration
API_URL="https://api.openai.com/v1/embeddings"
MODEL="text-embedding-3-small"
TEMP_FILE="/tmp/embedding_response.json"

# Function to display usage
usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "Options (mutually exclusive - choose ONE):"
    echo "  --text \"text string\"     Get embedding for direct text input"
    echo "  --text-file FILE         Get embedding for text from file"
    echo "  --pdf-file FILE          Get embedding for text from PDF (requires pdftotext)"
    echo ""
    echo "Examples:"
    echo "  $0 --text \"Dog\""
    echo "  $0 --text-file samples/dog.txt"
    echo "  $0 --pdf-file document.pdf"
    exit 1
}

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create $ENV_FILE with your OPENAI_API_KEY"
    exit 1
fi

source "$ENV_FILE"

if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${RED}Error: OPENAI_API_KEY not set in .env file${NC}"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Parse arguments
INPUT_TEXT=""
INPUT_METHOD=""

if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --text)
            if [ -n "$INPUT_METHOD" ]; then
                echo -e "${RED}Error: Only one input method allowed${NC}"
                usage
            fi
            INPUT_METHOD="text"
            INPUT_TEXT="$2"
            shift 2
            ;;
        --text-file)
            if [ -n "$INPUT_METHOD" ]; then
                echo -e "${RED}Error: Only one input method allowed${NC}"
                usage
            fi
            INPUT_METHOD="text-file"
            INPUT_FILE="$2"
            if [ ! -f "$INPUT_FILE" ]; then
                echo -e "${RED}Error: File not found: $INPUT_FILE${NC}"
                exit 1
            fi
            INPUT_TEXT=$(cat "$INPUT_FILE")
            shift 2
            ;;
        --pdf-file)
            if [ -n "$INPUT_METHOD" ]; then
                echo -e "${RED}Error: Only one input method allowed${NC}"
                usage
            fi
            INPUT_METHOD="pdf-file"
            INPUT_FILE="$2"

            # Check for pdftotext
            if ! command -v pdftotext &> /dev/null; then
                echo -e "${RED}Error: pdftotext is required for PDF support${NC}"
                echo "Install with:"
                echo "  macOS: brew install poppler"
                echo "  Linux: apt-get install poppler-utils"
                exit 1
            fi

            if [ ! -f "$INPUT_FILE" ]; then
                echo -e "${RED}Error: PDF file not found: $INPUT_FILE${NC}"
                exit 1
            fi

            # Extract text from PDF
            echo -e "${BLUE}Extracting text from PDF...${NC}"
            INPUT_TEXT=$(pdftotext "$INPUT_FILE" - 2>/dev/null)

            if [ -z "$INPUT_TEXT" ]; then
                echo -e "${RED}Error: Could not extract text from PDF${NC}"
                exit 1
            fi

            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Validate that we have input
if [ -z "$INPUT_TEXT" ]; then
    echo -e "${RED}Error: No input text provided${NC}"
    usage
fi

# Display input summary
echo -e "${YELLOW}=== Getting Embedding from OpenAI ===${NC}\n"
echo -e "${BLUE}Input method:${NC} $INPUT_METHOD"
echo -e "${BLUE}Text length:${NC} ${#INPUT_TEXT} characters"
echo -e "${BLUE}Model:${NC} $MODEL"
echo -e "${BLUE}API URL:${NC} $API_URL"
echo ""

# Preview text (first 100 characters)
TEXT_PREVIEW=$(echo "$INPUT_TEXT" | head -c 100)
echo -e "${BLUE}Text preview:${NC}"
echo "$TEXT_PREVIEW..."
echo ""

# Escape the input text for JSON (using jq)
ESCAPED_TEXT=$(echo "$INPUT_TEXT" | jq -Rs .)

# Make API request
echo -e "${BLUE}Sending request to OpenAI API...${NC}"

HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"$MODEL\", \"input\": $ESCAPED_TEXT}")

# Extract HTTP status code and body
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

# Check for errors
if [ "$HTTP_STATUS" != "200" ]; then
    echo -e "${RED}Error: API request failed with status $HTTP_STATUS${NC}"
    echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"
    exit 1
fi

# Save response to temp file with metadata about the input
echo "$HTTP_BODY" | jq --arg text "$INPUT_TEXT" --arg method "$INPUT_METHOD" \
    '. + {_metadata: {input_text: $text, input_method: $method}}' > "$TEMP_FILE"

echo -e "${GREEN}✓ Embedding received successfully!${NC}\n"

# Display embedding info
EMBEDDING_DIM=$(echo "$HTTP_BODY" | jq '.data[0].embedding | length')
echo -e "${BLUE}Embedding dimensions:${NC} $EMBEDDING_DIM"
echo -e "${BLUE}Saved to:${NC} $TEMP_FILE"
echo ""

# Display first 10 dimensions of the embedding
echo -e "${BLUE}First 10 dimensions of embedding vector:${NC}"
echo "$HTTP_BODY" | jq '.data[0].embedding[0:10]'
echo ""

# Display token usage
TOTAL_TOKENS=$(echo "$HTTP_BODY" | jq '.usage.total_tokens')
echo -e "${BLUE}Tokens used:${NC} $TOTAL_TOKENS"
echo ""

echo -e "${GREEN}Next step:${NC} Store this embedding with:"
echo "  ./03_store_embeddings.sh --$INPUT_METHOD $([ "$INPUT_METHOD" = "text" ] && echo "\"$INPUT_TEXT\"" || echo "$INPUT_FILE")"
