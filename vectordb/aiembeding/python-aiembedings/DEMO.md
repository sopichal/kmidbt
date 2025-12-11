# AI Embedding Demo - Complete Workflow

This document demonstrates the full workflow of loading academic and scientific PDF documents into a vector database and performing semantic similarity searches.

## Overview

This demo showcases:
1. **Loading 16 academic PDFs** from various fields (biology, legal, math, medicine, physics) into the vector database
2. **Querying with 3 test documents** (all medicine-related) to find semantically similar content
3. **Understanding similarity scores** and how vector embeddings capture semantic meaning
4. **Automatic chunking** for large PDFs that exceed the 8192 token limit

**Expected Outcome:** Medicine-related queries should return medicine documents with high similarity scores, demonstrating that embeddings capture domain-specific semantic content.

## Prerequisites

1. Virtual environment activated:
   ```bash
   source .venv/bin/activate  # macOS/Linux
   # or: .venv\Scripts\Activate.ps1  # Windows PowerShell
   ```

2. Dependencies installed:
   ```bash
   uv pip install -r requirements.txt
   ```

3. `.env` file with OpenAI API key:
   ```bash
   cp ../.env .env  # or create manually
   ```

4. PostgreSQL running:
   ```bash
   docker ps | grep postgres-vectordb
   ```

5. Database table created:
   ```bash
   cd .. && ./01_setup_demo.sh
   ```

## Step 1: Clear Existing Demo Data (Optional)

If you want to start fresh, clear the database:

```bash
# Connect to database and truncate table
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "TRUNCATE text_embeddings RESTART IDENTITY;"
```

## Step 2: Load Documents into Vector Database

**Note:** The system automatically checks for duplicate sources before storing. You have several options:
- **Interactive mode** (default): Prompts you to skip, replace, or allow duplicates
- **`--skip-if-exists`**: Automatically skip if source already exists
- **`--replace-if-exists`**: Automatically delete existing and store new
- **`--force`**: Store anyway (creates duplicates)

For batch operations, we recommend using `--skip-if-exists`:
```bash
python aiembedingdemo.py store-embeddings --pdf-file FILE.pdf --skip-if-exists
```

### Biology Documents (3 PDFs)

Classic evolutionary biology, genetics, and ecology research:

```bash
# ArXiv Genetics paper
python aiembedingdemo.py store-embeddings --pdf-file ../samples/biology/ArXiv_Genetics.pdf

# Darwin's Origin of Species (1859) - Foundational evolutionary biology text
python aiembedingdemo.py store-embeddings --pdf-file ../samples/biology/Darwin_Origin_of_Species.pdf

# Hunting Dogs and Tick Exposure - Ecology research
python aiembedingdemo.py store-embeddings --pdf-file ../samples/biology/Many_Hunting_Dogs_Significantly_Increases_Tick_Exposure.pdf
```

### Legal Documents (3 PDFs)

Foundational American and international legal documents:

```bash
# Declaration of Independence - Foundational American document
python aiembedingdemo.py store-embeddings --pdf-file ../samples/legal/Declaration_of_Independence.pdf

# Universal Declaration of Human Rights - International law
python aiembedingdemo.py store-embeddings --pdf-file ../samples/legal/Universal_Declaration_Human_Rights.pdf

# US Constitution - Constitutional law
python aiembedingdemo.py store-embeddings --pdf-file ../samples/legal/US_Constitution_COMPS-748.pdf
```

### Mathematics Documents (4 PDFs)

Advanced mathematics including topology, number theory, and discrete mathematics:

```bash
# ArXiv Mathematics paper on Khovanov Homology
python aiembedingdemo.py store-embeddings --pdf-file ../samples/math/ArXiv_Math_Khovanov_Homology.pdf

# Discrete Torsion on Supersingular surfaces
python aiembedingdemo.py store-embeddings --pdf-file ../samples/math/discrete_torsion_on_supersingular.pdf

# Real Numbers - Mathematical foundations
python aiembedingdemo.py store-embeddings --pdf-file ../samples/math/math_real_numbers.pdf

# Mono Trace Functions
python aiembedingdemo.py store-embeddings --pdf-file ../samples/math/mono_trace_fucntions.pdf
```

### Medicine Documents (4 PDFs)

Medical research covering infectious disease, neuroscience, and public health:

