#!/bin/bash

# 01_setup_demo.sh
# Setup script for AI Embedding Demo
# Creates the text_embeddings table in PostgreSQL with pgvector

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database connection details
DB_USER="vectoruser"
DB_NAME="vectordb"
CONTAINER_NAME="postgres-vectordb"

echo -e "${YELLOW}=== AI Embedding Demo Setup ===${NC}\n"

# Check if PostgreSQL container is running
echo "Checking if PostgreSQL container is running..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}Error: PostgreSQL container '$CONTAINER_NAME' is not running${NC}"
    echo "Please start it with: cd .. && docker compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL container is running${NC}\n"

# Check if SQL script exists
SQL_SCRIPT="$(dirname "$0")/sql/01_create_table.sql"
if [ ! -f "$SQL_SCRIPT" ]; then
    echo -e "${RED}Error: SQL script not found: $SQL_SCRIPT${NC}"
    exit 1
fi

# Execute the SQL script using docker exec
echo "Creating text_embeddings table..."
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" < "$SQL_SCRIPT"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Setup completed successfully!${NC}\n"
    echo "Table 'text_embeddings' is ready for use."
    echo "Next steps:"
    echo "  1. Get embeddings: ./02_get_embeddings.sh --text \"Your text\""
    echo "  2. Store embeddings: ./03_store_embeddings.sh --text \"Your text\""
    echo "  3. Query similar: ./04_query_similar.sh --text \"Query text\""
else
    echo -e "\n${RED}✗ Setup failed${NC}"
    exit 1
fi
