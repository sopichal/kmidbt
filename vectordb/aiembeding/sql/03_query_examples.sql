-- 03_query_examples.sql
-- Example queries for similarity search using cosine distance
-- These examples demonstrate how to find similar texts in the database

-- ============================================================================
-- Example 1: Find texts similar to a given embedding vector
-- ============================================================================
-- Replace [...] with actual 1536-dimensional vector from OpenAI API
-- The <=> operator computes cosine distance (0 = identical, 2 = opposite)
-- Lower distance = more similar

-- SELECT
--     id,
--     text,
--     source,
--     metadata,
--     1 - (embedding <=> '[...]'::vector(1536)) as cosine_similarity,
--     embedding <=> '[...]'::vector(1536) as cosine_distance,
--     created_at
-- FROM text_embeddings
-- ORDER BY embedding <=> '[...]'::vector(1536)
-- LIMIT 5;

-- ============================================================================
-- Example 2: Find similar texts with a specific source filter
-- ============================================================================
-- Useful for searching within PDFs or specific file types

-- SELECT
--     id,
--     LEFT(text, 100) as text_preview,  -- First 100 characters
--     source,
--     1 - (embedding <=> '[...]'::vector(1536)) as similarity_score
-- FROM text_embeddings
-- WHERE source LIKE 'pdf:%'  -- Only search in PDF sources
-- ORDER BY embedding <=> '[...]'::vector(1536)
-- LIMIT 10;

-- ============================================================================
-- Example 3: Find similar texts with metadata filtering
-- ============================================================================
-- Use JSONB operators to filter by metadata

-- SELECT
--     id,
--     text,
--     source,
--     metadata->>'pdf_filename' as pdf_file,
--     metadata->>'page_number' as page,
--     1 - (embedding <=> '[...]'::vector(1536)) as similarity
-- FROM text_embeddings
-- WHERE metadata->>'pdf_filename' = 'document.pdf'
-- ORDER BY embedding <=> '[...]'::vector(1536)
-- LIMIT 5;

-- ============================================================================
-- Example 4: Get distance metrics for all stored embeddings
-- ============================================================================
-- Compare against a query embedding using different distance metrics

-- SELECT
--     id,
--     text,
--     source,
--     -- Cosine distance (most common for text embeddings)
--     embedding <=> '[...]'::vector(1536) as cosine_distance,
--     -- L2 distance (Euclidean)
--     embedding <-> '[...]'::vector(1536) as l2_distance,
--     -- Inner product (negative distance)
--     (embedding <#> '[...]'::vector(1536)) * -1 as inner_product
-- FROM text_embeddings
-- ORDER BY embedding <=> '[...]'::vector(1536)
-- LIMIT 10;

-- ============================================================================
-- Example 5: View all stored embeddings (without filtering)
-- ============================================================================
-- Useful for debugging and understanding what's in the database

SELECT
    id,
    LEFT(text, 50) as text_preview,
    source,
    metadata,
    created_at,
    -- Show first 5 dimensions of the embedding vector
    (embedding::text::jsonb)->0 as dim_0,
    (embedding::text::jsonb)->1 as dim_1,
    (embedding::text::jsonb)->2 as dim_2,
    (embedding::text::jsonb)->3 as dim_3,
    (embedding::text::jsonb)->4 as dim_4
FROM text_embeddings
ORDER BY created_at DESC;

-- ============================================================================
-- Example 6: Statistics about stored embeddings
-- ============================================================================

SELECT
    COUNT(*) as total_embeddings,
    COUNT(DISTINCT source) as unique_sources,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created,
    AVG(LENGTH(text)) as avg_text_length,
    MAX(LENGTH(text)) as max_text_length
FROM text_embeddings;
