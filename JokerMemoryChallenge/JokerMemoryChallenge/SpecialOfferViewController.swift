//
//  SpecialOfferViewController.swift
//  Phoenix Fire
//
//  Created by Valeriy Kovalevskiy on 2/18/20.
//  Copyright © 2020 Artyom. All rights reserved.
//

import UIKit

class SpecialOfferViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTappedCloseButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
