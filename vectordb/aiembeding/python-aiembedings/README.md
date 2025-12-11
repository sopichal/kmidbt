# AI Embedding Demo - Python CLI

Cross-platform Python implementation of the AI embedding demo. Works on Windows, macOS, and Linux without requiring bash/shell scripts.

## Overview

This Python CLI tool provides three commands for working with OpenAI text embeddings and PostgreSQL pgvector:

1. **get-embeddings** - Fetch embeddings from OpenAI API
2. **store-embeddings** - Get embeddings and store in PostgreSQL
3. **query-similar** - Find similar texts using cosine similarity

## Features

- **Cross-platform**: Works on Windows, macOS, and Linux
- **Pure Python**: No external binaries required (uses pypdf instead of pdftotext)
- **Type safety**: Clear argument parsing with argparse
- **Multiple input methods**: Direct text, text files, or PDF files
- **Flexible text labeling**: Use `--text-key` to customize stored text labels

## Prerequisites

### Required Software

1. **Python 3.8+** - Check version:
   ```bash
   python --version  # or python3 --version
   ```

2. **uv** - Fast Python package manager (recommended)
   - Installation instructions below

3. **PostgreSQL with pgvector** - Must be running via Docker
   ```bash
   # Start from the parent directory
   cd ..
   docker compose up -d
   ```

4. **OpenAI API Key** - Get one at https://platform.openai.com/api-keys

## Installing uv

`uv` is a fast Python package manager that simplifies virtual environment management.

### Windows (PowerShell)

```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### macOS / Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Using pip (all platforms)

If you already have pip installed:

```bash
pip install uv
```

### Verify Installation

```bash
uv --version
```

## Setup

### 1. Navigate to Directory

```bash
cd /path/to/kmidbt/vectordb/aiembeding/python-aiembedings
```

### 2. Create Virtual Environment

Using uv (recommended):
```bash
uv venv
```

Or using standard Python:
```bash
python -m venv .venv
```

### 3. Activate Virtual Environment

**Windows (PowerShell):**
```powershell
.venv\Scripts\Activate.ps1
```

**Windows (Command Prompt):**
```cmd
.venv\Scripts\activate.bat
```

**macOS / Linux:**
```bash
source .venv/bin/activate
```

### 4. Install Dependencies

Using uv (recommended):
```bash
uv pip install -r requirements.txt
```

Or using pip:
```bash
pip install -r requirements.txt
```

### 5. Configure Environment Variables

Create a `.env` file in this directory:

```bash
# Copy from parent directory
cp ../.env .env
```

Or create manually with your OpenAI API key:
```
OPENAI_API_KEY=your-key-here
```

## Usage

### Command Structure

```bash
python aiembedingdemo.py <command> <input-option> [additional-options]
```

All commands support three mutually exclusive input options:
- `--text "string"` - Direct text input
- `--text-file FILE` - Read from text file
- `--pdf-file FILE` - Extract from PDF file

### Command: get-embeddings

Fetch embeddings from OpenAI API and display them.

**Examples:**

```bash
# Direct text
python aiembedingdemo.py get-embeddings --text "Dog"

# From text file
python aiembedingdemo.py get-embeddings --text-file ../samples/dog.txt

# From PDF
python aiembedingdemo.py get-embeddings --pdf-file document.pdf

# Show all 1536 dimensions (instead of first 10)
python aiembedingdemo.py get-embeddings --text "Dog" --full-array
```

**Options:**
- `--full-array` - Show all 1536 dimensions instead of just the first 10

**Output:**
- Text preview
- Text length
- Token usage
- Embedding vector (first 10 dimensions or full array)

### Command: store-embeddings

Get embeddings from OpenAI and store them in the PostgreSQL database.

**Examples:**

```bash
# Store direct text
python aiembedingdemo.py store-embeddings --text "Dog"

# Store from text file
python aiembedingdemo.py store-embeddings --text-file ../samples/cat.txt

# Store from PDF
python aiembedingdemo.py store-embeddings --pdf-file document.pdf

# Custom text label (only with files)
python aiembedingdemo.py store-embeddings --text-file ../samples/cat.txt --text-key "Feline"
python aiembedingdemo.py store-embeddings --pdf-file doc.pdf --text-key "Important Document"
```

**Options:**
- `--text-key TEXT` - Override the text column value (only valid with `--text-file` or `--pdf-file`)

**Behavior:**
- `--text`: Stores the exact text provided
- `--text-file` without `--text-key`: Stores the file content
- `--text-file` with `--text-key`: Stores the custom text key
- `--pdf-file` without `--text-key`: Stores the extracted PDF text
- `--pdf-file` with `--text-key`: Stores the custom text key

**Output:**
- Inserted record details (ID, text, source, metadata, timestamp)

### Command: query-similar

Find texts similar to the query using cosine similarity.

**Examples:**

```bash
# Query with direct text
python aiembedingdemo.py query-similar --text "Puppy"

