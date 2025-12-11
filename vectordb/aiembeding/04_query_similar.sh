#!/bin/bash

# 04_query_similar.sh
# Query similar texts from the database using cosine similarity
# Supports three mutually exclusive input methods:
#   --text "string"         - Find texts similar to direct text input
#   --text-file FILE        - Find texts similar to text file content
#   --pdf-file FILE         - Find texts similar to PDF content

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Database connection details
DB_USER="vectoruser"
DB_NAME="vectordb"
CONTAINER_NAME="postgres-vectordb"

# OpenAI API configuration
API_URL="https://api.openai.com/v1/embeddings"
MODEL="text-embedding-3-small"
RESULT_LIMIT=5

# Function to display usage
usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "Options (mutually exclusive - choose ONE):"
    echo "  --text \"text string\"     Find texts similar to direct text input"
    echo "  --text-file FILE         Find texts similar to text file content"
    echo "  --pdf-file FILE          Find texts similar to PDF content"
    echo ""
    echo "Examples:"
    echo "  $0 --text \"Cat\""
    echo "  $0 --text-file samples/cat.txt"
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

echo -e "${YELLOW}=== Querying Similar Texts ===${NC}\n"
echo -e "${BLUE}Input method:${NC} $INPUT_METHOD"
echo -e "${BLUE}Query text length:${NC} ${#INPUT_TEXT} characters"
echo -e "${BLUE}Result limit:${NC} Top $RESULT_LIMIT most similar"
echo ""

# Preview query text
TEXT_PREVIEW=$(echo "$INPUT_TEXT" | head -c 100)
echo -e "${BLUE}Query text preview:${NC}"
echo "$TEXT_PREVIEW..."
echo ""

# Get embedding for query text
echo -e "${BLUE}Getting embedding from OpenAI...${NC}"

ESCAPED_TEXT=$(echo "$INPUT_TEXT" | jq -Rs .)

HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"$MODEL\", \"input\": $ESCAPED_TEXT}")

HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

if [ "$HTTP_STATUS" != "200" ]; then
    echo -e "${RED}Error: API request failed with status $HTTP_STATUS${NC}"
    echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"
    exit 1
fi

QUERY_EMBEDDING=$(echo "$HTTP_BODY" | jq -c '.data[0].embedding')

if [ -z "$QUERY_EMBEDDING" ] || [ "$QUERY_EMBEDDING" = "null" ]; then
    echo -e "${RED}Error: Could not extract embedding from API response${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Query embedding received${NC}\n"

# Query the database for similar texts
echo -e "${BLUE}Searching database for similar texts...${NC}\n"

SQL_QUERY="SELECT
    id,
    LEFT(text, 100) as text_preview,
    source,
    metadata,
    1 - (embedding <=> '$QUERY_EMBEDDING'::vector(1536)) as cosine_similarity,
    embedding <=> '$QUERY_EMBEDDING'::vector(1536) as cosine_distance,
    created_at
FROM text_embeddings
ORDER BY embedding <=> '$QUERY_EMBEDDING'::vector(1536)
LIMIT $RESULT_LIMIT;"

RESULT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "$SQL_QUERY")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}=== Search Results (Top $RESULT_LIMIT) ===${NC}\n"
    echo "$RESULT"
    echo ""
    echo -e "${BLUE}Similarity score interpretation:${NC}"
    echo "  1.0 = Identical"
    echo "  0.9-0.99 = Very similar"
    echo "  0.8-0.89 = Similar"
    echo "  0.7-0.79 = Somewhat similar"
    echo "  <0.7 = Less similar"
else
    echo -e "${RED}✗ Query failed${NC}"
    exit 1
fi
