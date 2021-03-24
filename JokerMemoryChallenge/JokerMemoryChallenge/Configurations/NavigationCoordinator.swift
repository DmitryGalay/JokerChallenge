//
//  NavigationCoordinator.swift

import UIKit
import Amplitude
import AppsFlyerLib
import FBSDKCoreKit

struct ViewControllerRestorationIdentifier {
	static let jdpr = "jdpr"
	static let game = "game"
	static let loading = "loading"
}

class NavigationCoordinator: NSObject {

	static var pushViewController: UIViewController?
	
	static func showLoadingViewController() -> LoadingViewController {
		Logger.printInfo("Show Loading Screen")
		let loadingVC = LoadingViewController(nibName: "LoadingViewController", bundle: nil)
		let navVC = UINavigationController(rootViewController: loadingVC)
		navVC.navigationBar.isHidden = true
		navVC.restorationIdentifier = ViewControllerRestorationIdentifier.loading
		UIApplication.showRoot(vc: navVC)
		return loadingVC
	}
	
	static func showGameViewController() {
		Amplitude.instance()?.logEvent(AmplitudeEvents.gameShown)
		AppsFlyerTracker.shared().trackEvent(AmplitudeEvents.gameShown, withValues: nil)
		Logger.printAmplitude(AmplitudeEvents.gameShown)
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController")
		let navVC = UINavigationController(rootViewController: vc)
		navVC.navigationBar.isHidden = true
		navVC.restorationIdentifier = ViewControllerRestorationIdentifier.game
		UIApplication.showRoot(vc: navVC)
		UIDevice.rotateToDefaultOrientation()
	}
	
	static func showJdpr(url: URL) {
		Amplitude.instance()?.setUserProperties(["url" : url.absoluteString])
		Amplitude.instance()?.logEvent(AmplitudeEvents.webViewShown, withEventProperties: ["url" : url.absoluteString])
		AppsFlyerTracker.shared().trackEvent(AmplitudeEvents.webViewShown, withValues: nil)
		Logger.printAmplitude(AmplitudeEvents.webViewShown)
		
		UIApplication.showRoot(vc: UIViewController())
		ApplicationDelegate.shared.openJdprAgreementsController(url)
	}
	
	static func showPushViewController() {
		Amplitude.instance()?.logEvent(AmplitudeEvents.pushScreenShown)
		Logger.printAmplitude(AmplitudeEvents.pushScreenShown)
		
		let pushVC = PushViewController()
		NavigationCoordinator.pushViewController = pushVC
		UIApplication.showOnTop(vc: pushVC)
	}
	
	static func hidePushViewController() {
		guard let pushViewController = NavigationCoordinator.pushViewController else {
			return
		}
		pushViewController.dismiss(animated: true) {
			NavigationCoordinator.pushViewController = nil
		}
	}
	
	static private var defaultSupportedInterfaceOrientations: UIInterfaceOrientationMask {
		switch AppSettings.orientation {
		case .portrait:
			return [.portrait]
		case .landsacape:
			return [.landscapeLeft, .landscapeRight]
		}
	}
	
	static var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		guard let appDelegate = UIApplication.shared.delegate else {
			return .portrait
		}
		
		guard let window = appDelegate.window else {
			return .portrait
		}
		
		guard let rootViewController = window?.rootViewController else {
			return .portrait
		}
		
		if rootViewController.restorationIdentifier == ViewControllerRestorationIdentifier.loading {
			return .portrait
		} else if rootViewController.restorationIdentifier == ViewControllerRestorationIdentifier.game {
			return defaultSupportedInterfaceOrientations
		}
		
		return .all
	}
}

extension UIApplication {
	
	static func showRoot(vc: UIViewController?) {
		guard let application = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		let frame = UIScreen.main.bounds
		let window = UIWindow(frame: frame)
		window.rootViewController = vc
		
		application.window = window
		window.makeKeyAndVisible()
	}
	
	static func showOnTop(vc: UIViewController) {
		guard let application = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		guard let rootViewController = application.window?.rootViewController else {
			return
		}
		vc.modalPresentationStyle = .overCurrentContext
		rootViewController.present(vc, animated: true, completion: nil)
	}
	
	static func rootViewController() -> UIViewController? {
		guard let application = UIApplication.shared.delegate as? AppDelegate,
			let window = application.window,
			let rootVC = window.rootViewController else {
			return nil
		}
		return rootVC
	}
}

extension UIDevice {
	
	static func rotateToDefaultOrientation() {
		var orientation = UIInterfaceOrientation.portrait
		switch AppSettings.orientation {
		case .portrait:
			orientation = .portrait
		case .landsacape:
			orientation = .landscapeLeft
		}
		UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
		UIViewController.attemptRotationToDeviceOrientation()
	}
	
	static func rotateToPortraiteOrientation() {
		let orientation = UIInterfaceOrientation.portrait
		UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
		UIViewController.attemptRotationToDeviceOrientation()
	}
	
}
