-- example_04.sql
-- Find sweet fruits (high sweetness dimension)
-- This demonstrates filtering by specific vector dimensions

-- pgvector doesn't support direct array indexing on vector type
-- So we'll use a different approach: calculate similarity to a "pure sweetness" vector

-- Method 1: Using a sweetness-focused vector [0, 0, 1, 0] to find sweet fruits
SELECT 
    name,
    description,
    embedding,
    1 - (embedding <=> '[0, 0, 1, 0]') as sweetness_affinity
FROM fruits
ORDER BY embedding <=> '[0, 0, 1, 0]'
LIMIT 10;

-- Method 2: Cast to text and parse (less efficient but works for demonstration)
-- This extracts the actual sweetness value
SELECT 
    name,
    description,
    embedding,
    CAST(split_part(split_part(embedding::text, ',', 3), ',', 1) AS FLOAT) as sweetness_score
FROM fruits
WHERE CAST(split_part(split_part(embedding::text, ',', 3), ',', 1) AS FLOAT) >= 0.8
ORDER BY CAST(split_part(split_part(embedding::text, ',', 3), ',', 1) AS FLOAT) DESC;
