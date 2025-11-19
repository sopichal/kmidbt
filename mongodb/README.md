# MongoDB Environment

MongoDB Docker environment with Mongo Express web client for the KMI DBT course.

## Services

- **MongoDB Server** (mongodb)
  - Port: 27017
  - Root Username: admin
  - Root Password: reptiles
  - Database: kmidbt

- **Mongo Express** (Web Client)
  - Port: 8081
  - Access: http://localhost:8081
  - No authentication required for educational use

## Quick Start

From the `mongodb/` directory:

```bash
# Start services (simple setup)
docker compose up -d

# Start with persistent storage (recommended)
docker compose -f compose-1-node-persistence.yml up -d

# Start 3-node replica set cluster
docker compose -f compose-3-node-cluster-persistence.yml up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Stop and remove volumes
docker compose down -v
```

## Mongo Express Setup

1. Open http://localhost:8081
2. Select the `kmidbt` database from the dropdown
3. Browse collections: `departments`, `employees`, `salaries`, `products`, `customers`, `orders`, `reviews`

## Sample Data

Sample data is automatically loaded when the container starts for the first time through the `init/init-mongo.js` script.

### Included Collections

**HR Dataset:**
- `departments` - Company departments
- `employees` - Employee records with references to departments
- `salaries` - Salary history showing relationships over time

**E-commerce Dataset:**
- `products` - Product catalog with embedded specifications
- `customers` - Customer information with embedded addresses
- `orders` - Order documents with embedded item arrays (see note below)
- `reviews` - Product reviews with customer references (see note below)

### Loading Additional Data

The `orders` and `reviews` collections are available as JSON files but not auto-loaded to keep the initialization fast. To import them:

**Using Docker (from mongodb/ directory):**

Linux/macOS:
```bash
docker run -it --rm --network kmidbt-net -v $(pwd)/data:/data mongo:7.0 mongoimport --uri "mongodb://admin:reptiles@mongodb:27017/kmidbt?authSource=admin" --collection orders --file /data/ecommerce/orders.json --jsonArray

docker run -it --rm --network kmidbt-net -v $(pwd)/data:/data mongo:7.0 mongoimport --uri "mongodb://admin:reptiles@mongodb:27017/kmidbt?authSource=admin" --collection reviews --file /data/ecommerce/reviews.json --jsonArray
```

Windows PowerShell:
```powershell
docker run -it --rm --network kmidbt-net -v ${PWD}/data:/data mongo:7.0 mongoimport --uri "mongodb://admin:reptiles@mongodb:27017/kmidbt?authSource=admin" --collection orders --file /data/ecommerce/orders.json --jsonArray

docker run -it --rm --network kmidbt-net -v ${PWD}/data:/data mongo:7.0 mongoimport --uri "mongodb://admin:reptiles@mongodb:27017/kmidbt?authSource=admin" --collection reviews --file /data/ecommerce/reviews.json --jsonArray
```

## Query Examples

Sample queries are available in the `examples/` directory:
- `hr-queries.js` - 32 HR database queries demonstrating relationships, aggregations, CRUD operations
- `ecommerce-queries.js` - 50 e-commerce queries showing embedded documents, arrays, and complex analytics

### Running Example Queries

**Via Mongo Express:**
1. Open http://localhost:8081
2. Select the `kmidbt` database
3. Click on a collection
4. Use the "Execute" tab to run queries

**Via mongosh (MongoDB Shell):**

```bash
# Connect to MongoDB
docker exec -it mongodb mongosh -u admin -p reptiles --authenticationDatabase admin

# Switch to kmidbt database
use kmidbt

# Run queries from the examples files
# (Copy and paste queries from examples/*.js files)
```

## Compose File Options

### compose.yml
- Single MongoDB node
- No persistent storage (data lost on `docker compose down`)
- Best for: Quick testing, demos

### compose-1-node-persistence.yml
- Single MongoDB node
- Named volume for persistent storage
- Data survives container restarts
- Best for: Development, learning

### compose-3-node-cluster-persistence.yml
- Three MongoDB nodes configured as a replica set
- Each node has independent persistent storage
- Demonstrates high availability and replication
- Automatic replica set initialization via health check
- Best for: Learning replication concepts, production-like setup

**Replica Set Details:**
- Replica Set Name: `rs0`
- Primary election happens automatically
- Nodes: mongodb1 (port 27017), mongodb2 (port 27018), mongodb3 (port 27019)
- Mongo Express connects to all nodes via replica set URL

## Network

All services run on the `kmidbt-net` network for inter-container communication.

## Comparing with MySQL

This MongoDB environment mirrors the MySQL setup structure:
- Similar credentials (`admin:reptiles`) for consistency
- Same HR schema for comparing SQL vs NoSQL approaches
- Same Docker network name (`kmidbt-net`)
- Web-based management tool (Mongo Express vs CloudBeaver)

Key differences:
- MongoDB uses JavaScript for queries (vs SQL)
- Document-oriented (JSON) vs table-oriented (rows/columns)
- Flexible schema vs fixed schema
- Embedded documents/arrays vs foreign keys/joins

## Generating Presentation Slides

The course materials include a complete slide deck in `SLIDES.md` that can be converted to PowerPoint format.

### Prerequisites

Install required tools:
```bash
# Install Pandoc (for markdown to PPTX conversion)
brew install pandoc  # macOS
# or: sudo apt install pandoc  # Linux

# Install Python dependencies (for styling)
pip install python-pptx
```

### Generating Slides

**Step 1: Convert Markdown to PowerPoint**

From the `mongodb/` directory:

```bash
# Generate basic PowerPoint presentation
pandoc SLIDES.md -o mongodb-slides.pptx
```

**Step 2: Apply Professional Styling (Optional)**

Use the included Python styler to apply MongoDB-themed colors and consistent formatting:

```bash
# Apply MongoDB styling
python3 style_mongodb.py mongodb-slides.pptx mongodb-slides-styled.pptx
```

The styler applies:
- MongoDB color scheme (green #00ED64 on dark backgrounds)
- Consistent fonts (Segoe UI)
- Course branding footer
- Slide numbers
- Professional gradients and accent bars

**Using a Template:**

If you have an existing PowerPoint template:

```bash
python style_mongodb.py mongodb-slides.pptx --template "/path/to/template.pptx"
```

### Slide Deck Content

The `SLIDES.md` includes:
1. **Motivation** - Why MongoDB was created
2. **MongoDB Basics & Architecture** - NoSQL concepts, document model, comparisons with SQL
3. **Setup & Docker Environment** - How to use the course Docker setup
4. **CRUD Operations & Queries** - Hands-on examples with sample data
5. **Replication & Clustering** - Replica sets, high availability
6. **Sources & References** - Documentation, disclaimers, additional resources
