# AI Embedding Demo

This demo showcases text embeddings using OpenAI's `text-embedding-3-small` model and PostgreSQL with the pgvector extension for semantic similarity search.

## Overview

This demo provides a complete workflow for:
1. Getting text embeddings from OpenAI API
2. Storing embeddings in PostgreSQL with pgvector
3. Querying similar texts using cosine similarity

The system supports three input methods:
- Direct text strings
- Text files
- PDF documents (with text extraction)

## Prerequisites

### Required

1. **Docker** - For running PostgreSQL with pgvector (includes psql via docker exec)
2. **jq** - For JSON processing
   ```bash
   # macOS
   brew install jq

   # Linux
   apt-get install jq
   ```
3. **OpenAI API Key** - Get one at https://platform.openai.com/api-keys

### Optional (for PDF support)

4. **poppler-utils** - For PDF text extraction
   ```bash
   # macOS
   brew install poppler

   # Linux
   apt-get install poppler-utils
   ```

## Database Configuration

The demo uses the existing PostgreSQL database:

- **Host**: localhost
- **Port**: 5432
- **User**: vectoruser
- **Password**: vectorpass
- **Database**: vectordb
- **Container**: postgres-vectordb

## Directory Structure

```
aiembeding/
├── .env                      # Environment variables (OPENAI_API_KEY) - GITIGNORED
├── README.md                 # This file
├── sql/                      # SQL scripts
│   ├── 01_create_table.sql  # Create text_embeddings table
│   ├── 02_insert_demo_data.sql  # INSERT template examples
│   └── 03_query_examples.sql    # Similarity query examples
├── samples/                  # Sample text files
│   ├── dog.txt
│   ├── cat.txt
│   └── duckbill.txt
├── 01_setup_demo.sh         # Setup database table
├── 02_get_embeddings.sh     # Get embeddings from OpenAI
├── 03_store_embeddings.sh   # Store embeddings in database
├── 04_query_similar.sh      # Query similar texts
├── add_embedding.sh         # RECOMMENDED: Combined get+store (prevents mismatches)
└── test_embeddings.md       # Direct curl API examples
```

## Setup Instructions

### 1. Start PostgreSQL

```bash
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb
docker compose up -d
```

Verify it's running:
```bash
docker ps | grep postgres-vectordb
```

### 2. Initialize Database

```bash
cd aiembeding
./01_setup_demo.sh
```

This creates the `text_embeddings` table with:
- `id` - Primary key
- `text` - Original text content
- `source` - Source identifier (demo, file:*, pdf:*)
- `embedding` - 1536-dimensional vector
- `metadata` - JSONB for flexible metadata
- `created_at` - Timestamp

### 3. Verify Setup

Check that the OpenAI API key is configured:
```bash
cat .env
```

Should show:
```
OPENAI_API_KEY=sk-proj-...
```

## Usage

All scripts support three mutually exclusive parameters:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `--text "string"` | Direct text input | `--text "Dog"` |
| `--text-file FILE` | Read from text file | `--text-file samples/dog.txt` |
| `--pdf-file FILE` | Extract from PDF | `--pdf-file document.pdf` |

### Workflow 1: Simple Text Embedding (RECOMMENDED METHOD)

Use the combined `add_embedding.sh` script to avoid mismatches:

```bash
# Add embedding (get + store in one step)
./add_embedding.sh --text "Dog"
./add_embedding.sh --text "Cat"
./add_embedding.sh --text "Lynx"
./add_embedding.sh --text "Duckbill"


# Query similar texts
./04_query_similar.sh --text "Puppy"
```

### Workflow 2: Manual Two-Step Process (Advanced)

If you need to see the embedding before storing it:

```bash
# Step 1: Get embedding from OpenAI
./02_get_embeddings.sh --text "Dog"

# Step 2: Store in database (MUST run immediately after step 1)
./03_store_embeddings.sh --text "Dog"

# Step 3: Query similar texts
./04_query_similar.sh --text "Cat"
```

**⚠️ Important**: When using the manual two-step process, you MUST run `03_store_embeddings.sh` immediately after `02_get_embeddings.sh` with the **same parameters**. Otherwise, you'll store the wrong embedding!

### Workflow 3: Text File Embedding

```bash
# Add embedding from text file (recommended)
./add_embedding.sh --text-file samples/cat.txt

# Query with different text
./04_query_similar.sh --text "feline"
```

### Workflow 4: PDF Embedding (requires poppler)

```bash
# Add embedding from PDF (recommended)
./add_embedding.sh --pdf-file document.pdf

# Query with another PDF
./04_query_similar.sh --pdf-file query.pdf
```

### Complete Example Session (RECOMMENDED)

```bash
# 1. Setup (one time)
./01_setup_demo.sh

# 2. Add some sample embeddings using the combined script
./add_embedding.sh --text "Dog"
./add_embedding.sh --text "Cat"
./add_embedding.sh --text "Duckbill"

# 3. Query for similar texts
./04_query_similar.sh --text "Puppy"
# Should return "Dog" as most similar

./04_query_similar.sh --text "Kitten"
# Should return "Cat" as most similar

./04_query_similar.sh --text "Platypus"
# Should return "Duckbill" as most similar

./04_query_similar.sh --text "Perry"
# Hoping for "Duckbill" as most similar
```

## Script Details

### 01_setup_demo.sh

Creates the `text_embeddings` table and verifies the PostgreSQL connection.

