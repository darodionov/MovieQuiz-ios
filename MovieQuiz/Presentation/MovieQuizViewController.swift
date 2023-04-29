import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var movieQuizPresenter: MovieQuizPresenter!
    private var alertPresenter: ShowScreenProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        movieQuizPresenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(controller: self)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        movieQuizPresenter.didAnswer(isYes: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        movieQuizPresenter.didAnswer(isYes: true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator () {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError (message: String) {
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
                self.movieQuizPresenter.restartGame()
            })
        alertPresenter?.showScreen(model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func enableButtons(_ enableButtons: Bool) {
        yesButton.isEnabled = enableButtons
        noButton.isEnabled = enableButtons
    }
}
