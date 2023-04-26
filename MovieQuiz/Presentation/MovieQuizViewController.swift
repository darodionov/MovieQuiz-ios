import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var currentQuestionNumber: Int = 0
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: ShowScreenProtocol?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        alertPresenter = AlertPresenter(controller: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        //showNextQuestionOrResults()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        self.currentQuestion = question
        let quizStepViewModel = convert(model: currentQuestion!)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: quizStepViewModel)
        }
    }
    
    func didLoadDataFromServer() {
        showNextQuestionOrResults()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        enableButtons(false)
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        enableButtons(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator () {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError (message: String) {
        hideLoadingIndicator()
        let title = "Ошибка"
        let message = ""
        let buttonText = "Попробовать ещё раз"
        let alertModel = AlertModel(title: title, message: message, buttonText: buttonText, completion: {})
        alertPresenter?.showScreen(model: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
           buttonText: result.buttonText,
            completion: {[weak self] in
                guard let self = self else {return}
                self.currentQuestionNumber = 0
                self.correctAnswers = 0
                self.showNextQuestionOrResults()
            })
        alertPresenter?.showScreen(model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.borderColor =  isCorrect
        ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor// задаем цвет
        
        currentQuestionNumber += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            self.enableButtons(true)
        }
    }
    
    private func showNextQuestionOrResults() {
        if (currentQuestionNumber == questionsAmount) {
            guard let statisticService = statisticService else {
                assertionFailure("statisticService is empty")
                return
            }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame
            let message = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount).
                            Количество сыгранных квизов: \(statisticService.gamesCount).
                            Рекорд: \(bestGame.correct)/\(bestGame.total)(\(bestGame.date.dateTimeString)).
                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy)).
                            """
            
            show(quiz: QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            )
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func enableButtons(_ enableButtons: Bool) {
        yesButton.isEnabled = enableButtons
        noButton.isEnabled = enableButtons
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionNumber + 1)/\(questionsAmount)")
    }
}
