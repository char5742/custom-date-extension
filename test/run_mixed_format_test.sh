#!/bin/bash
# Run specific test for mixed date formats

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${YELLOW}=== Mixed Date Format Test ===${NC}"
echo ""

# Check test data exists
if [ ! -f "$PROJECT_ROOT/test/data/test_mixed_formats.csv" ]; then
    echo -e "${RED}Error: Test data file not found!${NC}"
    exit 1
fi

# Show test data summary
echo "Test data preview:"
head -5 "$PROJECT_ROOT/test/data/test_mixed_formats.csv"
echo "..."
echo ""

# Check unittest binary
UNITTEST_BIN="$PROJECT_ROOT/build/release/test/unittest"
if [ ! -f "$UNITTEST_BIN" ]; then
    echo -e "${RED}Error: unittest binary not found${NC}"
    echo "Please build the project first with 'make'"
    exit 1
fi

# Run the specific test
cd "$PROJECT_ROOT"
echo -e "${YELLOW}Running mixed_formats test...${NC}"
echo ""

if "$UNITTEST_BIN" --test-dir . "test/sql/mixed_formats.test"; then
    echo -e "\n${GREEN}Mixed format test passed!${NC}"
else
    echo -e "\n${RED}Mixed format test failed!${NC}"
    exit 1
fi