#!/bin/bash
# Cleanup and restart script

echo "🧹 Cleaning up existing containers and data..."

cd /Users/sopichal/projects/kmidbt/git/repo/kmidbt/vectordb

# Stop and remove containers
docker compose down

# Remove data directories
echo "Removing data directories..."
rm -rf datadir/
rm -rf cloudbeaver-data/

echo "✅ Cleanup complete!"
echo ""
echo "🚀 Starting fresh..."
docker compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "✅ Services restarted!"
echo "📊 CloudBeaver: http://localhost:9979"
echo ""
