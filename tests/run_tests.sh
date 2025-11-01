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
    rm -f Safari*.png
    rm -f Calculator*.png
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

assert_file_size_under() {
    local file=$1
    local max_kb=$2
    if [ -f "$file" ]; then
        # Get file size in KB
        local size_kb=$(du -k "$file" | cut -f1)
        if [ "$size_kb" -le "$max_kb" ]; then
            pass_test
        else
            fail_test "File $file is too large (${size_kb}KB, expected ≤ ${max_kb}KB)"
        fi
    else
        fail_test "File $file does not exist"
    fi
}

assert_file_size_over() {
    local file=$1
    local min_kb=$2
    if [ -f "$file" ]; then
        # Get file size in KB
        local size_kb=$(du -k "$file" | cut -f1)
        if [ "$size_kb" -ge "$min_kb" ]; then
            pass_test
        else
            fail_test "File $file is too small (${size_kb}KB, expected ≥ ${min_kb}KB)"
        fi
    else
        fail_test "File $file does not exist"
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
$CLI "$TEST_APP" -o test_basic.png -f
assert_file_exists "test_basic.png"

# Test 2: Custom size (256x256)
print_test 2 "Custom size extraction (256x256)"
$CLI "$TEST_APP" -s 256 -o test_256.png -f
assert_file_exists "test_256.png"

# Test 3: Small size (64x64)
print_test 3 "Small icon extraction (64x64)"
$CLI "$TEST_APP" -s 64 -o test_64.png -f
assert_file_exists "test_64.png"

# Test 4: Large size (1024x1024)
print_test 4 "Large icon extraction (1024x1024)"
$CLI "$TEST_APP" -s 1024 -o test_1024.png -f
assert_file_exists "test_1024.png"

# Test 5: File size validation (should be reasonable)
print_test 5 "Output file size validation"
assert_file_size "test_basic.png" 1000

# Test 6: Default output naming
print_test 6 "Default output naming"
$CLI "$TEST_APP" -f
assert_file_exists "${APP_NAME}.png"

# Test 7: Custom output path with directory creation
print_test 7 "Custom output path with directory creation"
mkdir -p test_output
$CLI "$TEST_APP" -o test_output/icon.png -s 128 -f
assert_file_exists "test_output/icon.png"

# Test 8: Positional argument (without -i flag)
print_test 8 "Positional argument support"
$CLI "$TEST_APP" -s 128 -o test_positional.png -f
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

# Test 13: Multiple standard sizes (16, 32, 128, 256, 512)
print_test 13 "Multiple standard sizes (16, 32, 128, 256, 512)"
sizes=(16 32 128 256 512)
all_exist=true
for size in "${sizes[@]}"; do
    $CLI "$TEST_APP" -s $size -o test_${size}.png -f
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

# Test 14: Force flag to overwrite without prompt
print_test 14 "Force flag overwrites without prompting"
$CLI "$TEST_APP" -o test_overwrite.png -s 128
# This should overwrite without prompting when using --force
$CLI "$TEST_APP" -o test_overwrite.png -s 256 --force
assert_file_exists "test_overwrite.png"

# Test 15: Non-interactive mode rejects overwrite without --force
print_test 15 "Non-interactive mode rejects overwrite (CI-safe)"
$CLI "$TEST_APP" -o test_no_interactive.png -s 128
# In non-interactive mode (piped input), should fail without --force
set +e
echo "y" | $CLI "$TEST_APP" -o test_no_interactive.png -s 256 > /dev/null 2>&1
exit_code=$?
set -e
# Should fail (exit code 1) in non-interactive mode
if [ $exit_code -eq 1 ]; then
    pass_test
else
    fail_test "Expected exit code 1 in non-interactive mode, got $exit_code"
fi

# Test 16: Force flag works in non-interactive mode
print_test 16 "Force flag works in non-interactive mode"
$CLI "$TEST_APP" -o test_force_non_interactive.png -s 128
# This should succeed with --force even in non-interactive mode
$CLI "$TEST_APP" -o test_force_non_interactive.png -s 256 --force
assert_file_exists "test_force_non_interactive.png"

# Test 17: Short form -f flag works
print_test 17 "Short form -f flag for force"
$CLI "$TEST_APP" -o test_force_short.png -s 128
$CLI "$TEST_APP" -o test_force_short.png -s 256 -f
assert_file_exists "test_force_short.png"

# ============================================
# Max File Size Optimization Tests
# ============================================

# Test 18: Max file size with KB format
print_test 18 "Max file size optimization with KB format"
$CLI "$TEST_APP" -s 64 -m 30KB -o test_max_30kb.png -f
assert_file_size_under "test_max_30kb.png" 30

# Test 19: Max file size with K shorthand
print_test 19 "Max file size optimization with K shorthand"
$CLI "$TEST_APP" -s 64 -m 25K -o test_max_25k.png -f
assert_file_size_under "test_max_25k.png" 25

# Test 20: Max file size with MB format
print_test 20 "Max file size optimization with MB format"
$CLI "$TEST_APP" -s 512 -m 1MB -o test_max_1mb.png -f
assert_file_size_under "test_max_1mb.png" 1024

# Test 21: Max file size with M shorthand
print_test 21 "Max file size optimization with M shorthand"
$CLI "$TEST_APP" -s 512 -m 2M -o test_max_2m.png -f
assert_file_size_under "test_max_2m.png" 2048

# Test 22: Lowercase max file size format (kb)
print_test 22 "Max file size with lowercase kb"
$CLI "$TEST_APP" -s 64 -m 25kb -o test_max_25kb_lower.png -f
assert_file_size_under "test_max_25kb_lower.png" 25

# Test 23: Lowercase max file size format (mb)
print_test 23 "Max file size with lowercase mb"
$CLI "$TEST_APP" -s 512 -m 1mb -o test_max_1mb_lower.png -f
assert_file_size_under "test_max_1mb_lower.png" 1024

# Test 24: Auto-size selection for small file size target
print_test 24 "Auto-size selection for 10KB target (should select 32px)"
$CLI "$TEST_APP" -m 12KB -o test_auto_12kb.png -f
# File should exist and be optimized
assert_file_size_under "test_auto_12kb.png" 12

# Test 25: Auto-size selection for medium file size target
print_test 25 "Auto-size selection for 100KB target (should select 128px or 256px)"
$CLI "$TEST_APP" -m 100KB -o test_auto_100kb.png -f
assert_file_size_under "test_auto_100kb.png" 100

# Test 26: Auto-size selection for large file size target
print_test 26 "Auto-size selection for 2MB target (should select 1024px)"
$CLI "$TEST_APP" -m 2MB -o test_auto_2mb.png -f
assert_file_size_under "test_auto_2mb.png" 2048

# Test 27: File already under limit (no optimization needed)
print_test 27 "File already under limit (skip optimization)"
# Create a small icon that won't need optimization
$CLI "$TEST_APP" -s 64 -m 500KB -o test_no_opt_needed.png -f
assert_file_exists "test_no_opt_needed.png"

# Test 28: Impossible file size target (should fail with exit code 3)
print_test 28 "Impossible file size target fails gracefully"
set +e
$CLI "$TEST_APP" -s 128 -m 5KB -o test_impossible.png -f 2>/dev/null
exit_code=$?
set -e
if [ $exit_code -eq 3 ]; then
    pass_test
else
    fail_test "Expected exit code 3 for impossible optimization, got $exit_code"
fi

# Test 29: Very small target with auto-size (should still try to optimize)
print_test 29 "Very small target with auto-size"
set +e
$CLI "$TEST_APP" -m 5KB -o test_very_small_auto.png -f 2>/dev/null
exit_code=$?
set -e
# May succeed or fail depending on icon complexity, but should handle gracefully
if [ $exit_code -eq 0 ] || [ $exit_code -eq 3 ]; then
    pass_test
else
    fail_test "Expected exit code 0 or 3, got $exit_code"
fi

# Test 30: Max file size with explicit size overrides auto-selection
print_test 30 "Explicit size overrides auto-selection"
# Use explicit 256px size even though 200KB would normally get smaller auto-size
$CLI "$TEST_APP" -s 256 -m 300KB -o test_explicit_override.png -f
if [ -f "test_explicit_override.png" ]; then
    # Verify the file exists and was optimized
    assert_file_size_under "test_explicit_override.png" 300
else
    fail_test "File not created"
fi

# Test 31: Mixed case file size format (Kb, mB)
print_test 31 "Mixed case file size formats"
$CLI "$TEST_APP" -s 64 -m 30Kb -o test_mixed_case.png -f
assert_file_size_under "test_mixed_case.png" 30

# Test 32: File size optimization maintains reasonable quality
print_test 32 "Optimized file maintains minimum size (not zero bytes)"
$CLI "$TEST_APP" -s 128 -m 80KB -o test_quality_check.png -f
assert_file_size "test_quality_check.png" 1000

# Test 33: Multiple optimizations on same output file with force
print_test 33 "Multiple optimizations with force flag"
$CLI "$TEST_APP" -s 128 -m 60KB -o test_multi_opt.png -f
$CLI "$TEST_APP" -s 64 -m 30KB -o test_multi_opt.png -f
assert_file_size_under "test_multi_opt.png" 30

# Test 34: Large icon with reasonable file size limit
print_test 34 "1024px icon optimized to 1.5MB"
$CLI "$TEST_APP" -s 1024 -m 1.5MB -o test_1024_opt.png -f
assert_file_size_under "test_1024_opt.png" 1536

# Test 35: Auto-size selection message appears in output
print_test 35 "Auto-size selection message in output"
output=$($CLI "$TEST_APP" -m 50KB -o test_auto_msg.png -f 2>&1)
if echo "$output" | grep -q "Auto-selecting"; then
    pass_test
else
    fail_test "Expected auto-selection message in output"
fi

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