```bash
# BioMed Central research article
python aiembedingdemo.py store-embeddings --pdf-file ../samples/medicine/BioMed_Central_Article.pdf

# COVID-19 research article from PMC
python aiembedingdemo.py store-embeddings --pdf-file ../samples/medicine/PMC_COVID19_7092819.pdf

# Neuroscience research on forced abstinence
python aiembedingdemo.py store-embeddings --pdf-file "../samples/medicine/PMC_Neuroscience_forc ed_abstinence.pdf"

# Public Health research on walkability
python aiembedingdemo.py store-embeddings --pdf-file ../samples/medicine/PMC_Public_Health_Walkability.pdf
```

**Note:** The neuroscience PDF filename contains a space, so it's wrapped in quotes.

### Physics Documents (2 PDFs)

Modern AI/ML and classical physics:

```bash
# "Attention Is All You Need" - Transformer architecture paper
python aiembedingdemo.py store-embeddings --pdf-file ../samples/physics/ArXiv_Attention_Is_All_You_Need.pdf

# Einstein's Theory of Relativity
python aiembedingdemo.py store-embeddings --pdf-file ../samples/physics/Einstein_Relativity.pdf
```

**Total: 16 documents loaded** (3 biology + 3 legal + 4 math + 4 medicine + 2 physics)

### About Automatic Chunking

Some PDFs may be large enough to exceed OpenAI's 8192 token limit. The system automatically:
- Detects when a document exceeds ~5000 tokens (conservative limit for documents with special characters)
- Splits the text into chunks at paragraph boundaries (or sentences/characters if needed)
- Stores each chunk separately with metadata (chunk_index, total_chunks)
- All chunks remain searchable and will appear in similarity queries

**Note:** Mathematical papers and documents with special characters, formulas, or LaTeX notation require more conservative chunking because they tokenize less efficiently than plain English text.

For example, Darwin's "Origin of Species" (1MB) is split into 47 chunks, while a mathematical paper might be split into more chunks per page. When you query the database, you might see multiple chunks from the same document in the results.

### Progress Check

Verify documents were loaded:

```bash
# Count stored documents
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT COUNT(*) as total_documents, COUNT(DISTINCT source) as unique_sources FROM text_embeddings;"

# View document sources
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT id, LEFT(text, 50) as preview, source FROM text_embeddings ORDER BY id;"
```

## Step 3: Query Similar Documents

Now test the vector database with medicine-related query documents. **Expected result:** These queries should return the medicine documents we stored, not biology, legal, math, or physics documents.

**Note:** Large query PDFs that exceed the token limit are automatically truncated to use only the first ~5000 tokens (~10,000 characters). This is usually sufficient since the beginning of academic papers (abstract, introduction) typically contains the most representative content.

### Query 1: Effects of Ketamine

```bash
python aiembedingdemo.py query-similar --pdf-file ../samples/query_samples/Query_affect_of_Ketamine.pdf
```

**Expected top results:**
- Neuroscience research (forced abstinence study)
- Other medical/pharmacology articles
- High similarity scores (> 0.6)

### Query 2: Breast Cancer Risk

```bash
python aiembedingdemo.py query-similar --pdf-file ../samples/query_samples/Query_breast_cancer_risk.pdf
```

**Expected top results:**
- Medical research articles (BioMed Central, PMC articles)
- Cancer-related or women's health content

### Query 3: Intervertebral Disc Degeneration

```bash
python aiembedingdemo.py query-similar --pdf-file ../samples/query_samples/Query_Intervertebral_Disc_Degeneration.pdf
```

**Expected top results:**
- Medical research articles
- Health-related documents (public health, medical studies)

### Optional: Extract Query Data for Analysis

If you need to inspect the embedding vectors or SQL queries for debugging or analysis, you can export them:

```bash
# Extract vector and query data from any query
python aiembedingdemo.py query-similar --pdf-file ../samples/query_samples/Query_breast_cancer_risk.pdf --dump-vector breast_cancer_vec.json --dump-query breast_cancer_query.sql

# Or use with text queries
python aiembedingdemo.py query-similar --text "medical research cardiovascular" --dump-vector cardio_vec.json --dump-query cardio_query.sql
```

These files will contain:
- **Vector JSON**: Full 1536-dimensional embedding, model metadata, input text preview
- **Query SQL**: Both template and executable SQL formats with complete vector data

## Step 4: Understanding Results

### Similarity Score Interpretation

