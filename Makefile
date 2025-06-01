PREFIX ?= /usr/local
BINARY = contacts
BUILD_DIR = .build/release

.PHONY: build install uninstall clean

build:
	@echo "Building release version..."
	swift build -c release

install: build
	@echo "Installing to $(PREFIX)/bin..."
	@mkdir -p $(PREFIX)/bin
	@cp $(BUILD_DIR)/$(BINARY) $(PREFIX)/bin/
	@echo "Installed $(BINARY) to $(PREFIX)/bin"

uninstall:
	@echo "Removing $(PREFIX)/bin/$(BINARY)..."
	@rm -f $(PREFIX)/bin/$(BINARY)

clean:
	@echo "Cleaning build artifacts..."
	swift package clean
