//
//  PurchaseViewController.swift


import UIKit

class PurchaseViewController: UIViewController {

    @IBOutlet weak var purchaseButton: UIButton!
    
    var gameSettingsIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

