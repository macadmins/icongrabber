# Contributing to Icon Grabber

Thank you for your interest in contributing to Icon Grabber! 🎉

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/icongrabber.git`
3. Create a feature branch: `git checkout -b my-feature`
4. Make your changes
5. Run tests: `make test`
6. Commit your changes: `git commit -am 'Add new feature'`
7. Push to your fork: `git push origin my-feature`
8. Open a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/kitzy/icongrabber.git
cd icongrabber

# Build the project
make build

# Run tests
make test

# Test locally
./bin/icongrabber /Applications/Safari.app
```

## Running Tests

Before submitting a PR, make sure all tests pass:

```bash
make test
```

The test suite includes:
- Integration tests
- CLI argument parsing tests
- Error handling tests
- Multiple icon size tests

See [tests/README.md](tests/README.md) for details.

## Code Guidelines

- **Swift Style**: Follow standard Swift conventions
- **Comments**: Add comments for complex logic
- **Error Handling**: Always handle errors gracefully
- **User Messages**: Keep CLI output clear and helpful

## Pull Request Process

1. **Update Documentation**: If you add features, update the README
2. **Add Tests**: Add tests for new functionality
3. **Pass CI**: Ensure all GitHub Actions checks pass
4. **Description**: Provide a clear description of changes
5. **One Feature**: Keep PRs focused on a single feature/fix

## Reporting Bugs

When reporting bugs, please include:

- macOS version
- Icon Grabber version (`icongrabber --version`)
- Steps to reproduce
- Expected vs actual behavior
- Error messages (if any)

## Feature Requests

Feature requests are welcome! Please:

- Check if it's already requested in Issues
- Explain the use case
- Describe the desired behavior
- Consider if it fits the project scope

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
