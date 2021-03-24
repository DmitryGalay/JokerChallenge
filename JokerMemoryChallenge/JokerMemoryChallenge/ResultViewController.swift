//
//  ResultViewController.swift


import UIKit

protocol ResultViewControllerDelegate {
	//func resultViewControllerDidTapNext()
	func resultViewControllerDidTapRestart()
}

class ResultViewController: UIViewController {
    
    var delegate: ResultViewControllerDelegate?
    var gameResult = GameResult.veryBad
    var score = 0
    var time = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
       // scoreLabel.text = String(score)
      //  timeLabel.text = String(time)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let message = ""
        
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if let popoverPresentationController = activityVC.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = sender.frame
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        if let navigationVC = presentingViewController as? UINavigationController {
            for viewController in navigationVC.viewControllers {
                if let menuViewController = viewController as? ViewController {
                    navigationVC.popToViewController(menuViewController, animated: false)
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.delegate?.resultViewControllerDidTapRestart()
        
        
        //NotificationCenter.default.post(name: NSNotification.Name("RestartGame"), /object: nil)
    }
    
}
