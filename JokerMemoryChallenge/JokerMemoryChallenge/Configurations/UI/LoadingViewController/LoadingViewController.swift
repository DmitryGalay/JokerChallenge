//
//  LoadingHUD.swift
//  PhoenixPuzzle
//
//  Created by Artsiom Likhatch Admin on 3/14/20.
//

import UIKit

@objc class LoadingViewController: UIViewController {

	@IBOutlet weak var loadingView: LoadingView!
	
//	static var loadingWindow: UIWindow?
	
	@objc var text: String = "" {
		didSet {
			update()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
		loadingView.startAnimating()
    }
	
	private func update() {
		if let loadingView = loadingView {
			loadingView.progressLabel.text = text
		}
	}

//	@objc static func showHUD() -> LoadingViewController {
//		let loadingHUD = LoadingViewController()
//		show(vc: loadingHUD)
//		return loadingHUD
//	}
	
	
//	@objc  static  func hideHUD() {
//		loadingWindow = nil
//	}
	
//	private static func show(vc: UIViewController) {
//		let window = UIWindow.init()
//		window.backgroundColor = UIColor.red
//		window.rootViewController = vc
//		let level = UIWindow.Level.alert.rawValue + 1
//		window.windowLevel = UIWindow.Level.init(level)
//		window.makeKeyAndVisible()
//		
//		loadingWindow = window
//	}
}
