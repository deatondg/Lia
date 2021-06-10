import XCTest
@testable import LiaLib

final class LiaParsersTests: XCTestCase {
    func testTemplateHeaderAndBodyParser() throws {
        let parser = TemplateHeaderAndBodyParser()
        var result: ((String?, String), String.Index)
        
        let correctHeader =
            """
            {#######
            header
            #######}
            body
            """
        
        result = try parser.parse(from: correctHeader)
        XCTAssertEqual(result.0.0, "header\n")
        XCTAssertEqual(result.0.1, "body")
        XCTAssertEqual(result.1, correctHeader.endIndex)
        
        let correctNoHeader =
            """
            {{#######
            header
            #######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: correctNoHeader) else {
            XCTFail(); return
        }
        guard case .noHeader = f else {
            XCTFail(); return
        }
        
        let correctNoHeader2 =
            """
            {
            header
            }
            body
            """
        
        guard case let .failure(f) = parser.parse(from: correctNoHeader2) else {
            XCTFail(); return
        }
        guard case .noHeader = f else {
            XCTFail(); return
        }
    
        let correctEmptyHeader =
            """
            {#######
            #######}
            body
            """
        
        result = try parser.parse(from: correctEmptyHeader)
        XCTAssertEqual(result.0.0, "")
        XCTAssertEqual(result.0.1, "body")
        XCTAssertEqual(result.1, correctEmptyHeader.endIndex)
        
        let noNewlineAfterBeginDelimeter =
            """
            {#######hi
            header
            #######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noNewlineAfterBeginDelimeter) else {
            XCTFail(); return
        }
        guard case let .noNewlineAfterBeginDelimeter(index) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(index, noNewlineAfterBeginDelimeter.firstIndex(of: "h"))
        
        let noNewlineBeforeEndDelimeter =
            """
            {#######
            header
            hi#######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noNewlineBeforeEndDelimeter) else {
            XCTFail(); return
        }
        guard case let .noNewlineBeforeEndDelimeter(index) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(index, noNewlineBeforeEndDelimeter.index(after: noNewlineBeforeEndDelimeter.firstIndex(of: "i")!))
        
        let noNewlineAfterEndDelimeter =
            """
            {#######
            header
            #######} hi
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noNewlineAfterEndDelimeter) else {
            XCTFail(); return
        }
        guard case let .noNewlineAfterEndDelimeter(index) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(index, noNewlineAfterEndDelimeter.index(after: noNewlineAfterEndDelimeter.firstIndex(of: "}")!))
        
        let unexpectedBeginDelimeter =
            """
            {#######
            header {#######
            #######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: unexpectedBeginDelimeter) else {
            XCTFail(); return
        }
        guard case let .unexpectedBeginDelimeter(range) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(range, unexpectedBeginDelimeter.indices.filter({ unexpectedBeginDelimeter[$0] == "{" }).dropFirst().first!..<unexpectedBeginDelimeter.indices.filter({ unexpectedBeginDelimeter[$0] == "\n" }).dropFirst().first!)
        
        let unexpectedBeginDelimeter2 =
            """
            {#######
            header {########}
            #######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: unexpectedBeginDelimeter2) else {
            XCTFail(); return
        }
        guard case let .unexpectedBeginDelimeter(range) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(range, unexpectedBeginDelimeter2.indices.filter({ unexpectedBeginDelimeter2[$0] == "{" }).dropFirst().first!..<unexpectedBeginDelimeter2.index(before: unexpectedBeginDelimeter2.indices.filter({ unexpectedBeginDelimeter2[$0] == "\n" }).dropFirst().first!))
        
        let incorrectEndDelimeter =
            """
            {#######
            header
            ########}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: incorrectEndDelimeter) else {
            XCTFail(); return
        }
        guard case let .incorrectEndDelimeter(range) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(range, incorrectEndDelimeter.index(incorrectEndDelimeter.firstIndex(of: "r")!, offsetBy: 2)..<incorrectEndDelimeter.index(after: incorrectEndDelimeter.firstIndex(of: "}")!))
        
        let incorrectEndDelimeter2 =
            """
            {#######
            header
            #########}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: incorrectEndDelimeter2) else {
            XCTFail(); return
        }
        guard case let .incorrectEndDelimeter(range) = f else {
            XCTFail(); return
        }
        XCTAssertEqual(range, incorrectEndDelimeter2.index(incorrectEndDelimeter2.firstIndex(of: "r")!, offsetBy: 2)..<incorrectEndDelimeter2.index(after: incorrectEndDelimeter2.firstIndex(of: "}")!))
        
        let noEndDelimeter =
            """
            {#######
            header
            ######}
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noEndDelimeter) else {
            XCTFail(); return
        }
        guard case .noEndDelimeter = f else {
            XCTFail(); return
        }
        
        let noEndDelimeter2 =
            """
            {#######
            header
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noEndDelimeter2) else {
            XCTFail(); return
        }
        guard case .noEndDelimeter = f else {
            XCTFail(); return
        }
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Self.packageDirectory
    }
    class var packageDirectory: Path {
        Path(#file).deletingLastComponent().deletingLastComponent().deletingLastComponent()
    }
    
    /// Returns the path to the libraries built by SwiftPM
    var libDirectory: Path {
        packageDirectory.appending(components: ".build", "debug")
    }
}
