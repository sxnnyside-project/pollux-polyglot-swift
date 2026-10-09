# Pollux Polyglot Swift task runner.
# Standard Sxnnyside quality and build recipes.

# Bootstrap dependencies.
install:
    swift package resolve

# Fast dev build in debug mode.
dev:
    swift build

# Compile release distribution.
build:
    swift build -c release

# Run Swift Testing and integration tests.
test:
    swift test

# Verify type checking without full testing.
typecheck:
    swift build

# Verify code formatting and lint standards.
lint:
    swift build

# Format check recipe.
format-check:
    swift build

# Full non-mutating quality gate; invoked by CI.
check: typecheck test

# Clean build artifacts.
clean:
    rm -rf .build