# Query with text file
python aiembedingdemo.py query-similar --text-file ../samples/dog.txt

# Query with PDF
python aiembedingdemo.py query-similar --pdf-file query.pdf

# Advanced: Export query data for analysis
python aiembedingdemo.py query-similar --text "example" --dump-vector query_vector.json
python aiembedingdemo.py query-similar --pdf-file doc.pdf --dump-query query.sql
python aiembedingdemo.py query-similar --text-file ../samples/dog.txt --dump-vector vec.json --dump-query query.sql
```

**Output:**
- Top 5 most similar results
- ID, text preview, source, similarity score, distance
- Similarity score interpretation guide

**Options:**
- `--dump-vector FILE` - Save query embedding vector to JSON file
- `--dump-query FILE` - Save SQL query to file

Both options are independent and can be used together.

### Output File Formats

When using the dump options, the following file formats are generated:

**Vector JSON Format (`--dump-vector`):**

The JSON file contains:
```json
{
  "model": "text-embedding-3-small",
  "dimensions": 1536,
  "embedding": [/* 1536 float values */],
  "input_text_length": 31,
  "input_text_preview": "first 100 characters..."
}
```

- **File size**: ~40KB (depends on formatting)
- **Use cases**: Inspect embedding values, integrate with external systems, compare vectors across queries
- **Contents**: Full 1536-dimensional embedding vector, model metadata, input text preview

**Query SQL Format (`--dump-query`):**

The SQL file contains two sections:

*Section 1: SQL Template with Parameters*
```sql
-- SQL Template
SELECT id, text, source, ...
FROM text_embeddings
WHERE embedding <=> $1::vector
LIMIT $2;

-- Parameters documented with first 10 dimensions preview
```

*Section 2: Executable SQL*
```sql
-- Ready to run in PostgreSQL with full embedded vector
SELECT id, text, source, ...
FROM text_embeddings
WHERE embedding <=> '[0.123, -0.456, ..., 0.789]'::vector
LIMIT 5;
```

- **File size**: ~102KB (includes full 1536-dimensional vector)
- **Use cases**: Debug SQL issues, share queries with DBAs, document query patterns
- **Contents**: Header with metadata, SQL template with placeholders, executable SQL with embedded vector

## Complete Workflow Example

```bash
# 1. Activate virtual environment (if not already active)
source .venv/bin/activate  # macOS/Linux
# or: .venv\Scripts\Activate.ps1  # Windows PowerShell

# 2. Add some sample embeddings
python aiembedingdemo.py store-embeddings --text "Dog"
python aiembedingdemo.py store-embeddings --text "Cat"
python aiembedingdemo.py store-embeddings --text "Lynx"
python aiembedingdemo.py store-embeddings --text "Duckbill"

# 3. Query for similar texts
python aiembedingdemo.py query-similar --text "Puppy"
# Should return "Dog" as most similar

python aiembedingdemo.py query-similar --text "Kitten"
# Should return "Cat" as most similar

