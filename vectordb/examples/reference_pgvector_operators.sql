-- pgvector_operators_reference.sql
-- Quick reference guide for pgvector distance operators

-- ============================================
-- DISTANCE OPERATORS
-- ============================================

-- 1. COSINE DISTANCE: <=>
--    Range: 0 (identical) to 2 (opposite)
--    Best for: Normalized embeddings, semantic similarity
--    Example:
SELECT name, embedding <=> '[0.9, 0.8, 0.85, 0.6]' as cosine_distance
FROM fruits
ORDER BY embedding <=> '[0.9, 0.8, 0.85, 0.6]'
LIMIT 3;

-- Convert to similarity (0 to 1, where 1 = identical):
SELECT name, 1 - (embedding <=> '[0.9, 0.8, 0.85, 0.6]') as cosine_similarity
FROM fruits
LIMIT 3;


-- 2. EUCLIDEAN DISTANCE (L2): <->
--    Range: 0 to infinity
--    Best for: Absolute differences, spatial data
--    Example:
SELECT name, embedding <-> '[0.9, 0.8, 0.85, 0.6]' as euclidean_distance
FROM fruits
ORDER BY embedding <-> '[0.9, 0.8, 0.85, 0.6]'
LIMIT 3;


-- 3. INNER PRODUCT: <#>
--    Range: negative infinity to 0
--    Best for: Unnormalized vectors, recommendation systems
--    Example:
SELECT name, embedding <#> '[0.9, 0.8, 0.85, 0.6]' as inner_product
FROM fruits
ORDER BY embedding <#> '[0.9, 0.8, 0.85, 0.6]'
LIMIT 3;


-- ============================================
-- PERFORMANCE: INDEX TYPES
-- ============================================

-- IVFFlat Index (Inverted File with Flat compression)
-- Fast approximate search, good for large datasets
CREATE INDEX fruits_ivfflat_cosine_idx ON fruits 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);

-- HNSW Index (Hierarchical Navigable Small World)
-- Better recall, higher memory usage
-- CREATE INDEX fruits_hnsw_cosine_idx ON fruits 
-- USING hnsw (embedding vector_cosine_ops);


-- ============================================
-- USEFUL FUNCTIONS
-- ============================================

-- Get vector dimensions
SELECT vector_dims(embedding) as dimensions FROM fruits LIMIT 1;

-- Get vector norm (magnitude)
SELECT name, vector_norm(embedding) as magnitude FROM fruits;

-- Calculate distance between two stored vectors
SELECT 
    f1.name as fruit1,
    f2.name as fruit2,
    f1.embedding <=> f2.embedding as distance
FROM fruits f1
CROSS JOIN fruits f2
WHERE f1.name = 'Strawberry' AND f2.name IN ('Cherry', 'Banana', 'Lime')
ORDER BY distance;


-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================

-- Find top N similar items with threshold
SELECT name, embedding <=> '[0.9, 0.8, 0.85, 0.6]' as distance
FROM fruits
WHERE embedding <=> '[0.9, 0.8, 0.85, 0.6]' < 0.5  -- Only items with distance < 0.5
ORDER BY distance
LIMIT 5;

-- Combine vector search with traditional filters
SELECT name, description, embedding <=> '[0.9, 0.8, 0.85, 0.6]' as distance
FROM fruits
WHERE description LIKE '%berry%'
ORDER BY distance
LIMIT 3;

-- Batch similarity search
WITH search_vectors AS (
    SELECT * FROM (VALUES 
        ('search1', '[0.9, 0.8, 0.85, 0.6]'::vector),
        ('search2', '[0.3, 0.7, 0.95, 0.1]'::vector)
    ) AS t(search_name, vec)
)
SELECT 
    sv.search_name,
    f.name,
    f.embedding <=> sv.vec as distance
FROM fruits f
CROSS JOIN search_vectors sv
ORDER BY sv.search_name, distance
LIMIT 10;
