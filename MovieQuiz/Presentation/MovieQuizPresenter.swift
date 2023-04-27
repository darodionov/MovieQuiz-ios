import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var currentQuestionNumber = 0
    private var statisticService = StatisticServiceImplementation()
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = (viewController as? MovieQuizViewController)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
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
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = (isYes == currentQuestion.correctAnswer)
        viewController?.enableButtons(false)
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    
    
    private func proceedToNextQuestionOrResults() {
        if (self.isLastQuestion()) {
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
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        switchToNextQuestion()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            self.viewController?.enableButtons(true)
        }
    }
    
    func restartGame() {
        currentQuestionNumber = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        proceedToNextQuestionOrResults()
    }
    
    // MARK: - QuestionFactoryDelegate
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
    
    func didLoadDataFromServer() {
        proceedToNextQuestionOrResults()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
