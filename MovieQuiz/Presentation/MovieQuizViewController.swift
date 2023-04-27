import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let movieQuizPresenter = MovieQuizPresenter()
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: ShowScreenProtocol?
    //private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let moviesLoader = MoviesLoader()
        movieQuizPresenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        movieQuizPresenter.questionFactory = questionFactory
        alertPresenter = AlertPresenter(controller: self)
        //statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        movieQuizPresenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        movieQuizPresenter.showNextQuestionOrResults()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        movieQuizPresenter.noButtonClicked()
    }
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        movieQuizPresenter.yesButtonClicked()
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
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
           buttonText: result.buttonText,
            completion: {[weak self] in
                guard let self = self else {return}
                self.movieQuizPresenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.movieQuizPresenter.correctAnswers = self.correctAnswers
                self.movieQuizPresenter.showNextQuestionOrResults()
            })
        alertPresenter?.showScreen(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.borderColor =  isCorrect
        ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor// задаем цвет
        
        movieQuizPresenter.switchToNextQuestion()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.movieQuizPresenter.correctAnswers = self.correctAnswers
            self.movieQuizPresenter.showNextQuestionOrResults()
            self.enableButtons(true)
        }
    }
    
//    private func showNextQuestionOrResults() {
//        if (movieQuizPresenter.isLastQuestion()) {
//            guard let statisticService = statisticService else {
//                assertionFailure("statisticService is empty")
//                return
//            }
//            statisticService.store(correct: correctAnswers, total: movieQuizPresenter.questionsAmount)
//            let bestGame = statisticService.bestGame
//            let message = """
//                            Ваш результат: \(correctAnswers)/\(movieQuizPresenter.questionsAmount).
//                            Количество сыгранных квизов: \(statisticService.gamesCount).
//                            Рекорд: \(bestGame.correct)/\(bestGame.total)(\(bestGame.date.dateTimeString)).
//                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy)).
//                            """
//
//            show(quiz: QuizResultViewModel(
//                title: "Этот раунд окончен!",
//                text: message,
//                buttonText: "Сыграть еще раз")
//            )
//        } else {
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
    func enableButtons(_ enableButtons: Bool) {
        yesButton.isEnabled = enableButtons
        noButton.isEnabled = enableButtons
    }
}
