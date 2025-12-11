-- example_05.sql
-- Advanced query: Find fruits similar to a "custom profile"
-- Let's search for a fruit that is: moderately red, very tasty, sweet, and slightly sour
-- Custom vector: [0.6, 0.9, 0.85, 0.5]

WITH custom_fruit AS (
    SELECT '[0.6, 0.9, 0.85, 0.5]'::vector as search_vector
)
SELECT 
    f.name,
    f.description,
    f.embedding,
    1 - (f.embedding <=> cf.search_vector) as similarity_score,
    f.embedding <=> cf.search_vector as distance
FROM fruits f, custom_fruit cf
ORDER BY f.embedding <=> cf.search_vector
LIMIT 5;

-- This demonstrates searching for fruits matching a hypothetical flavor profile
