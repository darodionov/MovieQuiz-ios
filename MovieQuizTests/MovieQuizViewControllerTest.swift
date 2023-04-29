import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerTest: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let data = Data()
        let questionText = "Test Question Text"
        let question = QuizQuestion(
            image: data,
            text: questionText,
            correctAnswer: true)
        
        //When
        let viewModel = sut.convert(model: question)
        
        //Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, questionText)
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
