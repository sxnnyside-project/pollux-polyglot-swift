# Changelog

All notable changes to **Pollux Polyglot Swift** are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.1.0] — 2026-10-09

### Added

- Swift 6 native language binding for Pollux Core and the FFI native bridge (`pollux-abi/1`).
- Modern Swift Concurrency (`Sendable`, strict concurrency enabled).
- Idiomatic `PolluxEngine` resource management with automatic memory cleanup in `deinit` and explicit `close()`.
- Strongly-typed `Operation` models with built-in factories for filesystem, network, process, and custom domains.
- Full protocol evaluation trace deserialization via `EvaluationResult`.
- Comprehensive test suite leveraging the new Swift Testing framework (`@Test`, `@Suite`).
- Cross-platform support for Apple Platforms (macOS, iOS, tvOS, watchOS, visionOS) and Linux.

---

[Unreleased]: https://github.com/sxnnyside-project/pollux-polyglot-swift/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/sxnnyside-project/pollux-polyglot-swift/releases/tag/v0.1.0
