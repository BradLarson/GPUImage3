import XCTest

@testable import GPUImage

final class MatrixTests: XCTestCase {
    func testMatrix3x3() throws {
        let newMatrix = Matrix3x3(rowMajorValues: [
            1.0, 2.0, 3.0,
            4.0, 5.0, 6.0,
            7.0, 8.0, 9.0,
        ])

        XCTAssertEqual(newMatrix.m11, 1.0)
        XCTAssertEqual(newMatrix.m23, 6.0)
        XCTAssertEqual(newMatrix.m32, 8.0)
    }
}
