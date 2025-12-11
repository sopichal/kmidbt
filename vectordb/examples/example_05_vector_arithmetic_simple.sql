-- example_06.sql
-- Demonstrate vector arithmetic: Find fruits that combine characteristics
-- Example: What if we want something between a Strawberry and a Banana?

-- Simpler approach: Manually calculate the average of Strawberry and Banana vectors
-- Strawberry: [0.9, 0.8, 0.85, 0.6]
-- Banana:     [0.3, 0.7, 0.95, 0.1]
-- Average:    [0.6, 0.75, 0.9, 0.35]

WITH search_vector AS (
    SELECT '[0.6, 0.75, 0.9, 0.35]'::vector as vec
)
SELECT 
    f.name,
    f.description,
    f.embedding,
    1 - (f.embedding <=> sv.vec) as similarity_score,
    f.embedding <=> sv.vec as distance
FROM fruits f, search_vector sv
WHERE f.name NOT IN ('Strawberry', 'Banana')
ORDER BY f.embedding <=> sv.vec
LIMIT 5;

-- This finds fruits that blend characteristics of both Strawberry and Banana:
-- - Moderate color (0.6): between pink/red and yellow
-- - Good taste (0.75): balanced flavor
-- - Very sweet (0.9): high sweetness from both
-- - Low sourness (0.35): minimal tartness

-- Expected results: Mango, Purple Grape, or other sweet fruits with moderate color
