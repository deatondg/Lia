import Foundation
import tee

extension Path {
    public static func executable(named name: String) async throws -> Path {
        Path(try await Path("/bin/sh").run(withArguments: "-c", "which \(name)").extractOutput().trimmingCharacters(in: .newlines))
    }
    
    @discardableResult
    public func run(inDirectory directory: Path? = nil, withArguments arguments: String..., tee shouldTee: Bool = false) async throws -> ProcessResults {
        return try await self.run(inDirectory: directory, withArguments: arguments, tee: shouldTee)
    }
    @discardableResult
    public func run(inDirectory directory: Path? = nil, withArguments arguments: [String], tee shouldTee: Bool = false) async throws -> ProcessResults {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = self.url
        process.arguments = arguments
        process.currentDirectoryURL = directory?.url
        
        if shouldTee {
            let processOutput = Pipe()
            let processError = Pipe()
            
            tee(from: processOutput, into: outputPipe, FileHandle.standardOutput)
            tee(from: processError, into: errorPipe, FileHandle.standardError)
            
            process.standardOutput = processOutput
            process.standardError = processError
        } else {
            process.standardOutput = outputPipe
            process.standardError = errorPipe
        }
        
        let xcodeTestVars = ["OS_ACTIVITY_DT_MODE", "XCTestSessionIdentifier", "XCTestBundlePath", "XCTestConfigurationFilePath"]
        if xcodeTestVars.contains(where: ProcessInfo.processInfo.environment.keys.contains) {
            var env = ProcessInfo.processInfo.environment
            for key in xcodeTestVars {
                env[key] = nil
            }
            process.environment = env
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            process.terminationHandler = { _ in
                continuation.resume()
            }
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
        
        let output = try String(data: outputPipe.fileHandleForReading.readDataToEndOfFile())
        let error = try String(data: errorPipe.fileHandleForReading.readDataToEndOfFile())
        
        return ProcessResults(output: output, error: error, terminationStatus: process.terminationStatus, terminationReason: process.terminationReason)
    }
}

public struct ProcessResults: Error {
    public let output: String
    public let error: String
    public let terminationStatus: Int32
    public let terminationReason: Process.TerminationReason
    
    public func extractOutputAndError() throws -> (output: String, error: String) {
        guard terminationStatus == 0,
              terminationReason == .exit
        else {
            throw self
        }
        return (output, error)
    }
        
    public func extractOutput() throws -> String {
        guard error == "",
              terminationStatus == 0,
              terminationReason == .exit
        else {
            throw self
        }
        return output
    }
    
    public func confirmEmpty() throws {
        guard try self.extractOutput() == "" else { throw self }
    }
}
