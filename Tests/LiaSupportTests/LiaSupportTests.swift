import XCTest
@testable import LiaSupport

final class LiaSupportTests: XCTestCase {
    func testLiaOptionalLocationWorks() {
        let optional1: LiaOptional<Never> = .none()
        let optional2: LiaOptional<Never> = .none(); let optional3: LiaOptional<Never> = .none()
        
        XCTAssertNotEqual(optional1.location.line, optional2.location.line)
        XCTAssertEqual(optional1.location.column, optional2.location.column)
        
        XCTAssertEqual(optional2.location.line, optional3.location.line)
        XCTAssertNotEqual(optional2.location.column, optional3.location.column)
        
        XCTAssertNotEqual(optional1.location.line, optional3.location.line)
        XCTAssertNotEqual(optional1.location.column, optional3.location.column)
    }
}
