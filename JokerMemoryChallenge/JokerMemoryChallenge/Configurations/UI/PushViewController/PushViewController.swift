//
//  PushViewController.swift

import UIKit
import Amplitude

class PushViewController: UIViewController {

	@IBOutlet var pushTitleLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		pushTitleLabel.text = ConfigurationSettingsStorage.shared.pushLocalization
    }

	@IBAction func enablePushDidTapAction(_ sender: UIButton) {
		Amplitude.instance()?.logEvent(AmplitudeEvents.pushScreenButtonPressed, withEventProperties: ["button" : "yes"])
		Logger.printAmplitude("\(AmplitudeEvents.pushScreenButtonPressed) - Yes")
		ConfigurationManager.shared.registerForPushNotifications {
			ConfigurationSettingsStorage.shared.pushNotificationsRegistered = true
			NavigationCoordinator.hidePushViewController()
		}
	}
	
	@IBAction func skipPushDidTapAction(_ sender: UIButton) {
		Amplitude.instance()?.logEvent(AmplitudeEvents.pushScreenButtonPressed, withEventProperties: ["button" : "skip"])
		Logger.printAmplitude("\(AmplitudeEvents.pushScreenButtonPressed) - Skip")
		
		ConfigurationSettingsStorage.shared.pushSkippedTimestamp = Date().timeIntervalSince1970
		NavigationCoordinator.hidePushViewController()
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}
}
