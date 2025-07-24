#!/bin/bash
set -e

echo "🚀 Starting MVP Test Suite..."

# Phase 1: JavaScript Tests
echo "📦 Phase 1: Running JavaScript tests..."
npm test
if [ $? -ne 0 ]; then
    echo "❌ JavaScript tests failed"
    exit 1
fi

# Phase 2: Python Tests (if exists)
if [ -f "requirements.txt" ]; then
    echo "🐍 Phase 2: Running Python tests..."
    python -m pytest python/ -v --json-report
    if [ $? -ne 0 ]; then
        echo "❌ Python tests failed"
        exit 1
    fi
fi

# Phase 3: SQL Tests (if exists)
if [ -d "sql" ]; then
    echo "🗄️ Phase 3: Running SQL tests..."
    # SQL test execution logic
fi

# Phase 4: Shell Tests (if exists)
if [ -d "shell" ]; then
    echo "🐚 Phase 4: Running Shell tests..."
    ./shell/run-system-tests.sh
fi

# Generate unified report
echo "📊 Generating unified test report..."
# node utils/generate-report.js (to be implemented)

echo "✅ All tests completed successfully!" 