python aiembedingdemo.py query-similar --text "Platypus"
# Should return "Duckbill" as most similar
```

## Database Schema

The tool uses the `text_embeddings` table:

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

**Columns:**
- `id` - Auto-incrementing primary key
- `text` - The text content or custom label
- `source` - Source identifier (e.g., "demo", "file:cat.txt", "pdf:doc.pdf")
- `embedding` - 1536-dimensional vector from OpenAI
- `metadata` - JSONB with additional info (filename, size, etc.)
- `created_at` - Timestamp when record was created

## Dependencies

Defined in `requirements.txt`:

```
openai>=1.0.0           # OpenAI API client
psycopg2-binary>=2.9.0  # PostgreSQL adapter (includes precompiled libs)
python-dotenv>=1.0.0    # Load .env files
pypdf>=3.0.0            # PDF text extraction (pure Python)
```

### Why These Dependencies?

- **openai**: Official OpenAI Python client
- **psycopg2-binary**: PostgreSQL adapter with precompiled binaries (works cross-platform)
- **python-dotenv**: Standard way to load environment variables from `.env` files
- **pypdf**: Pure Python PDF library (no external dependencies, works on Windows)

## Configuration

### Environment Variables

The tool loads configuration from a `.env` file:

```bash
OPENAI_API_KEY=your-key-here
```

The tool looks for `.env` in:
1. Current directory (`python-aiembedings/.env`)
2. Parent directory (`aiembeding/.env`)

### Database Connection

Hardcoded in the script (matches Docker setup):

```python
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "vectoruser",
    "password": "vectorpass",
    "database": "vectordb"
}
```

## Troubleshooting

### "OPENAI_API_KEY environment variable not set"

**Solution:**
1. Create a `.env` file in this directory
2. Add your API key: `OPENAI_API_KEY=your-key-here`
3. Or copy from parent: `cp ../.env .env`

### "Error connecting to database"

**Solution:**
1. Check PostgreSQL is running:
   ```bash
   docker ps | grep postgres-vectordb
   ```
2. Start if needed:
   ```bash
   cd .. && docker compose up -d
   ```
3. Verify table exists:
   ```bash
   cd .. && ./01_setup_demo.sh
   ```

### "Missing required package"

**Solution:**
Install dependencies:
```bash
uv pip install -r requirements.txt
```

Or using pip:
```bash
pip install -r requirements.txt
```

### "File not found" errors

**Solution:**
- Use relative or absolute paths
- Relative paths are from the current directory
- Example: `--text-file ../samples/dog.txt` (parent directory's samples folder)

### PDF extraction fails

**Possible causes:**
1. PDF is image-based (no text layer)
2. PDF is encrypted
3. File is corrupted

**Solution:**
- Ensure PDF has actual text (not just scanned images)
- Use unencrypted PDFs
- Try opening the PDF in a viewer to verify it's valid

### Virtual environment issues (Windows)

**Problem:** Cannot activate virtual environment

**Solution (Windows PowerShell):**
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then activate
.venv\Scripts\Activate.ps1
```

### Import errors after installation

**Solution:**
1. Verify you're in the virtual environment:
   ```bash
   which python  # macOS/Linux
   where python  # Windows
   ```
   Should show path inside `.venv/`

2. Reinstall dependencies:
   ```bash
   uv pip install --force-reinstall -r requirements.txt
   ```

## Comparison with Shell Scripts

| Feature | Shell Scripts | Python CLI |
|---------|--------------|------------|
| Platform | macOS/Linux only | Windows/macOS/Linux |
| PDF extraction | Requires poppler (pdftotext) | Pure Python (pypdf) |
| Database access | Requires psql binary | Pure Python (psycopg2) |
| JSON processing | Requires jq | Built-in json module |
| Text customization | N/A | `--text-key` option |
| Installation | chmod +x | pip/uv install |

## API Cost Information

**OpenAI text-embedding-3-small Pricing:** $0.00002 per 1K tokens

- Single word: ~1 token = $0.00000002
- Sentence (10-20 words): ~10-20 tokens = $0.0000002-$0.0000004
- Paragraph (100 words): ~100 tokens = $0.000002
- Page (500 words): ~500 tokens = $0.00001

For detailed pricing: https://openai.com/pricing

## Development

### Project Structure

```
python-aiembedings/
├── aiembedingdemo.py    # Main CLI tool
├── requirements.txt     # Python dependencies
├── README.md           # This file
├── .env                # Environment variables (gitignored)
└── .venv/              # Virtual environment (gitignored)
```

### Adding New Commands

To add a new command, follow this pattern:

```python
# 1. Add command handler function
def cmd_new_command(args: argparse.Namespace) -> None:
    """New command handler."""
    # Implementation here
    pass

# 2. Add to argparse in main()
parser_new = subparsers.add_parser("new-command", help="Description")
# Add arguments
parser_new.set_defaults(func=cmd_new_command)
```

### Testing

Manual testing checklist:

```bash
# Test all input methods
python aiembedingdemo.py get-embeddings --text "Test"
python aiembedingdemo.py get-embeddings --text-file ../samples/dog.txt
python aiembedingdemo.py get-embeddings --pdf-file test.pdf

# Test store with custom key
python aiembedingdemo.py store-embeddings --text-file ../samples/cat.txt --text-key "Custom"

# Test query
python aiembedingdemo.py query-similar --text "Test query"

# Test full array output
python aiembedingdemo.py get-embeddings --text "Test" --full-array
```

## License

This is educational material for the KMI DBT course at Palacký University.

## Additional Resources

- **OpenAI Embeddings Guide**: https://platform.openai.com/docs/guides/embeddings
- **pgvector Documentation**: https://github.com/pgvector/pgvector
- **uv Documentation**: https://github.com/astral-sh/uv
- **psycopg2 Documentation**: https://www.psycopg.org/docs/
- **pypdf Documentation**: https://pypdf.readthedocs.io/
