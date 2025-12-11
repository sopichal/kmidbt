#!/bin/bash
# Quick start script for the vector database project

echo "🚀 Starting Vector Database Project..."
echo ""

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📦 Creating network if it doesn't exist..."
docker network create kmidbt-net 2>/dev/null || echo "   Network already exists"

echo ""
echo "🐘 Starting PostgreSQL with pgvector and CloudBeaver..."
docker compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "✅ Services started!"
echo ""
echo "📊 Access CloudBeaver at: http://localhost:9979"
echo ""
echo "🔐 Database Connection Details:"
echo "   Host: postgres-vectordb"
echo "   Port: 5432"
echo "   Database: vectordb"
echo "   User: vectoruser"
echo "   Password: vectorpass"
echo ""
echo "📖 Check README.md for example queries and usage instructions"
echo ""
echo "🛠️  Useful commands:"
echo "   View logs:    docker compose logs -f"
echo "   Stop:         docker compose down"
echo "   Restart:      docker compose restart"
echo ""
