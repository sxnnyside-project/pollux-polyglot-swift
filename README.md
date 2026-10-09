# Pollux Polyglot Swift

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
[![CI](https://github.com/sxnnyside-project/pollux-polyglot-swift/workflows/CI/badge.svg)](https://github.com/sxnnyside-project/pollux-polyglot-swift/actions)

<p align="center">
  <strong>Universal Swift ✦ Strict Concurrency ✦ Deterministic Authority</strong><br>
  <em>Deterministic execution authority and sandboxing SDK for Swift on Apple Platforms and Linux.</em>
</p>

<p align="center">
  <a href="#about">About</a> ✦
  <a href="#features">Features</a> ✦
  <a href="#installation">Installation</a> ✦
  <a href="#usage">Usage</a> ✦
  <a href="#architecture">Architecture</a> ✦
  <a href="#contributing">Contributing</a>
</p>

---

## About

**Pollux Polyglot Swift** is the official Swift language binding for the Pollux Core deterministic authority sandboxing engine.

It bridges Swift applications across Apple platforms (macOS, iOS, watchOS, tvOS, visionOS) and Linux with the native Rust Core (`pollux-abi/1`), enforcing strict memory safety and modern Swift 6 Concurrency without data races.

Engine instances verify incoming capability requests (filesystem, network, process execution, secret access) against fine-grained Authority Manifests, returning deterministic evaluation traces and verdict decisions.

### Philosophy

> *"Deterministic capability enforcement with Swift 6 safety and zero raw pointer leaks."*

This is a Sxnnyside project, part of the Sxnnyside Project's core ecosystem.

## Features

- **Swift 6 Strict Concurrency**: Fully `Sendable` compliant types eliminating data races across tasks and actors.
- **Universal Apple & Linux Support**: Seamless execution on macOS 13+, iOS 16+, visionOS 1+, and modern Linux distributions.
- **Zero Raw Pointer Leaks**: Memory-safe wrappers prevent unsafe C pointer exposure across public APIs.
- **Automatic Resource Lifecycle**: Engine handles manage memory deterministically with automatic cleanup in `deinit` and explicit `close()`.
- **Modern Swift Testing**: Ships with test suites built on Apple's modern Swift Testing framework (`@Suite`, `@Test`, `#expect`).
- **ABI Version Verification**: Instantly verifies `pollux-abi/1` compatibility upon instantiation.

## Installation

### Swift Package Manager (Package.swift)

Add `pollux-polyglot-swift` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/sxnnyside-project/pollux-polyglot-swift.git", from: "0.1.0")
]
```

And add it to your target:

```swift
.target(
    name: "MyApplication",
    dependencies: [
        .product(name: "Pollux", package: "pollux-polyglot-swift")
    ]
)
```

### Xcode

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter repository URL: `https://github.com/sxnnyside-project/pollux-polyglot-swift.git`
3. Select version rule: **Up to Next Major Version** (`0.1.0`)
4. Add `Pollux` to your application target.

### From Source

```bash
git clone https://github.com/sxnnyside-project/pollux-polyglot-swift.git
cd pollux-polyglot-swift

just install
just check
```

## Usage

```swift
import Pollux

let manifestYaml = """
version: 1
filesystem:
  read:
    - ./config
    - ./assets
"""

do {
    // 1. Load engine instance
    let engine = try PolluxEngine.load(manifestYaml: manifestYaml)
    defer { engine.close() }

    // 2. Evaluate allowed read
    let readResult = try engine.evaluate(Operation.fileRead("./assets"))
    print("Can read ./assets: \(readResult.isAllowed)") // true
    print("Outcome: \(readResult.outcome)")              // "allow"

    // 3. Evaluate unauthorized write
    let writeResult = try engine.evaluate(Operation.fileWrite("./assets"))
    print("Can write ./assets: \(writeResult.isAllowed)") // false
    print("Outcome: \(writeResult.outcome)")              // "deny"
} catch {
    print("Evaluation error: \(error)")
}
```

## Architecture

```
pollux-polyglot-swift/
├── Sources/Pollux/          # Public Engine API, Operation structs, and error types
│   ├── PolluxEngine.swift   # High-level engine lifecycle and evaluation
│   ├── Operation.swift      # Strongly typed capability candidates
│   ├── EvaluationResult.swift # Verdict parser and trace models
│   ├── NativeBridge.swift   # Dynamic FFI dlopen/dlsym bridge
│   └── LibraryLoader.swift  # Cross-platform library path resolver
├── Tests/PolluxTests/       # Swift Testing verification suite
├── .github/workflows/       # Continuous integration and release pipelines
├── Package.swift            # SwiftPM manifest (Swift 6 tools)
└── Justfile                 # Standardized developer task runner
```

## Contributing

Contributions are accepted. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Before contributing, read the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Pollux Polyglot Swift</strong> — A Sxnnyside Project<br>
  <em>&copy; 2026 Sxnnyside Project</em>
</p>
