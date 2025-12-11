-- query_example_06_vector_arithmetic_advanced.sql
-- Advanced: Vector arithmetic using PostgreSQL array functions
-- This example shows how to properly manipulate vectors programmatically
-- Note: Run this manually in CloudBeaver after the database is initialized

-- First, let's create a helper function to average two vectors
CREATE OR REPLACE FUNCTION avg_two_vectors(v1 vector, v2 vector)
RETURNS vector AS $$
DECLARE
    result_array float[];
    v1_array float[];
    v2_array float[];
    result_string text;
BEGIN
    -- Convert vectors to arrays by parsing the text representation
    v1_array := string_to_array(trim(both '[]' from v1::text), ',')::float[];
    v2_array := string_to_array(trim(both '[]' from v2::text), ',')::float[];
    
    -- Calculate average for each dimension
    result_array := ARRAY[
        (v1_array[1] + v2_array[1]) / 2.0,
        (v1_array[2] + v2_array[2]) / 2.0,
        (v1_array[3] + v2_array[3]) / 2.0,
        (v1_array[4] + v2_array[4]) / 2.0
    ];
    
    -- Convert back to vector type (must include brackets!)
    result_string := '[' || array_to_string(result_array, ',') || ']';
    RETURN result_string::vector;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT 
    'Test: Strawberry+Banana Blend' as description,
    avg_two_vectors(
        '[0.9, 0.8, 0.85, 0.6]'::vector,
        '[0.3, 0.7, 0.95, 0.1]'::vector
    ) as blended_vector;

-- Now use the function to find fruits similar to the average of Strawberry and Banana
WITH vector_blend AS (
    SELECT avg_two_vectors(
        (SELECT embedding FROM fruits WHERE name = 'Strawberry'),
        (SELECT embedding FROM fruits WHERE name = 'Banana')
    ) as blended_vec
)
SELECT 
    f.name,
    f.description,
    f.embedding,
    vb.blended_vec as search_vector,
    1 - (f.embedding <=> vb.blended_vec) as similarity_score
FROM fruits f, vector_blend vb
WHERE f.name NOT IN ('Strawberry', 'Banana')
ORDER BY f.embedding <=> vb.blended_vec
LIMIT 5;

-- Bonus: Show the actual blended vector
SELECT 
    'Strawberry+Banana Blend' as name,
    avg_two_vectors(
        (SELECT embedding FROM fruits WHERE name = 'Strawberry'),
        (SELECT embedding FROM fruits WHERE name = 'Banana')
    ) as blended_vector;

-- You can also blend other fruits!
SELECT 
    'Cherry+Lime Blend' as name,
    avg_two_vectors(
        (SELECT embedding FROM fruits WHERE name = 'Cherry'),
        (SELECT embedding FROM fruits WHERE name = 'Lime')
    ) as blended_vector;
