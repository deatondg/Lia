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
        
        result = try parser.parse(from: correctNoHeader)
        XCTAssertEqual(result.0.0, nil)
        XCTAssertEqual(result.0.1, correctNoHeader)
        XCTAssertEqual(result.1, correctNoHeader.endIndex)
        
        let correctNoHeader2 =
            """
            {
            header
            }
            body
            """
        
        result = try parser.parse(from: correctNoHeader2)
        XCTAssertEqual(result.0.0, nil)
        XCTAssertEqual(result.0.1, correctNoHeader2)
        XCTAssertEqual(result.1, correctNoHeader2.endIndex)
        
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
        XCTAssertEqual(f, .noNewlineAfterBeginDelimeter)
        
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
        XCTAssertEqual(f, .noNewlineBeforeEndDelimeter)
        
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
        XCTAssertEqual(f, .noNewlineAfterEndDelimeter)
        
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
        XCTAssertEqual(f, .unexpectedBeginDelimeter)
        
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
        XCTAssertEqual(f, .unexpectedBeginDelimeter)
        
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
        XCTAssertEqual(f, .incorrectEndDelimeter)
        
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
        XCTAssertEqual(f, .incorrectEndDelimeter)
        
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
        XCTAssertEqual(f, .noEndDelimeter)
        
        let noEndDelimeter2 =
            """
            {#######
            header
            body
            """
        
        guard case let .failure(f) = parser.parse(from: noEndDelimeter2) else {
            XCTFail(); return
        }
        XCTAssertEqual(f, .noEndDelimeter)
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
