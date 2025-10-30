#!/bin/bash
#
# Integration tests for Icon Grabber CLI
# Tests various features and edge cases
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up test artifacts..."
    rm -f test_*.png
    rm -f Safari_*.png
    rm -f Calculator_*.png
    rm -rf test_output
}

# Run cleanup on exit
trap cleanup EXIT

# Helper functions
print_test() {
    echo ""
    echo -e "${YELLOW}▶ Test $1: $2${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

pass_test() {
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_file_exists() {
    if [ -f "$1" ]; then
        pass_test
    else
        fail_test "File $1 does not exist"
    fi
}

assert_file_size() {
    local file=$1
    local min_size=$2
    if [ -f "$file" ]; then
        local size=$(wc -c < "$file" | tr -d ' ')
        if [ "$size" -gt "$min_size" ]; then
            pass_test
        else
            fail_test "File $file is too small ($size bytes, expected > $min_size)"
        fi
    else
        fail_test "File $file does not exist"
    fi
}

assert_exit_code() {
    local expected=$1
    local actual=$2
    if [ "$actual" -eq "$expected" ]; then
        pass_test
    else
        fail_test "Expected exit code $expected, got $actual"
    fi
}

# Check if CLI binary exists
if [ ! -f "./bin/icongrabber" ]; then
    echo -e "${RED}Error: CLI binary not found. Run 'make build' first.${NC}"
    exit 1
fi

CLI="./bin/icongrabber"

# Check if Safari.app exists (should be on all macOS systems)
TEST_APP="/Applications/Safari.app"
if [ ! -d "$TEST_APP" ]; then
    # Try Calculator as fallback
    TEST_APP="/Applications/Calculator.app"
    if [ ! -d "$TEST_APP" ]; then
        echo -e "${RED}Error: No test app found (tried Safari.app and Calculator.app)${NC}"
        exit 1
    fi
fi

APP_NAME=$(basename "$TEST_APP" .app)
echo "Using $TEST_APP for tests"
echo "================================"

# Test 1: Basic extraction (default size)
print_test 1 "Basic icon extraction (default 512x512)"
$CLI "$TEST_APP" -o test_basic.png
assert_file_exists "test_basic.png"

# Test 2: Custom size (256x256)
print_test 2 "Custom size extraction (256x256)"
$CLI "$TEST_APP" -s 256 -o test_256.png
assert_file_exists "test_256.png"

# Test 3: Small size (64x64)
print_test 3 "Small icon extraction (64x64)"
$CLI "$TEST_APP" -s 64 -o test_64.png
assert_file_exists "test_64.png"

# Test 4: Large size (1024x1024)
print_test 4 "Large icon extraction (1024x1024)"
$CLI "$TEST_APP" -s 1024 -o test_1024.png
assert_file_exists "test_1024.png"

# Test 5: File size validation (should be reasonable)
print_test 5 "Output file size validation"
assert_file_size "test_basic.png" 1000

# Test 6: Default output naming
print_test 6 "Default output naming"
$CLI "$TEST_APP"
assert_file_exists "${APP_NAME}_512x512.png"

# Test 7: Custom output path with directory creation
print_test 7 "Custom output path with directory creation"
mkdir -p test_output
$CLI "$TEST_APP" -o test_output/icon.png -s 128
assert_file_exists "test_output/icon.png"

# Test 8: Positional argument (without -i flag)
print_test 8 "Positional argument support"
$CLI "$TEST_APP" -s 128 -o test_positional.png
assert_file_exists "test_positional.png"

# Test 9: Help flag
print_test 9 "Help flag (--help)"
if $CLI --help > /dev/null 2>&1; then
    pass_test
else
    fail_test "Help flag failed"
fi

# Test 10: Version flag
print_test 10 "Version flag (--version)"
if $CLI --version > /dev/null 2>&1; then
    pass_test
else
    fail_test "Version flag failed"
fi

# Test 11: Invalid app path (should fail gracefully)
print_test 11 "Invalid app path handling"
set +e  # Temporarily disable exit on error
$CLI /NonExistent/App.app -o test_invalid.png 2>/dev/null
exit_code=$?
set -e
if [ $exit_code -ne 0 ]; then
    pass_test
else
    fail_test "Should have failed with invalid app path"
fi

# Test 12: Missing required argument (should fail gracefully)
print_test 12 "Missing required argument handling"
set +e
$CLI -o test_no_input.png 2>/dev/null
exit_code=$?
set -e
if [ $exit_code -ne 0 ]; then
    pass_test
else
    fail_test "Should have failed with missing input"
fi

# Test 13: Multiple size formats
print_test 13 "Multiple standard sizes (16, 32, 128, 256, 512)"
sizes=(16 32 128 256 512)
all_exist=true
for size in "${sizes[@]}"; do
    $CLI "$TEST_APP" -s $size -o test_${size}.png
    if [ ! -f "test_${size}.png" ]; then
        all_exist=false
        break
    fi
done
if [ "$all_exist" = true ]; then
    pass_test
else
    fail_test "Some size extractions failed"
fi

# Test 14: Overwrite existing file
print_test 14 "Overwrite existing file"
$CLI "$TEST_APP" -o test_overwrite.png -s 128
$CLI "$TEST_APP" -o test_overwrite.png -s 256
assert_file_exists "test_overwrite.png"

# Print summary
echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo -e "Total tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    exit 0
fi
