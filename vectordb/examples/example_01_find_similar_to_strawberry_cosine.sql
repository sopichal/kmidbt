-- example_02.sql
-- Find fruits most similar to Strawberry using cosine similarity
-- Strawberry vector: [0.9, 0.8, 0.85, 0.6] (Color, Taste, Sweetness, Sourness)

-- Method 1: Using cosine distance (most common for embeddings)
-- Cosine distance ranges from 0 (identical) to 2 (opposite)
-- Lower distance = more similar
SELECT 
    name,
    description,
    embedding,
    1 - (embedding <=> '[0.9, 0.8, 0.85, 0.6]') as cosine_similarity,
    embedding <=> '[0.9, 0.8, 0.85, 0.6]' as cosine_distance
FROM fruits
WHERE name != 'Strawberry'  -- Exclude strawberry itself
ORDER BY embedding <=> '[0.9, 0.8, 0.85, 0.6]'
LIMIT 5;

-- Expected results: Cherry, Raspberry, Blackberry should be most similar
-- because they share similar color (red/pink), sweetness, and sourness profiles
