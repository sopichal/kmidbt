# Example Queries

These SQL files demonstrate various vector search operations. Run them in CloudBeaver (GUI) or from the command line.

## Available Examples

### Basic Similarity Searches

**example_01_find_similar_to_strawberry_cosine.sql**
- Find fruits most similar to Strawberry using cosine similarity
- Best for: Understanding basic vector similarity search
- Expected: Cherry, Blueberry (most similar profiles)

**example_02_find_similar_euclidean.sql**
- Same search using Euclidean (L2) distance
- Best for: Comparing different distance metrics
- Expected: Cherry, Blackberry, Plum

### Advanced Queries

**example_03_filter_by_sweetness.sql**
- Find fruits with high sweetness values
- Best for: Filtering by specific vector dimensions
- Shows two methods: vector similarity and text parsing

**example_04_custom_profile_search.sql**
- Search for fruits matching a custom flavor profile
- Best for: Understanding how to search with arbitrary vectors
- Example: moderately colored, very tasty, sweet, slightly sour fruits

**example_05_vector_arithmetic_simple.sql**
- Find fruits similar to the average of Strawberry + Banana
- Best for: Basic vector arithmetic concepts
- Pre-calculated average: [0.6, 0.75, 0.9, 0.35]

**example_06_vector_arithmetic_advanced.sql**
- Creates a PostgreSQL function for dynamic vector averaging
- Best for: Advanced programmatic vector manipulation
- Shows multiple blending examples

### Reference Guide

**reference_pgvector_operators.sql**
- Complete reference for all pgvector operators
- Distance metrics: cosine, euclidean, inner product
- Performance tips and indexing strategies
- Batch operations and advanced patterns

---

## How to Run Examples

### Option 1: CloudBeaver (GUI - Recommended for Beginners)

1. Open browser: http://localhost:9979
2. Connect to the vectordb database
3. Copy and paste any example query
4. Click "Execute" and explore results

### Option 2: Helper Scripts (Fastest)

```bash
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples

# Make scripts executable (one time only)
chmod +x run_example.sh run_all_examples.sh run_examples_quick.sh

# Run a single example
./run_example.sh 1              # Example 1: Strawberry similarity (cosine)
./run_example.sh 2              # Example 2: Strawberry similarity (euclidean)
./run_example.sh 3              # Example 3: Filter by sweetness
./run_example.sh 4              # Example 4: Custom profile
./run_example.sh 5              # Example 5: Vector arithmetic (simple)
./run_example.sh 6              # Example 6: Vector arithmetic (advanced)
./run_example.sh ref            # Reference guide

# Run all examples (with pause between each)
./run_all_examples.sh

# Run all examples (quick mode, no pauses)
./run_examples_quick.sh
```

### Option 3: Using `docker exec` (Most Flexible)

```bash
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples

# Run any example file
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < example_01_find_similar_to_strawberry_cosine.sql
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb < example_02_find_similar_euclidean.sql
# ... and so on

# Interactive psql session
docker exec -it postgres-vectordb psql -U vectoruser -d vectordb
# Then you can paste SQL or use: \i /path/to/file.sql
```

### Option 4: Using Docker Network

```bash
# Run query through Docker network
docker run -it --rm \
  --network vectordb_kmidbt-net \
  -v "$(pwd):/examples" \
  postgres:16 \
  psql -h postgres-vectordb -U vectoruser -d vectordb \
  -f /examples/example_01_find_similar_to_strawberry_cosine.sql

# Interactive session
docker run -it --rm \
  --network vectordb_kmidbt-net \
  postgres:16 \
  psql -h postgres-vectordb -U vectoruser -d vectordb
# Password: vectorpass
```

### Option 5: Using Local `psql` (If Installed)

```bash
# Run query from file
psql -h localhost -p 5432 -U vectoruser -d vectordb \
  -f example_01_find_similar_to_strawberry_cosine.sql
# Password: vectorpass

# Interactive session
psql -h localhost -p 5432 -U vectoruser -d vectordb
# Password: vectorpass
```

---

## Quick Reference Commands

### Check Database Status

```bash
# Check if container is running
docker ps | grep postgres-vectordb

# Check database connection
docker exec postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT 1;"

# Count fruits
docker exec postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT COUNT(*) FROM fruits;"

# List all fruits
docker exec postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT name FROM fruits ORDER BY name;"
```

### Quick One-Liner Queries

```bash
# Find fruits similar to Strawberry
docker exec postgres-vectordb psql -U vectoruser -d vectordb -c \
  "SELECT name, embedding <=> '[0.9, 0.8, 0.85, 0.6]' as distance 
   FROM fruits 
   WHERE name != 'Strawberry'
   ORDER BY distance 
   LIMIT 5;"

# Find sweet fruits
docker exec postgres-vectordb psql -U vectoruser -d vectordb -c \
  "SELECT name, embedding <=> '[0, 0, 1, 0]' as sweetness
   FROM fruits 
   ORDER BY sweetness 
   LIMIT 5;"

# Show all data with nice formatting
docker exec postgres-vectordb psql -U vectoruser -d vectordb \
  --pset=format=aligned \
  --pset=border=2 \
  -c "SELECT * FROM fruits;"
```

---

## Database Connection Info

| Parameter | Value |
|-----------|-------|
| **Container** | postgres-vectordb |
| **Network** | vectordb_kmidbt-net |
| **Host** | postgres-vectordb (inside Docker) or localhost (from host) |
| **Port** | 5432 |
| **Database** | vectordb |
| **User** | vectoruser |
| **Password** | vectorpass |

---

## Troubleshooting

### Container not running?
```bash
docker compose up -d
docker ps | grep postgres-vectordb
```

### Check logs
```bash
docker logs postgres-vectordb
docker logs --tail 50 postgres-vectordb
```

### Restart database
```bash
docker compose restart postgres-vectordb
```

### Check network
```bash
docker network ls | grep vectordb
docker network inspect vectordb_kmidbt-net
```

### Test connection
```bash
docker exec postgres-vectordb pg_isready
docker exec postgres-vectordb psql -U vectoruser -l
```

---

## Pro Tips

1. **Use `docker exec`** - Simplest and most reliable method
2. **Helper scripts** - Fastest way to run multiple examples
3. **Format output** - Add `--pset=format=aligned --pset=border=2` for readable tables
4. **Save results** - Redirect output with `> results.txt`
5. **Measure time** - Add `\timing on` in psql interactive sessions
6. **CloudBeaver** - Best for visual exploration and result analysis

## Example Workflow

```bash
# 1. Navigate to examples directory
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb/examples

# 2. Make scripts executable (first time only)
chmod +x *.sh

# 3. Run examples in order
./run_example.sh 1
./run_example.sh 2
./run_example.sh 3

# Or run all at once (quick mode)
./run_examples_quick.sh

# 4. Explore results visually in CloudBeaver
open http://localhost:9979
```

## Learning Path

**Beginners:** Start with CloudBeaver (GUI) and example_01  
**Intermediate:** Use helper scripts to run multiple examples  
**Advanced:** Use `docker exec` for automation and scripting  

---

## Need Help?

```bash
# Show available examples and usage
./run_example.sh

# Read main project documentation
cat ../README.md

# Check database status
docker compose ps
```
