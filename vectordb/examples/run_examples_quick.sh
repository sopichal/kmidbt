#!/bin/bash
# Run all examples quickly without pausing
# Usage: ./run_examples_quick.sh

set -e

EXAMPLES_DIR="/Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples"
cd "$EXAMPLES_DIR"

echo "🚀 Running all examples (quick mode)..."
echo ""

# Check container
if ! docker ps | grep -q postgres-vectordb; then
    echo "❌ Container not running. Start with: docker compose up -d"
    exit 1
fi

# Run all examples
for sql_file in example_*.sql; do
    echo "▶️  $sql_file"
    docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < "$sql_file" 2>&1 | head -20
    echo ""
done

echo "✅ All examples completed!"
