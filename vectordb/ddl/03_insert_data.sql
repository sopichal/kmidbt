-- example_01.sql
-- Insert sample fruit data with vector embeddings
-- Vector format: [Color, Taste, Sweetness, Sourness]

-- Red/Pink fruits
INSERT INTO fruits (name, description, embedding) VALUES
('Strawberry', 'Sweet red berry', '[0.9, 0.8, 0.85, 0.6]'),
('Raspberry', 'Tart red berry', '[0.85, 0.75, 0.7, 0.8]'),
('Watermelon', 'Large sweet red fruit', '[0.95, 0.6, 0.9, 0.3]'),
('Cherry', 'Small sweet red fruit', '[0.9, 0.85, 0.8, 0.5]');

-- Yellow/Orange fruits
INSERT INTO fruits (name, description, embedding) VALUES
('Banana', 'Sweet yellow fruit', '[0.3, 0.7, 0.95, 0.1]'),
('Orange', 'Citrus fruit', '[0.5, 0.75, 0.7, 0.7]'),
('Mango', 'Tropical sweet fruit', '[0.4, 0.9, 0.95, 0.2]'),
('Pineapple', 'Tropical tangy fruit', '[0.4, 0.8, 0.8, 0.6]');

-- Green fruits
INSERT INTO fruits (name, description, embedding) VALUES
('Apple (Green)', 'Tart green apple', '[0.2, 0.6, 0.6, 0.9]'),
('Kiwi', 'Fuzzy green fruit', '[0.3, 0.7, 0.7, 0.7]'),
('Lime', 'Sour citrus', '[0.2, 0.5, 0.2, 0.95]'),
('Green Grape', 'Sweet green grape', '[0.25, 0.65, 0.85, 0.4]');

-- Purple/Blue fruits
INSERT INTO fruits (name, description, embedding) VALUES
('Blueberry', 'Small blue berry', '[0.7, 0.7, 0.75, 0.5]'),
('Blackberry', 'Dark berry', '[0.8, 0.75, 0.7, 0.6]'),
('Plum', 'Purple stone fruit', '[0.75, 0.8, 0.8, 0.4]'),
('Purple Grape', 'Sweet purple grape', '[0.7, 0.7, 0.85, 0.3]');

-- Verify insertion
SELECT COUNT(*) as total_fruits FROM fruits;
SELECT name, embedding FROM fruits ORDER BY name;
