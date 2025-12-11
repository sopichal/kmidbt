-- 01_create_table.sql
-- Create text_embeddings table for storing OpenAI embeddings
-- Model: text-embedding-3-small (1536 dimensions)

CREATE TABLE IF NOT EXISTS text_embeddings (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    source VARCHAR(255) DEFAULT 'demo',
    embedding vector(1536) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for fast similarity search using cosine distance
-- This dramatically improves query performance for vector similarity searches
CREATE INDEX IF NOT EXISTS text_embeddings_embedding_idx
ON text_embeddings
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Add comments for documentation
COMMENT ON TABLE text_embeddings IS 'Stores text with OpenAI embeddings (text-embedding-3-small, 1536 dimensions)';
COMMENT ON COLUMN text_embeddings.text IS 'Original text content that was embedded';
COMMENT ON COLUMN text_embeddings.source IS 'Source identifier: "demo", "file:filename.txt", "pdf:filename.pdf"';
COMMENT ON COLUMN text_embeddings.embedding IS '1536-dimensional vector from OpenAI text-embedding-3-small model';
COMMENT ON COLUMN text_embeddings.metadata IS 'Flexible JSON metadata for PDF info (filename, page_number, chunk_index, etc.)';

-- Verify table creation
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'text_embeddings'
ORDER BY ordinal_position;
