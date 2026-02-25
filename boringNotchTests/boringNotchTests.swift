import XCTest
@testable import boringNotch

final class boringNotchTests: XCTestCase {
    func testAppModuleLoads() {
        XCTAssertNotNil(Bundle(for: Self.self))
    }
}
