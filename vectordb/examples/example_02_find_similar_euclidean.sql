-- example_03.sql
-- Find fruits most similar to Strawberry using Euclidean distance (L2)
-- This demonstrates an alternative distance metric

SELECT 
    name,
    description,
    embedding,
    embedding <-> '[0.9, 0.8, 0.85, 0.6]' as euclidean_distance
FROM fruits
WHERE name != 'Strawberry'
ORDER BY embedding <-> '[0.9, 0.8, 0.85, 0.6]'
LIMIT 5;

-- Comparison: Euclidean vs Cosine
-- Euclidean distance measures absolute distance in vector space
-- Cosine distance measures angular difference (better for normalized embeddings)
