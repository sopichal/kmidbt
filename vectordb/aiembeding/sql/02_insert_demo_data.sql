-- 02_insert_demo_data.sql
-- Template for inserting embeddings into text_embeddings table
-- This file demonstrates the INSERT syntax but should be populated with actual embeddings
-- from the OpenAI API using the shell scripts

-- Example INSERT statement (with placeholder vector):
-- INSERT INTO text_embeddings (text, source, embedding, metadata)
-- VALUES (
--     'Dog',
--     'demo',
--     '[0.001, 0.002, ..., 0.1536]'::vector(1536),
--     '{"type": "demo", "category": "animal"}'::jsonb
-- );

-- The actual insertion will be done by the 03_store_embeddings.sh script
-- which fetches real embeddings from OpenAI API

-- Example with text file source:
-- INSERT INTO text_embeddings (text, source, embedding, metadata)
-- VALUES (
--     'Content from file...',
--     'file:sample.txt',
--     '[...]'::vector(1536),
--     '{"filename": "sample.txt", "size_bytes": 1234}'::jsonb
-- );

-- Example with PDF source:
-- INSERT INTO text_embeddings (text, source, embedding, metadata)
-- VALUES (
--     'Content from PDF page...',
--     'pdf:document.pdf',
--     '[...]'::vector(1536),
--     '{"pdf_filename": "document.pdf", "page_number": 1, "chunk_index": 0}'::jsonb
-- );

-- Check for existing records
SELECT COUNT(*) as total_embeddings FROM text_embeddings;
