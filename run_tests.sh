#!/bin/bash

# FoundIt Test Runner Script
echo "🧪 Running FoundIt Tests"
echo "========================"

echo ""
echo "📋 Running RSpec unit tests..."
bundle exec rspec --format documentation

echo ""
echo "📋 Running Cucumber integration tests..."
bundle exec cucumber --format pretty

echo ""
echo "✅ All tests completed!"
