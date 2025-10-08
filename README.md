# kmidbt

MySQL Docker environment with CloudBeaver web client.

## Services

- **MySQL Server** (mysqlsrv01)
  - Port: 3306
  - Root Password: reptiles
  - Data Directory: `./datadir`

- **CloudBeaver** (Web Client)
  - Port: 9978
  - Access: http://localhost:9978
  - Data Directory: `./cloudbeaver-data`

## Quick Start

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Stop and remove volumes
docker compose down -v
```

## CloudBeaver Setup

1. Open http://localhost:9978
2. Create admin credentials on first launch
3. Add MySQL connection:
   - **Host**: `mysqlsrv01`
   - **Port**: `3306`
   - **User**: `root`
   - **Password**: `reptiles`

## Network

All services run on the `kmidbt-net` network for inter-container communication.
