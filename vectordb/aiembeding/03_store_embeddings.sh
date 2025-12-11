#!/bin/bash

# 03_store_embeddings.sh
# Store embeddings in PostgreSQL database
# Supports three mutually exclusive input methods:
#   --text "string"         - Store embedding for direct text input
#   --text-file FILE        - Store embedding for text file
#   --pdf-file FILE         - Store embedding for PDF file

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
TEMP_FILE="/tmp/embedding_response.json"

# Function to display usage
usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "Options (mutually exclusive - choose ONE):"
    echo "  --text \"text string\"     Store embedding for direct text input"
    echo "  --text-file FILE         Store embedding for text from file"
    echo "  --pdf-file FILE          Store embedding for text from PDF"
    echo ""
    echo "Note: You must run 02_get_embeddings.sh first with the same parameters"
    echo ""
    echo "Examples:"
    echo "  $0 --text \"Dog\""
    echo "  $0 --text-file samples/dog.txt"
    echo "  $0 --pdf-file document.pdf"
    exit 1
}

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Parse arguments
INPUT_TEXT=""
INPUT_METHOD=""
SOURCE_NAME=""
METADATA="{}"

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
            SOURCE_NAME="demo"
            METADATA='{"type":"demo","input_method":"direct"}'
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
            FILE_BASENAME=$(basename "$INPUT_FILE")
            SOURCE_NAME="file:$FILE_BASENAME"
            FILE_SIZE=$(wc -c < "$INPUT_FILE")
            METADATA=$(jq -n --arg filename "$FILE_BASENAME" --argjson size "$FILE_SIZE" \
                '{type:"file",filename:$filename,size_bytes:$size}')
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

            FILE_BASENAME=$(basename "$INPUT_FILE")
            SOURCE_NAME="pdf:$FILE_BASENAME"
            FILE_SIZE=$(wc -c < "$INPUT_FILE")
            METADATA=$(jq -n --arg filename "$FILE_BASENAME" --argjson size "$FILE_SIZE" \
                '{type:"pdf",pdf_filename:$filename,size_bytes:$size}')
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

# Check if embedding file exists
if [ ! -f "$TEMP_FILE" ]; then
    echo -e "${RED}Error: Embedding file not found: $TEMP_FILE${NC}"
    echo "Please run 02_get_embeddings.sh first with the same parameters"
    exit 1
fi

echo -e "${YELLOW}=== Storing Embedding in Database ===${NC}\n"
echo -e "${BLUE}Input method:${NC} $INPUT_METHOD"
echo -e "${BLUE}Source:${NC} $SOURCE_NAME"
echo -e "${BLUE}Text length:${NC} ${#INPUT_TEXT} characters"
echo ""

# Extract embedding and metadata from the saved response
EMBEDDING_ARRAY=$(jq -c '.data[0].embedding' "$TEMP_FILE")
STORED_TEXT=$(jq -r '._metadata.input_text // empty' "$TEMP_FILE")

if [ -z "$EMBEDDING_ARRAY" ] || [ "$EMBEDDING_ARRAY" = "null" ]; then
    echo -e "${RED}Error: Could not extract embedding from $TEMP_FILE${NC}"
    exit 1
fi

# Validate that the stored embedding matches the text we're trying to store
if [ -n "$STORED_TEXT" ] && [ "$STORED_TEXT" != "$INPUT_TEXT" ]; then
    echo -e "${RED}Error: Embedding mismatch!${NC}"
    echo "The embedding in $TEMP_FILE is for:"
    echo "  \"${STORED_TEXT:0:100}...\""
    echo "But you're trying to store text:"
    echo "  \"${INPUT_TEXT:0:100}...\""
    echo ""
    echo "Please run: ./02_get_embeddings.sh with the same parameters first"
    exit 1
fi

# Escape text for SQL
ESCAPED_TEXT=$(echo "$INPUT_TEXT" | sed "s/'/''/g")

# Create SQL INSERT statement
SQL_INSERT="INSERT INTO text_embeddings (text, source, embedding, metadata)
VALUES (
    '$ESCAPED_TEXT',
    '$SOURCE_NAME',
    '$EMBEDDING_ARRAY'::vector(1536),
    '$METADATA'::jsonb
)
RETURNING id, text, source, metadata, created_at;"

echo -e "${BLUE}Inserting into database...${NC}"

# Execute the INSERT using docker exec
RESULT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "$SQL_INSERT")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Embedding stored successfully!${NC}\n"
    echo -e "${BLUE}Inserted record:${NC}"
    echo "$RESULT"
    echo ""
    echo -e "${GREEN}Next step:${NC} Query similar texts with:"
    echo "  ./04_query_similar.sh --text \"query text\""
else
    echo -e "${RED}✗ Failed to store embedding${NC}"
    exit 1
fi
