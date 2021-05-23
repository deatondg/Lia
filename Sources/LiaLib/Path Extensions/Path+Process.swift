import Foundation
import tee

extension Path {
    public static func executable(named name: String) throws -> Path {
        Path(try Path("/bin/sh").runSync(withArguments: "-c", "which \(name)").extractOutput().trimmingCharacters(in: .newlines))
    }
    
    @discardableResult
    public func runSync(inDirectory directory: Path? = nil, withArguments arguments: String..., tee shouldTee: Bool = false) throws -> ProcessResults {
        return try self.runSync(inDirectory: directory, withArguments: arguments, tee: shouldTee)
    }
    @discardableResult
    public func runSync(inDirectory directory: Path? = nil, withArguments arguments: [String], tee shouldTee: Bool = false) throws -> ProcessResults {
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
        
        try process.run()
        process.waitUntilExit()
        
        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        
        return ProcessResults(output: output, error: error, terminationStatus: process.terminationStatus, terminationReason: process.terminationReason)
    }
}

public struct ProcessResults: Error {
    public let output: String?
    public let error: String?
    public let terminationStatus: Int32
    public let terminationReason: Process.TerminationReason
    
    public func extractOutput() throws -> String {
        guard let output = output,
              error == "",
              terminationStatus == 0,
              terminationReason == .exit
        else {
            throw self
        }
        return output
    }
}