**Usage:**
```bash
./01_setup_demo.sh
```

### 02_get_embeddings.sh

Fetches embeddings from OpenAI API and saves the response to `/tmp/embedding_response.json`.

**Features:**
- Validates API key from `.env`
- Supports three input methods
- Displays first 10 dimensions of embedding
- Shows token usage
- Pretty prints JSON with `jq`

**Usage:**
```bash
./02_get_embeddings.sh --text "Your text here"
./02_get_embeddings.sh --text-file path/to/file.txt
./02_get_embeddings.sh --pdf-file path/to/document.pdf
```

### 03_store_embeddings.sh

Stores the embedding (from previous step) into the PostgreSQL database.

**Features:**
- Reads embedding from `/tmp/embedding_response.json`
- Automatically sets source and metadata based on input type
- Escapes text for SQL safety
- Returns inserted record details

**Usage:**
```bash
./03_store_embeddings.sh --text "Your text here"
./03_store_embeddings.sh --text-file path/to/file.txt
./03_store_embeddings.sh --pdf-file path/to/document.pdf
```

**Important:** Must run `02_get_embeddings.sh` with the same parameters first.

### 04_query_similar.sh

Queries the database for texts similar to the input.

**Features:**
- Gets embedding for query text from OpenAI
- Performs cosine similarity search
- Returns top 5 most similar results
- Shows similarity scores (0-1, where 1 is identical)

**Usage:**
```bash
./04_query_similar.sh --text "Query text"
./04_query_similar.sh --text-file path/to/file.txt
./04_query_similar.sh --pdf-file path/to/document.pdf
```

## Database Schema

The `text_embeddings` table structure:

```sql
CREATE TABLE text_embeddings (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    source VARCHAR(255) DEFAULT 'demo',
    embedding vector(1536) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Indexes

Cosine similarity index for fast vector search:
```sql
CREATE INDEX text_embeddings_embedding_idx
ON text_embeddings
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

### Metadata Examples

**Direct text:**
```json
{"type": "demo", "input_method": "direct"}
```

**Text file:**
```json
{"type": "file", "filename": "sample.txt", "size_bytes": 1234}
```

**PDF file:**
```json
{"type": "pdf", "pdf_filename": "document.pdf", "size_bytes": 56789}
```

## SQL Query Examples

The `sql/03_query_examples.sql` file contains various query patterns:

### Basic Similarity Search
```sql
SELECT
    id,
    text,
    source,
    1 - (embedding <=> '[...]'::vector(1536)) as similarity
FROM text_embeddings
ORDER BY embedding <=> '[...]'::vector(1536)
LIMIT 5;
```

### Filter by Source
```sql
WHERE source LIKE 'pdf:%'
```

### Filter by Metadata
```sql
WHERE metadata->>'pdf_filename' = 'document.pdf'
```

## Understanding Similarity Scores

The cosine similarity score ranges from 0 to 1:

- **1.0** - Identical (same text)
- **0.9-0.99** - Very similar (synonyms, paraphrases)
- **0.8-0.89** - Similar (related concepts)
- **0.7-0.79** - Somewhat similar (same domain)
- **<0.7** - Less similar (different topics)

## Future: PDF Integration

The system is designed for future PDF text embedding workflows:

### Planned Features

1. **Chunk large PDFs** - Split PDFs into page or paragraph chunks
2. **Track page numbers** - Store page information in metadata
3. **Batch processing** - Process multiple PDFs in one go
4. **PDF search** - Find relevant pages across multiple documents

### Metadata for PDF Chunks

```json
{
  "type": "pdf",
  "pdf_filename": "document.pdf",
  "page_number": 5,
  "chunk_index": 2,
  "total_chunks": 10,
  "chunk_start": 0,
  "chunk_end": 500
}
```

## Troubleshooting

### "PostgreSQL container is not running"

```bash
cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb
docker compose up -d
```

### "jq is required but not installed"

```bash
# macOS
brew install jq

# Linux
apt-get install jq
```

### "OPENAI_API_KEY not set"

Check that `.env` file exists and contains:
```bash
OPENAI_API_KEY=sk-proj-...
```

Source it manually:
```bash
source .env
echo $OPENAI_API_KEY
```

### "pdftotext is required"

Only needed for `--pdf-file` option:
```bash
# macOS
brew install poppler

# Linux
apt-get install poppler-utils
```

### API Request Failed

Check your OpenAI API key:
1. Verify it's valid at https://platform.openai.com/api-keys
2. Check for billing/usage limits
3. Ensure the key has embeddings API access

### Database Connection Failed

Verify PostgreSQL container is accessible:
```bash
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT 1;"
```

## Cost Estimation

**OpenAI text-embedding-3-small Pricing:** $0.00002 per 1K tokens

- Single word: ~1 token = $0.00000002
- Sentence (10-20 words): ~10-20 tokens = $0.0000002-$0.0000004
- Paragraph (100 words): ~100 tokens = $0.000002
- Page (500 words): ~500 tokens = $0.00001

For detailed pricing: https://openai.com/pricing

## Additional Resources

- **OpenAI Embeddings Guide**: https://platform.openai.com/docs/guides/embeddings
- **pgvector Documentation**: https://github.com/pgvector/pgvector
- **PostgreSQL Vector Operations**: See `sql/03_query_examples.sql`
- **Direct API Testing**: See `test_embeddings.md`

## License

This is educational material for the KMI DBT course at Palacký University.
