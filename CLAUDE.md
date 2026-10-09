# Pollux Polyglot Swift Guide

## Overview
`pollux-polyglot-swift` is the official Swift language binding for Pollux Core and the Pollux FFI Native Bridge (`pollux-abi/1`).
Built with modern Swift 6 (Strict Concurrency, `Sendable`, Swift Testing) for Apple Platforms (macOS, iOS, watchOS, tvOS, visionOS) and Linux.

## Commands

Always use `just` recipes when interacting with this repository:

- `just install` - Resolve and download SwiftPM package dependencies
- `just dev` - Fast debug compilation of Swift targets
- `just build` - Compile release distribution binary artifacts
- `just test` - Run full Swift Testing and integration suite
- `just typecheck` - Verify compiler type checking without full testing
- `just lint` - Verify code standards and lint rules
- `just format-check` - Verify formatting adherence
- `just check` - Run full non-mutating quality gate (`typecheck` + `test`)
- `just clean` - Clean SwiftPM build artifacts (`.build`)

## Architecture Rules

- **Swift 6 Strict Concurrency**: All exposed structs and classes must be `Sendable` compliant without data races.
- **Deterministic Resource Disposal**: Engine instances manage native C handles with deterministic destruction in `deinit` and explicit `close()`.
- **Dynamic FFI Resolution**: `NativeBridge` resolves `libpollux_ffi` dynamically via `dlopen`/`dlsym` across Apple and Linux platforms.
- **Zero Raw Pointers Exposed**: Memory safety guarantees mean no raw `UnsafeMutableRawPointer` or `UnsafePointer<CChar>` are leaked across public APIs.
- **Modern Swift Testing**: Test suites use Swift Testing (`@Suite`, `@Test`, `#expect`) over legacy XCTest.
