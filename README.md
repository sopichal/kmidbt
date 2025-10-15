# kmidbt

Docker environments for multiple database systems used in the KMI DBT course at Palacký University, Department of Computer Science.

## Available Databases

### [MySQL](mysql/)
MySQL 8.1.0 with CloudBeaver web client
- **Port:** 3306
- **Web UI:** http://localhost:9978
- **Documentation:** [mysql/README.md](mysql/README.md)

### MongoDB (Coming Soon)
MongoDB environment with web client
- **Documentation:** [mongo/README.md](mongo/README.md)

## Quick Start

Navigate to the specific database directory and follow its README:

```bash
# MySQL
cd mysql/
docker compose up -d

# MongoDB (when available)
cd mongo/
docker compose up -d
```

## Repository Structure

```
.
├── mysql/              MySQL environment
│   ├── compose.yml
│   ├── ddl/
│   └── README.md
├── mongo/              MongoDB environment (future)
└── README.md           This file
```
