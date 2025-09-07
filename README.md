# macOS Contacts

A read only Swift command line tool for listing, and searching macOS Contacts, with support for birthday listings and aerc integration.

## Build and Installation

This project uses [just](https://github.com/casey/just) as a command runner and requires the [Swift](https://swift.org/) toolchain for building. Below are the available commands:

### Available Commands

- `just` or `just install` - Build and install the binary to `PREFIX/bin/` (default: `/usr/local/bin`)
- `just build` - Build the release binary in the `.build/release` directory
- `just uninstall` - Remove the installed binary
- `just clean` - Clean the Swift package build artifacts

## Usage

```
Contacts

Usage:
  contacts <query>            Search contacts by name
  contacts --list             List all contacts
  contacts --search <query>   Search contacts by name
  contacts --birthdays        List contacts with birthdays this month
  contacts --duplicates       Find duplicate contacts
  contacts --aerc [query]     List contacts in aerc format, optionally filtered by query
  contacts --help             Show this help message

Short options:
  contacts -l                 Short form for --list
  contacts -s <query>         Short form for --search
  contacts -b                 Short form for --birthdays
  contacts -d                 Short form for --duplicates
  contacts -a [query]         Short form for --aerc
  contacts -h                 Short form for --help

Examples:
  contacts John
  contacts --list
  contacts --birthdays
  contacts --duplicates
  contacts --search "John"
  contacts -s "john@example.com"
  contacts --aerc
  contacts --aerc "john"
```

## aerc

```
[compose]
address-book-cmd=contacts --aerc %s
```
