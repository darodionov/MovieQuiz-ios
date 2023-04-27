import UIKit

final class MovieQuizPresenter {
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var currentQuestionNumber = 0
    private var statisticService = StatisticServiceImplementation()
    
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
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
    
    //TODO: убрать
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = (isYes == currentQuestion.correctAnswer)
        viewController?.enableButtons(false)
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        self.currentQuestion = question
        let quizStepViewModel = convert(model: currentQuestion!)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: quizStepViewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if (self.isLastQuestion()) {
//            guard let statisticService = statisticService else {
//                assertionFailure("statisticService is empty")
//                return
//            }
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let bestGame = statisticService.bestGame
            let message = """
                            Ваш результат: \(correctAnswers)/\(self.questionsAmount).
                            Количество сыгранных квизов: \(statisticService.gamesCount).
                            Рекорд: \(bestGame.correct)/\(bestGame.total)(\(bestGame.date.dateTimeString)).
                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy)).
                            """
            
            viewController?.show(quiz: QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            )
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
}
