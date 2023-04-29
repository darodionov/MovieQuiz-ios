import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    // Given
    let arr = [1, 2, 3]
    
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        
        // When
        let result = arr[safe: 1]
        
        // Then
        XCTAssertEqual(result, 2)
    }
    
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        // When
        let result = arr[safe: 3]
        
        // Then
        XCTAssertNil(result)
    }
}
