-- 01_create_extension.sql
-- Enable pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify the extension is installed
SELECT * FROM pg_extension WHERE extname = 'vector';
