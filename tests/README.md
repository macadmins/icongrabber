# Icon Grabber Tests

This directory contains the test suite for Icon Grabber CLI.

## Running Tests

### Run all tests

```bash
make test
```

Or directly:

```bash
./tests/run_tests.sh
```

## Test Suite

The test suite includes the following tests:

### Functional Tests
1. **Basic extraction** - Default 512x512 PNG extraction
2. **Custom size** - 256x256 icon extraction
3. **Small size** - 64x64 icon extraction
4. **Large size** - 1024x1024 icon extraction
5. **File size validation** - Ensures output files are reasonable size
6. **Default naming** - Tests automatic filename generation
7. **Custom output path** - Tests directory creation and custom paths
8. **Positional arguments** - Tests CLI argument parsing
9. **Help flag** - Ensures `--help` works
10. **Version flag** - Ensures `--version` works

### Error Handling Tests
11. **Invalid app path** - Graceful failure with non-existent apps
12. **Missing arguments** - Proper error handling
13. **Multiple sizes** - Tests various standard icon sizes
14. **File overwrite** - Tests overwriting existing files

## Test Output

Tests create temporary files that are automatically cleaned up:
- `test_*.png` - Various test output files
- `*_512x512.png` - Default named output files
- `test_output/` - Test directory for path tests

All artifacts are removed after test completion.

## GitHub Actions

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

See `.github/workflows/ci.yml` for the full CI configuration.

## CI Jobs

### 1. Test Job
- Runs full integration test suite
- Uploads test artifacts for inspection
- Tests help and version commands

### 2. Multi-Version Build Test
- Tests on macOS 13, 14, and latest
- Ensures compatibility across macOS versions
- Runs quick smoke tests

### 3. Lint and Format
- Checks Swift syntax
- Verifies project structure

### 4. Installation Test
- Tests build and installation process
- Verifies binary works after installation
- Tests user-level installation (no sudo)

## Requirements

- macOS (tests use macOS system apps like Safari or Calculator)
- Swift compiler
- Built binary at `./bin/icongrabber`

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Adding New Tests

To add a new test:

1. Add a test case in `run_tests.sh`
2. Use the helper functions:
   - `print_test <number> <description>`
   - `pass_test` or `fail_test <reason>`
   - `assert_file_exists <path>`
   - `assert_file_size <path> <min_bytes>`
   - `assert_exit_code <expected> <actual>`

Example:

```bash
print_test 15 "My new test description"
$CLI /Applications/Safari.app -o test_new.png
assert_file_exists "test_new.png"
```

## Debugging Failed Tests

If tests fail:

1. Check the test output for specific failure messages
2. Run individual tests by commenting out others in `run_tests.sh`
3. Remove the cleanup trap to inspect test artifacts:
   ```bash
   # Comment out: trap cleanup EXIT
   ```
4. Check GitHub Actions artifacts for test outputs

## Local Testing

Before pushing changes:

```bash
# Build
make build

# Run tests
make test

# Clean up
make clean
```
