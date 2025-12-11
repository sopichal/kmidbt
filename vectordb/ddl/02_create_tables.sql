-- 02_create_tables.sql
-- Create a table to store fruit embeddings
-- Each fruit has a 4-dimensional vector representing: [Color, Taste, Sweetness, Sourness]

CREATE TABLE fruits (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    embedding vector(4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create an index for faster similarity search using cosine distance
-- This dramatically improves query performance for vector similarity searches
CREATE INDEX ON fruits USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Alternative: You can also create index for L2 distance (Euclidean)
-- CREATE INDEX ON fruits USING ivfflat (embedding vector_l2_ops) WITH (lists = 100);

COMMENT ON TABLE fruits IS 'Stores fruits with their vector embeddings for similarity search';
COMMENT ON COLUMN fruits.embedding IS '4D vector: [Color, Taste, Sweetness, Sourness]';
