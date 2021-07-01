import Foundation

@discardableResult
public func timeIt<T>(name: String, _ f: () throws -> T) rethrows -> T {
    print("Starting \(name)...")
    let start = Date()
    let result = try f()
    let end = Date()
    print("Finished \(name) in \(end.timeIntervalSince(start)) seconds.")
    return result
}
@discardableResult
public func timeIt<T>(name: String, _ f: () async throws -> T) async rethrows -> T {
    print("Starting \(name)...")
    let start = Date()
    let result = try await f()
    let end = Date()
    print("Finished \(name) in \(end.timeIntervalSince(start)) seconds.")
    return result
}
