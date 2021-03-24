//
//  LoseViewController.swift
//  LepreconIsha
//
//  Created by Dima on 4/15/20.
//
protocol LooseViewControllerDelegate: class {
    func looseViewControllerDidDismiss()
    func restartButton()
}
import UIKit

class LooseViewController: UIViewController {
    weak var delegate: LooseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func gesturerecognozerDidTapp(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true) {
            self.delegate?.looseViewControllerDidDismiss()
        }
    }
    @IBAction func restartButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.delegate?.restartButton()
        
        NotificationCenter.default.post(name: NSNotification.Name("RestartGame"), object: nil)
    }
    
  
}