The cosine similarity score ranges from 0 to 1:

- **0.9 - 1.0**: Nearly identical content (same document or very similar)
- **0.8 - 0.9**: Very similar (same domain, similar concepts)
- **0.7 - 0.8**: Similar (related topics within same field)
- **0.6 - 0.7**: Somewhat similar (overlapping concepts)
- **< 0.6**: Less similar (different domains or topics)

### Why Medicine Queries Match Medicine Documents

Vector embeddings capture semantic meaning, not just keywords:

1. **Domain-specific terminology**: Medical terms create distinct embedding patterns
2. **Conceptual relationships**: Understanding of anatomy, disease, treatment concepts
3. **Writing style**: Academic medical writing has characteristic patterns
4. **Context understanding**: Embeddings capture relationships between concepts

### Example Analysis

If a medical query (e.g., breast cancer risk) returns:
1. **BioMed_Central_Article.pdf** (0.78) - Medical research article
2. **PMC_COVID19_7092819.pdf** (0.72) - Related medical/epidemiological research
3. **PMC_Public_Health_Walkability.pdf** (0.68) - Public health research context
4. **Darwin_Origin_of_Species.pdf** (0.52) - Lower score, different domain (biology)
5. **US_Constitution** (0.45) - Very different domain (legal)

This demonstrates that embeddings successfully distinguish between medical and non-medical content.

## Step 5: Additional Experiments

### Cross-Domain Queries

Try querying with a document from a different domain to see lower similarity scores:

```bash
# Query with a physics document (should return physics documents)
python aiembedingdemo.py query-similar --pdf-file ../samples/physics/Einstein_Relativity.pdf

# Query with a legal document (should return legal documents)
python aiembedingdemo.py query-similar --pdf-file ../samples/legal/US_Constitution_COMPS-748.pdf
```

### Custom Text Queries

Query with direct text to find related documents:

```bash
# Find medical documents
python aiembedingdemo.py query-similar --text "cardiovascular disease treatment and diagnosis"

# Find physics documents
python aiembedingdemo.py query-similar --text "theory of relativity and spacetime curvature"

# Find legal documents
python aiembedingdemo.py query-similar --text "constitutional rights and legal precedent"
```

### Using Custom Labels

Store documents with custom labels for better organization:

```bash
# Store with descriptive labels
python aiembedingdemo.py store-embeddings --pdf-file ../samples/medicine/BioMed_Central_Article.pdf --text-key "Medical Research Article"

python aiembedingdemo.py store-embeddings --pdf-file ../samples/physics/ArXiv_Attention_Is_All_You_Need.pdf --text-key "Transformer Neural Network Architecture"
```

## Step 6: Analyze Results by Category

### View Documents by Source Pattern

```bash
# Medicine documents
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT id, LEFT(text, 60) as preview, source FROM text_embeddings WHERE source LIKE '%medicine%' ORDER BY id;"

# Physics documents
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT id, LEFT(text, 60) as preview, source FROM text_embeddings WHERE source LIKE '%physics%' ORDER BY id;"

# Legal documents
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT id, LEFT(text, 60) as preview, source FROM text_embeddings WHERE source LIKE '%legal%' ORDER BY id;"
```

### Statistics

```bash
# Get embedding statistics
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "
SELECT
    COUNT(*) as total_embeddings,
    COUNT(DISTINCT source) as unique_sources,
    AVG(LENGTH(text)) as avg_text_length,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created
FROM text_embeddings;
"
```

## Troubleshooting

### PDF Extraction Issues

If a PDF fails to load:
- **Check if it's image-based**: Some scanned PDFs don't have text layers
- **Try another PDF tool**: pypdf works for most PDFs but not all
- **Check file integrity**: Verify the PDF opens correctly in a viewer

### Low Similarity Scores

If all results have low similarity (< 0.6):
- **Check query content**: Make sure it's relevant to stored documents
- **Add more documents**: Small databases may not have good matches
- **Try different queries**: Some topics may not be well-represented

### Large PDF Handling

The system automatically handles large PDFs:
- **Storing large PDFs**: Automatically chunked into ~5000 token segments (~10,000 chars) at paragraph boundaries
- **Querying with large PDFs**: Automatically truncated to use first ~5000 tokens (~10,000 chars)
- **Token limit**: OpenAI's text-embedding-3-small model has an 8192 token limit
- **Conservative estimation**: Uses 2 characters per token (safer for math/special characters vs. 4 for plain text)
- **No manual intervention needed**: All token limit handling is automatic

