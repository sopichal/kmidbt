# kmidbt

Docker environments for multiple database systems used in the KMI DBT course at Palacký University, Department of Computer Science.

## Available Databases

### [MySQL](mysql/)
MySQL 8.1.0 with CloudBeaver web client
- **Port:** 3306
- **Web UI:** http://localhost:9978
- **Documentation:** [mysql/README.md](mysql/README.md)

### [Vector Database (pgvector)](vectordb/)
PostgreSQL 16 with pgvector extension for vector similarity search
- **Port:** 5432
- **Web UI:** http://localhost:9979
- **Use Case:** AI embeddings, similarity search, vector operations
- **Documentation:** [vectordb/README.md](vectordb/README.md)
- **Features:**
  - 4D vector embeddings demo with fruit similarity
  - Cosine, Euclidean, and Inner Product distance metrics
  - 16 sample vectors with example queries
  - Command-line and GUI access

### [MongoDB](mongodb/)
MongoDB environment with web client
- **Documentation:** [mongodb/README.md](mongodb/README.md)

## Quick Start

Navigate to the specific database directory and follow its README:

```bash
# MySQL
cd mysql/
docker compose up -d

# Vector Database (pgvector)
cd vectordb/
./start.sh
# or: docker compose up -d

# MongoDB
cd mongodb/
docker compose up -d
```

## Repository Structure

```
.
├── mysql/              MySQL 8.1.0 environment
│   ├── compose.yml
│   ├── ddl/
│   └── README.md
├── vectordb/           PostgreSQL + pgvector
│   ├── compose.yaml
│   ├── ddl/            Auto-run initialization scripts
│   ├── examples/       Manual example queries
│   ├── start.sh
│   └── README.md
├── mongodb/            MongoDB environment
└── README.md           This file
```

## Network

All database services use the `kmidbt-net` Docker network for inter-container communication.

## Learning Resources

Each database directory contains:
- Complete setup instructions
- Example queries and data
- Usage documentation
- Troubleshooting guides

Start with the README in each directory for detailed information.
