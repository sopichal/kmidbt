#!/bin/bash

# add_embedding.sh
# Combined script: Get embedding from OpenAI AND store it in database
# This prevents mismatches between get and store operations
# Supports three mutually exclusive input methods:
#   --text "string"         - Get and store embedding for direct text input
#   --text-file FILE        - Get and store embedding for text file
#   --pdf-file FILE         - Get and store embedding for PDF file

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Function to display usage
usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "This script combines get + store operations to prevent embedding mismatches"
    echo ""
    echo "Options (mutually exclusive - choose ONE):"
    echo "  --text \"text string\"     Add embedding for direct text input"
    echo "  --text-file FILE         Add embedding for text from file"
    echo "  --pdf-file FILE          Add embedding for PDF content"
    echo ""
    echo "Examples:"
    echo "  $0 --text \"Dog\""
    echo "  $0 --text-file samples/dog.txt"
    echo "  $0 --pdf-file document.pdf"
    exit 1
}

# Validate arguments
if [ $# -eq 0 ]; then
    usage
fi

echo -e "${YELLOW}=== Add Embedding (Get + Store) ===${NC}\n"

# Step 1: Get embedding
echo -e "${BLUE}Step 1/2: Getting embedding from OpenAI...${NC}\n"
"$SCRIPT_DIR/02_get_embeddings.sh" "$@"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to get embedding${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 2/2: Storing embedding in database...${NC}\n"

# Step 2: Store embedding
"$SCRIPT_DIR/03_store_embeddings.sh" "$@"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to store embedding${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Successfully added embedding!${NC}"
