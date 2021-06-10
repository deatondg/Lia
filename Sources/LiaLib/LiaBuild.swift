public enum LiaBuild {
    public enum LiaBuildError: Error {
        case sourcesMustHaveSwiftExtension
    }
    public static func swiftArguments(libDirectory: Path, libs: [String]) -> [String] {
        [
            "-Xlinker", "-rpath",
            "-Xlinker", libDirectory.path,
            "-L", libDirectory.path,
            "-I", libDirectory.path
        ] + libs.map({ "-l" + $0 })
    }
    public static func swiftcArguments(libDirectory: Path, libs: [String], sources: [Path], destination: Path) throws -> [String] {
        guard sources.allSatisfy({ $0.extension == "swift" }) else { throw LiaBuildError.sourcesMustHaveSwiftExtension }
        return swiftArguments(libDirectory: libDirectory, libs: libs) + sources.map(\.path) + ["-o", destination.path]
    }
    public static func swiftcArguments(libDirectory: Path, libs: [String], sources: Path..., destination: Path) throws -> [String] {
        try swiftcArguments(libDirectory: libDirectory, libs: libs, sources: sources, destination: destination)
    }
    public static func swiftcArguments(libDirectory: Path, libs: [String], source: Path, destination: Path) throws -> [String] {
        try swiftcArguments(libDirectory: libDirectory, libs: libs, sources: source, destination: destination)
    }
    
    public static func build(swiftc: Path, libDirectory: Path, libs: [String], sources: [Path], destination: Path) async throws {
        try await swiftc.run(withArguments: swiftcArguments(libDirectory: libDirectory, libs: libs, sources: sources, destination: destination)).confirmEmpty()
    }
    public static func build(swiftc: Path, libDirectory: Path, libs: [String], sources: Path..., destination: Path) async throws {
        try await build(swiftc: swiftc, libDirectory: libDirectory, libs: libs, sources: sources, destination: destination)
    }
    public static func build(swiftc: Path, libDirectory: Path, libs: [String], source: Path, destination: Path) async throws {
        try await build(swiftc: swiftc, libDirectory: libDirectory, libs: libs, sources: source, destination: destination)
    }
}
