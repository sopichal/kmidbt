# Vector Database Project with pgvector

This project demonstrates using PostgreSQL with the pgvector extension for storing and querying vector embeddings.

## Project Structure

```
vectordb/
├── compose.yaml              # Docker Compose configuration
├── ddl/                      # Auto-run initialization scripts
│   ├── 01_create_extension.sql
│   ├── 02_create_tables.sql
│   └── 03_insert_data.sql
├── examples/                 # Manual query examples
│   ├── example_01_find_similar_to_strawberry_cosine.sql
│   ├── example_02_find_similar_euclidean.sql
│   ├── example_03_filter_by_sweetness.sql
│   ├── example_04_custom_profile_search.sql
│   ├── example_05_vector_arithmetic_simple.sql
│   ├── example_06_vector_arithmetic_advanced.sql
│   └── reference_pgvector_operators.sql
├── start.sh                  # Quick start script
└── restart.sh                # Clean restart script
```

## Overview

- **Database**: PostgreSQL 16 with pgvector extension
- **Web Client**: CloudBeaver (accessible at http://localhost:9979)
- **Use Case**: Fruit similarity search using 4D embeddings

## Vector Dimensions

Each fruit is represented by a 4-dimensional vector:
- **[0]** Color (0.0-1.0): darkness/intensity of color
- **[1]** Taste (0.0-1.0): overall taste quality
- **[2]** Sweetness (0.0-1.0): level of sweetness
- **[3]** Sourness (0.0-1.0): level of tartness/acidity

## Quick Start

### 1. Start the Services

```bash
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb
./start.sh
```

Or manually:
```bash
docker compose up -d
```

### 2. Verify Services

```bash
docker compose ps
docker compose logs postgres-vectordb
```

### 3. Access CloudBeaver

1. Open browser: http://localhost:9979
2. First time setup:
   - Create admin user
   - Add new connection:
     - Driver: PostgreSQL
     - Host: postgres-vectordb
     - Port: 5432
     - Database: vectordb
     - User: vectoruser
     - Password: vectorpass

## Automatic Initialization

The following scripts run automatically on first startup (from `/ddl` directory):

1. **01_create_extension.sql** - Enables pgvector extension
2. **02_create_tables.sql** - Creates `fruits` table with vector column and index
3. **03_insert_data.sql** - Inserts 16 sample fruits with embeddings

After initialization, you'll have:
- ✅ pgvector extension enabled
- ✅ `fruits` table with 4D vector embeddings
- ✅ IVFFlat index for fast similarity search
- ✅ 16 sample fruits ready for querying

## Example Queries

All example queries are in the `/examples` directory. Run them in CloudBeaver (GUI) or from command line.

### Basic Examples

1. **example_01** - Find fruits similar to Strawberry (cosine similarity)
2. **example_02** - Find fruits similar to Strawberry (Euclidean distance)
3. **example_03** - Filter fruits by sweetness dimension

### Advanced Examples

4. **example_04** - Search by custom flavor profile
5. **example_05** - Vector arithmetic (simple blending)
6. **example_06** - Vector arithmetic (advanced with functions)

### Reference

- **reference_pgvector_operators.sql** - Complete pgvector operator guide

### Running Examples

**Option 1: CloudBeaver (GUI)**
- Open http://localhost:9979
- Copy/paste queries and execute

**Option 2: Command Line**
```bash
cd examples/

# Run single example
chmod +x run_example.sh
./run_example.sh 1          # Run example 1

# Run all examples (with pause between)
chmod +x run_all_examples.sh
./run_all_examples.sh

# Run all examples (quick mode)
chmod +x run_examples_quick.sh
./run_examples_quick.sh

# Or manually with docker exec
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < example_01_find_similar_to_strawberry_cosine.sql
```

See `/examples/README.md` for complete command-line documentation.

## Key Concepts

### Distance Metrics

**Cosine Distance** (`<=>`)
- Measures angular difference between vectors
- Range: 0 (identical) to 2 (opposite)
- Best for normalized embeddings
- Formula: 1 - (A·B)/(||A||×||B||)

**Euclidean Distance (L2)** (`<->`)
- Measures straight-line distance
- Sensitive to magnitude
- Good for absolute differences

**Inner Product** (`<#>`)
- Dot product of vectors
- Useful for unnormalized vectors

### Strawberry Similarity Example

Strawberry vector: `[0.9, 0.8, 0.85, 0.6]`
- High color (0.9) - red/pink
- High taste (0.8) - flavorful
- High sweetness (0.85) - very sweet
- Moderate sourness (0.6) - slight tartness

Expected similar fruits:
1. **Cherry** - Similar color, sweetness, low sourness
2. **Blueberry** - Similar taste and sweetness profiles
3. **Blackberry** - Similar berry characteristics
4. **Raspberry** - Similar color, moderate sweetness

## Sample Data

The database includes 16 fruits across color categories:

| Category | Fruits |
|----------|--------|
| **Red/Pink** | Strawberry, Raspberry, Watermelon, Cherry |
| **Yellow/Orange** | Banana, Orange, Mango, Pineapple |
| **Green** | Green Apple, Kiwi, Lime, Green Grape |
| **Purple/Blue** | Blueberry, Blackberry, Plum, Purple Grape |

## Management Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f postgres-vectordb

# Stop services
docker compose down

# Clean restart (removes all data)
./restart.sh

# Manual clean restart
docker compose down
rm -rf datadir/ cloudbeaver-data/
docker compose up -d
```

## Index Performance

The `ivfflat` index dramatically improves query performance:
- Without index: O(n) - scans all vectors
- With index: O(√n) - approximate nearest neighbor search
- Trade-off: slight accuracy loss for major speed gain

Note: You may see "index created with little data" warning on first startup. This is normal - the index performs better with 100+ vectors.

## Troubleshooting

**Issue**: Container exits with code 3
**Solution**: Check logs with `docker compose logs postgres-vectordb`. Usually indicates a SQL error in initialization scripts.

**Issue**: CloudBeaver won't connect
**Solution**: Wait ~10 seconds after starting for PostgreSQL to be fully ready. Verify with `docker compose ps`.

**Issue**: Queries returning unexpected results
**Solution**: Check that data was inserted correctly with `SELECT * FROM fruits;`

## Next Steps

1. **Run the examples** - Start with example_01 in CloudBeaver
2. **Experiment** - Modify search vectors and parameters
3. **Add more data** - Insert your own fruits with custom vectors
4. **Scale up** - Test with larger datasets (100+ vectors)
5. **Explore applications**:
   - Use real AI embeddings (OpenAI, Sentence Transformers)
   - Build recommendation systems
   - Create semantic search
   - Implement image similarity search

## Learning Resources

- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [PostgreSQL Vector Operations](https://github.com/pgvector/pgvector#vector-operators)
- [CloudBeaver Guide](https://cloudbeaver.io/docs/)
- [Vector Database Concepts](https://www.pinecone.io/learn/vector-database/)

---

**Created**: December 2025  
**Database**: PostgreSQL 16 + pgvector 0.8.1  
**Purpose**: Learning vector databases and similarity search
