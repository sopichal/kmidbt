#!/bin/bash
# Run a single example by number
# Usage: ./run_example.sh 1
#        ./run_example.sh 3

if [ -z "$1" ]; then
    echo "Usage: $0 <example_number>"
    echo ""
    echo "Available examples:"
    echo "  1 - Find similar to Strawberry (cosine)"
    echo "  2 - Find similar to Strawberry (euclidean)"
    echo "  3 - Filter by sweetness"
    echo "  4 - Custom profile search"
    echo "  5 - Vector arithmetic (simple)"
    echo "  6 - Vector arithmetic (advanced)"
    echo "  ref - pgvector operators reference"
    echo ""
    echo "Example: $0 1"
    exit 1
fi

EXAMPLES_DIR="/Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples"
cd "$EXAMPLES_DIR"

# Map number to filename
case "$1" in
    1)
        FILE="example_01_find_similar_to_strawberry_cosine.sql"
        ;;
    2)
        FILE="example_02_find_similar_euclidean.sql"
        ;;
    3)
        FILE="example_03_filter_by_sweetness.sql"
        ;;
    4)
        FILE="example_04_custom_profile_search.sql"
        ;;
    5)
        FILE="example_05_vector_arithmetic_simple.sql"
        ;;
    6)
        FILE="example_06_vector_arithmetic_advanced.sql"
        ;;
    ref|reference)
        FILE="reference_pgvector_operators.sql"
        ;;
    *)
        echo "❌ Invalid example number: $1"
        exit 1
        ;;
esac

if [ ! -f "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
fi

echo "📄 Running: $FILE"
echo "=========================================="
echo ""

docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < "$FILE"

echo ""
echo "✅ Done!"
