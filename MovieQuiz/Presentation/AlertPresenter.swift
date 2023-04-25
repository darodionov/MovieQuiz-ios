import Foundation
import UIKit

class AlertPresenter: ShowScreenProtocol {
    weak var controller: UIViewController?
    
    init(controller: UIViewController? = nil) {
        self.controller = controller
    }
    
    func showScreen(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
        controller?.present(alert, animated: true)
    }
}
