#!/bin/bash
# Run all example queries sequentially
# Usage: ./run_all_examples.sh

set -e  # Exit on error

EXAMPLES_DIR="/Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples"
cd "$EXAMPLES_DIR"

echo "🚀 Running all vector database examples..."
echo "📁 Directory: $EXAMPLES_DIR"
echo ""

# Check if container is running
if ! docker ps | grep -q postgres-vectordb; then
    echo "❌ Error: postgres-vectordb container is not running"
    echo "   Start it with: docker compose up -d"
    exit 1
fi

# Check if database is ready
echo "🔍 Checking database connection..."
if ! docker exec postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Error: Cannot connect to database"
    echo "   Check logs with: docker logs postgres-vectordb"
    exit 1
fi

echo "✅ Database connection OK"
echo ""

# Run each example
for sql_file in example_*.sql; do
    echo "=========================================="
    echo "📄 Running: $sql_file"
    echo "=========================================="
    
    if docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < "$sql_file"; then
        echo "✅ Success"
    else
        echo "❌ Failed"
    fi
    
    echo ""
    echo "Press Enter to continue to next example (or Ctrl+C to stop)..."
    read
done

echo "=========================================="
echo "🎉 All examples completed!"
echo "=========================================="
