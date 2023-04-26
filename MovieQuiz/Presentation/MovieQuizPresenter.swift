import UIKit

final class MovieQuizPresenter {
    let questionsAmount = 10
    private var currentQuestionNumber = 0
    
    func isLastQuestion() -> Bool{
        return currentQuestionNumber == questionsAmount
    }
    
    func resetQuestionIndex() {
        currentQuestionNumber = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionNumber += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionNumber + 1)/\(questionsAmount)")
    }
}