### Memory Issues

For very large PDFs:
- **Monitor memory usage**: PDF extraction can use significant memory
- **Process in batches**: Don't load all 16 PDFs at once if memory-constrained

### Extracting Vector and Query Data for Analysis

The `--dump-vector` and `--dump-query` flags allow you to export query data for debugging and analysis.

**When to use:**
- **--dump-vector**: Inspect embedding values, integrate with external systems, compare vectors across different queries
- **--dump-query**: Debug SQL issues, share queries with DBAs, document query patterns for research or troubleshooting

**Examples:**

```bash
# Extract vector for analysis
python aiembedingdemo.py query-similar --text "medical research" --dump-vector medical_vec.json

# Extract SQL query for database team
python aiembedingdemo.py query-similar --pdf-file ../samples/query_samples/Query_breast_cancer_risk.pdf --dump-query query_debug.sql

# Extract both for comprehensive debugging
python aiembedingdemo.py query-similar --text-file sample.txt --dump-vector vec.json --dump-query query.sql
```

**Vector JSON contents:**
- Full 1536-dimensional embedding array
- Model name (text-embedding-3-small) and metadata
- Input text length and preview (first 100 characters)
- File size: ~40KB

**Query SQL contents:**
- Header with generation timestamp, input method, vector dimensions, result limit
- Section 1: SQL template with parameter placeholders ($1, $2, $3, $4)
- Section 2: Executable SQL with full embedded vector (ready to run in PostgreSQL)
- File size: ~102KB (includes full vector)

**Use cases:**
- Debugging similarity search behavior
- Comparing embedding vectors across different inputs
- Sharing SQL queries with database administrators
- Documenting query patterns for academic research
- Integrating vectors with external analysis tools

## Expected Demo Outcomes

After completing this demo, you should observe:

1. **Domain clustering**: Queries from one domain return documents from the same domain
2. **Semantic understanding**: Results are based on meaning, not just keywords
3. **Consistent scoring**: Similar documents consistently score above 0.7
4. **Clear separation**: Documents from different domains score below 0.6

## Cost Information

**OpenAI API Cost** for this demo:

Assuming average document length of 10,000 words (~13,000 tokens):
- 16 stored documents: 16 × 13,000 = 208,000 tokens
- 3 queries: 3 × 13,000 = 39,000 tokens
- **Total**: ~247,000 tokens

**Cost**: 247,000 tokens × $0.00002 per 1K tokens = **$0.00494** (~$0.005)

Very affordable for this comprehensive demo!

**Note:** Large PDFs that exceed the token limit are automatically chunked, which may result in multiple API calls per document. The system uses conservative chunking (~5000 tokens per chunk) to safely handle documents with mathematical notation and special characters. The chunking system splits documents at paragraph boundaries when possible to maintain semantic coherence.

## Next Steps

1. **Add your own PDFs**: Try with documents from your domain
2. **Experiment with chunking**: Split large PDFs into pages or sections
3. **Build applications**: Use this as a foundation for semantic search, RAG, or recommendation systems
4. **Optimize queries**: Try different query formulations to improve results
5. **Scale up**: Add hundreds or thousands of documents to build a real knowledge base

## Clean Up

To remove all demo data:

```bash
# Clear the database
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "TRUNCATE text_embeddings RESTART IDENTITY;"

# Verify
docker exec -i postgres-vectordb psql -U vectoruser -d vectordb -c "SELECT COUNT(*) FROM text_embeddings;"
```

## Summary

This demo demonstrated:
- ✅ Loading 16 academic PDFs across 5 domains (biology, legal, math, medicine, physics)
- ✅ Automatic chunking of large PDFs that exceed token limits
- ✅ Creating 1536-dimensional embeddings for each document/chunk
- ✅ Storing embeddings in PostgreSQL with pgvector
- ✅ Querying with medicine documents and finding medicine matches
- ✅ Understanding cosine similarity scores
- ✅ Distinguishing between different academic domains

**Key Insight:** Vector embeddings successfully capture domain-specific semantic meaning, enabling accurate similarity search without explicit keyword matching or domain classification. The automatic chunking system handles documents of any size (including large books and mathematical papers with special notation) while maintaining semantic coherence through intelligent paragraph/sentence boundary detection.
