BINARY   := "contacts"
BUILD_DIR := ".build/release"

PREFIX := env("PREFIX", "/usr/local")

default: install

build:
    swift build -c release

install: build
    mkdir -p {{PREFIX}}/bin/
    cp {{BUILD_DIR}}/{{BINARY}} {{PREFIX}}/bin/

uninstall:
    rm -f {{PREFIX}}/bin/{{BINARY}}

clean:
    swift package clean
