# Makefile for Icon Grabber CLI

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1

CLI_SOURCE = icongrabber-cli/main.swift
CLI_BINARY = bin/icongrabber
MAN_PAGE = icongrabber.1

.PHONY: all build install uninstall clean test help release

all: build

help:
	@echo "Icon Grabber CLI - Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build      - Compile the CLI tool (default)"
	@echo "  release    - Create optimized release build"
	@echo "  install    - Install the CLI to $(BINDIR)"
	@echo "  uninstall  - Remove the CLI from $(BINDIR)"
	@echo "  clean      - Remove build artifacts"
	@echo "  test       - Run a simple test extraction"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX     - Installation prefix (default: /usr/local)"

build:
	@echo "Building Icon Grabber CLI..."
	@mkdir -p bin
	@swiftc -o $(CLI_BINARY) $(CLI_SOURCE) -framework AppKit
	@echo "✓ Build complete: $(CLI_BINARY)"

install: build
	@echo "Installing Icon Grabber CLI to $(BINDIR)..."
	@mkdir -p $(BINDIR)
	@install -m 755 $(CLI_BINARY) $(BINDIR)/icongrabber
	@echo "✓ Installed binary to $(BINDIR)/icongrabber"
	@if [ -f "$(MAN_PAGE)" ]; then \
		echo "Installing man page to $(MANDIR)..."; \
		mkdir -p $(MANDIR); \
		install -m 644 $(MAN_PAGE) $(MANDIR)/icongrabber.1; \
		echo "✓ Installed man page to $(MANDIR)/icongrabber.1"; \
	fi
	@echo ""
	@echo "You can now use 'icongrabber' from anywhere!"
	@echo "View the manual with: man icongrabber"

uninstall:
	@echo "Uninstalling Icon Grabber CLI..."
	@rm -f $(BINDIR)/icongrabber
	@rm -f $(MANDIR)/icongrabber.1
	@echo "✓ Uninstalled"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf bin
	@rm -rf release
	@rm -f test_*.png
	@echo "✓ Clean complete"

release:
	@./release.sh

test: build
	@echo "Running Icon Grabber CLI tests..."
	@./tests/run_tests.sh
