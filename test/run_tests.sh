#!/bin/bash
# Test runner script for custom_date extension

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${YELLOW}=== Custom Date Extension Test Runner ===${NC}"
echo "Project root: $PROJECT_ROOT"
echo ""

# Check if unittest binary exists
UNITTEST_BIN="$PROJECT_ROOT/build/release/test/unittest"
if [ ! -f "$UNITTEST_BIN" ]; then
    echo -e "${RED}Error: unittest binary not found at $UNITTEST_BIN${NC}"
    echo "Please build the project first with 'make'"
    exit 1
fi

# Check if extension is built
EXTENSION_PATH="$PROJECT_ROOT/build/release/extension/custom_date/custom_date.duckdb_extension"
if [ ! -f "$EXTENSION_PATH" ]; then
    echo -e "${YELLOW}Warning: Extension not found at $EXTENSION_PATH${NC}"
    echo "Some tests may fail"
fi

# Run tests
cd "$PROJECT_ROOT"

echo -e "${YELLOW}Running custom_date extension tests...${NC}"
echo ""

# Run all tests in the custom_date group
if "$UNITTEST_BIN" --test-dir . "test/sql/custom_date.test" && "$UNITTEST_BIN" --test-dir . "test/sql/mixed_formats.test"; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi