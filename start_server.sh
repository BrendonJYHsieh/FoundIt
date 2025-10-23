#!/bin/bash

# FoundIt Server Startup Script
echo "🔍 Starting FoundIt server..."
echo "=============================="

# Check if server is already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Server is already running on port 3000"
    echo "   Visit: http://localhost:3000"
    echo "   To stop: kill \$(lsof -t -i:3000)"
    exit 1
fi

# Start the server
echo "🚀 Starting Rails server on port 3000..."
echo "   Visit: http://localhost:3000"
echo "   Press Ctrl+C to stop"
echo ""

rails server -p 3000
