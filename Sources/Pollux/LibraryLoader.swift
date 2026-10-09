import Foundation

/// Resolves the file system path for the `libpollux_ffi` native dynamic library.
internal enum LibraryLoader {
    private static var libraryExtension: String {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
        return "dylib"
        #elseif os(Windows)
        return "dll"
        #else
        return "so"
        #endif
    }

    private static var libraryFileName: String {
        #if os(Windows)
        return "pollux_ffi.dll"
        #else
        return "libpollux_ffi.\(libraryExtension)"
        #endif
    }

    /// Locates the dynamic library path from environment variables, bundle locations, or system paths.
    static func resolve(customPath: String? = nil) throws -> String {
        var searchedPaths: [String] = []

        if let custom = customPath, !custom.isEmpty {
            if FileManager.default.fileExists(atPath: custom) {
                return custom
            }
            searchedPaths.append(custom)
        }

        let env = ProcessInfo.processInfo.environment
        if let envCore = env["POLLUX_CORE_LIB"], !envCore.isEmpty {
            if FileManager.default.fileExists(atPath: envCore) {
                return envCore
            }
            searchedPaths.append(envCore)
        }

        if let envFfi = env["POLLUX_FFI_PATH"], !envFfi.isEmpty {
            if FileManager.default.fileExists(atPath: envFfi) {
                return envFfi
            }
            searchedPaths.append(envFfi)
        }

        // Resolve relative to the repository source root if built locally
        let thisFileUrl = URL(fileURLWithPath: #filePath)
        let repoRootUrl = thisFileUrl.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let repoLibPath = repoRootUrl.appendingPathComponent("lib/\(libraryFileName)").path

        let candidates = [
            // Repo lib directory resolved from source file
            repoLibPath,
            // Local project lib directories
            "./lib/\(libraryFileName)",
            "../lib/\(libraryFileName)",
            // Native bridge targets in monorepo
            "../../Native/pollux-polyglot-native-bridge/target/release/\(libraryFileName)",
            "../../Native/pollux-polyglot-native-bridge/target/debug/\(libraryFileName)",
            "../pollux-polyglot-native-bridge/target/release/\(libraryFileName)",
            "../pollux-polyglot-native-bridge/target/debug/\(libraryFileName)",
            // Pollux target in workspace
            "../../Pollux/target/release/\(libraryFileName)",
            "../../Pollux/target/debug/\(libraryFileName)",
            // Standard system install locations
            "/opt/homebrew/lib/\(libraryFileName)",
            "/usr/local/lib/\(libraryFileName)",
            "/usr/lib/\(libraryFileName)"
        ]

        for candidate in candidates {
            let expanded = NSString(string: candidate).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expanded) {
                return expanded
            }
            searchedPaths.append(expanded)
        }

        throw PolluxError.libraryNotFound(searchedPaths: searchedPaths)
    }
}
