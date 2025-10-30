Icon Grabber Tests

This directory contains the test suite for Icon Grabber CLI.

Running Tests

Run all tests

```bash
make test
```

Or directly:

```bash
./tests/run_tests.sh
```

Test Suite

The test suite includes the following tests:

Functional Tests
. Basic extraction- Default x PNG extraction
. Custom size- xicon extraction
. Small size- xicon extraction
. Large size- xicon extraction
. File size validation- Ensures output files are reasonable size
. Default naming- Tests automatic filename generation
. Custom output path- Tests directory creation and custom paths
. Positional arguments- Tests CLI argument parsing
. Help flag- Ensures `--help` works
. Version flag- Ensures `--version` works

Error Handling Tests
. Invalid app path- Graceful failure with non-existent apps
. Missing arguments- Proper error handling
. Multiple sizes- Tests various standard icon sizes
. File overwrite- Tests overwriting existing files

Test Output

Tests create temporary files that are automatically cleaned up:
- `test_.png` - Various test output files
- `_x.png` - Default named output files
- `test_output/` - Test directory for path tests

All artifacts are removed after test completion.

GitHub Actions

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

See `.github/workflows/ci.yml` for the full CI configuration.

CI Jobs

. Test Job
- Runs full integration test suite
- Uploads test artifacts for inspection
- Tests help and version commands

. Multi-Version Build Test
- Tests on mac OS , , and latest
- Ensures compatibility across mac OS versions
- Runs quick smoke tests

. Lint and Format
- Checks Swift syntax
- Verifies project structure

. Installation Test
- Tests build and installation process
- Verifies binary works after installation
- Tests user-level installation (no sudo)

Requirements

- mac OS (tests use mac OS system apps like Safari or Calculator)
- Swift compiler
- Built binary at `./bin/icongrabber`

Exit Codes

- `` - All tests passed
- `` - One or more tests failed

Adding New Tests

To add a new test:

. Add a test case in `run_tests.sh`
. Use the helper functions:
 - `print_test <number> <description>`
 - `pass_test` or `fail_test <reason>`
 - `assert_file_exists <path>`
 - `assert_file_size <path> <min_bytes>`
 - `assert_exit_code <expected> <actual>`

Example:

```bash
print_test "My new test description"
$CLI /Applications/Safari.app -o test_new.png
assert_file_exists "test_new.png"
```

Debugging Failed Tests

If tests fail:

. Check the test output for specific failure messages
. Run individual tests by commenting out others in `run_tests.sh`
. Remove the cleanup trap to inspect test artifacts:
 ```bash
 Comment out: trap cleanup EXIT
 ```
. Check GitHub Actions artifacts for test outputs

Local Testing

Before pushing changes:

```bash
Build
make build

Run tests
make test

Clean up
make clean
```
