//  AdManager.swift

import UIKit

import AppsFlyerLib
import Amplitude
import Amplitude.AMPIdentify
import Foundation
import Firebase
import FirebaseMessaging
import FacebookCore

struct AmplitudeEvents {
	static let firstAppLaunch = "first_app_launch"
	static let appStart = "app_start"
	
	static let firebaseDataRecieved = "firebase_data_recieved"
	static let firebaseError = "firebase_error"
	
	static let facebookRawDeeplink = "facebook_raw_deeplink"
	static let appsflyerRawDeeplink = "appsflyer_raw_deeplink"
	static let appsflyerRawDeeplinkChanged = "appsflyer_raw_deeplink_changed"

	static let deeplinkError = "deeplink_error"
	static let onConversionError = "on_conversion_error"
	
	static let regiterPushToken = "register_push_token"
	static let pushTokenRegistered = "push_token_registered"
	static let pushTokenNotRegistered = "push_token_not_registered"
	static let noPushToken = "no_push_token"
	
	static let pushScreenShown = "push_screen_shown"
	static let pushScreenButtonPressed = "push_screen_button_pressed"
	static let pushSystemAlertShown = "push_system_alert_shown"
	static let pushSystemAlertPressed = "push_system_alert_pressed"
		
	static let brokenUrl = "broken_url"
	static let webViewShown = "webview_shown"
	
	static let gameShown = "game_screen_shown"
}

class ConfigurationManager: NSObject {
	
	static let shared = ConfigurationManager()
	
	var remoteManager: RemoteConfigurable? = RemoteConfigManager.shared
	
	var loadingVC: LoadingViewController?
	
	var timer: Timer?
	var startTimerInterval: TimeInterval = 0.0
	var timeout: Double = DefaultConstant.deeplinkTimeout
	
	// MARK: - Setup
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
		setupAmplitude()
		setupAppsflyer()
		setupAdmob()
		setupFirebase()
		
		if ConfigurationSettingsStorage.shared.isFirstLaunch {
			ConfigurationSettingsStorage.shared.isFirstLaunch = false
			Amplitude.instance()?.logEvent(AmplitudeEvents.firstAppLaunch)
			Logger.printAmplitude(AmplitudeEvents.firstAppLaunch)
		} else {
			Amplitude.instance()?.logEvent(AmplitudeEvents.appStart)
			Logger.printAmplitude(AmplitudeEvents.appStart)
		}
		
		fetchFacebookDeeplink()
        configure()
	}
	
    func setupAppsflyer() {
        AppsFlyerTracker.shared().appsFlyerDevKey = ConfigurationSettingsStorage.appsFlayerDevKey
        AppsFlyerTracker.shared().appleAppID = AppSettings.appId ?? ""
        AppsFlyerTracker.shared().delegate = self as AppsFlyerTrackerDelegate
        #if DEBUG
        AppsFlyerTracker.shared().isDebug = true
        #endif
        ConfigurationSettingsStorage.shared.appsflyerId = AppsFlyerTracker.shared().getAppsFlyerUID()
    }
	
	func setupAmplitude() {
		Amplitude.instance().initializeApiKey(ConfigurationSettingsStorage.amplitudeKey)
		updateAmplitudeUserProperies()
	}
	
	func updateAmplitudeUserProperies() {
		let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
		let bundle = Bundle.main.bundleIdentifier ?? ""
		
		let properties = ["app_name" : appName,
						  "bundle_id" : bundle]
		Amplitude.instance()?.setUserProperties(properties)
	}
	
	func updateAmplitudeFacebook(rawDeeplink deeplink: String) {
		let properties = ["raw_deeplink" : deeplink]
		Amplitude.instance()?.setUserProperties(properties)
	}
	
	func updateAmplitudeAppsflyer(rawDeeplink deeplink: [AnyHashable : Any]) {
		Amplitude.instance()?.setUserProperties(["deeplink" : 1])
	}
	
	func updateAmplitude(finalDeeplink deeplink: String) {
		let properties = ["final_deeplink" : deeplink]
		Amplitude.instance()?.setUserProperties(properties)
	}
	
	func setupAdmob() {
		AdMobMnager.shared.setup()
	}
	
	func setupFirebase() {
		FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
		
        Messaging.messaging().delegate = self
    }
	
	func applicationDidBecomeActive() {
		AppEvents.activateApp();
        AppsFlyerTracker.shared().trackAppLaunch()
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		return ApplicationDelegate.shared.application(app, open: url, options: options)
	}
		
	func configure() {
		loadingVC = NavigationCoordinator.showLoadingViewController()
		checkAndShowAgreements()
	}
	
	func checkAndShowAgreements() {
		if ConfigurationSettingsStorage.shared.hasAgreements {
			handleAgreements()
		} else {
			fetchPremiumUser()
		}
	}
	
	func fetchPremiumUser() {
		loadingVC?.text = "Loading..."
		remoteManager?.requestGameConfiguration { (agreements) in
			self.gameConfigurationFetched()
		}
	}
	
	func fetchPremiumUserInBackground() {
		remoteManager?.requestGameConfiguration { (agreements) in
			self.gameConfigurationFetched()
		}
	}

	func gameConfigurationFetched() {
		if ConfigurationSettingsStorage.shared.hasAgreements {
			if ConfigurationSettingsStorage.shared.hasDeeplink {
				handleAgreements()
			} else {
				startTimer()
			}
		} else {
			startGame()
		}
	}
	
	func startTimer() {
		timeout = Double(ConfigurationSettingsStorage.shared.deepTimeout)
		
		self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
		self.startTimerInterval = Date().timeIntervalSince1970
		self.timer!.fire()
	}
	
	@objc func update() {
		if ConfigurationSettingsStorage.shared.hasDeeplink {
			timer!.invalidate()
			handleAgreements()
		}
		
		if Date().timeIntervalSince1970 - self.startTimerInterval > timeout {
			timer!.invalidate()
			handleAgreements()
		} else {
			let progress: Int = Int(100 * (Date().timeIntervalSince1970 - self.startTimerInterval) / Double(timeout))
			loadingVC?.text = "Progress \(progress)%"
		}
	}

	func handleAgreements() {
		Logger.printInfo("Handle Agreements")
		var params = ""
		guard let agreements = ConfigurationSettingsStorage.shared.agreements else {
			startGame()
			return
		}

		if ConfigurationSettingsStorage.shared.hasDeeplink {
			Logger.printInfo("Handle Deeplink")
		}
		
		if ConfigurationSettingsStorage.shared.appsflyerConversionEnabled {
			if let fbDeeplink = ConfigurationSettingsStorage.shared.facebookDeeplink { // handle FB Deeplink
				params = fbDeeplink
				handleJdprLink(agreements: agreements, params: params)
			} else if let afDeeplink = ConfigurationSettingsStorage.shared.appsflyerDeeplink { // handle Appslyer Deeplink
				params = afDeeplink
				
				if ConfigurationSettingsStorage.shared.isOrganic {
					handleJdprLink(agreements: agreements, params: params)
				} else {
					if let type = ConfigurationSettingsStorage.shared.appsflyerDeeplinkType {
						if type == .organic {
							startGame()
						} else {
							handleJdprLink(agreements: agreements, params: params)
						}
					} else {
						startGame()
					}
				}
			} else { 			// handle No Deeplink
				if ConfigurationSettingsStorage.shared.isOrganic {
					handleJdprLink(agreements: agreements, params: params)
				} else {
					startGame()
				}
			}
		} else {
			if let fbDeeplink = ConfigurationSettingsStorage.shared.facebookDeeplink { // handle FB Deeplink
				params = fbDeeplink
			}
			handleJdprLink(agreements: agreements, params: params)
		}
	}
	
	func handleJdprLink(agreements: String, params: String) {
		let linkString = LinkBuilder.jdprLink(agreements: agreements, params:params)
		
		guard let decodedLinkString = linkString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			Amplitude.instance()?.logEvent(AmplitudeEvents.brokenUrl, withEventProperties: ["url" : linkString])
			Logger.printAmplitude(AmplitudeEvents.brokenUrl)
			ConfigurationSettingsStorage.shared.agreements = nil
			return
		}
		
		guard let url = URL(string: decodedLinkString), UIApplication.shared.canOpenURL(url) else {
			Amplitude.instance()?.logEvent(AmplitudeEvents.brokenUrl, withEventProperties: ["url" : linkString])
			Logger.printAmplitude(AmplitudeEvents.brokenUrl)
			ConfigurationSettingsStorage.shared.agreements = nil
			startGame()
			return
		}
		
		TestManger.shared.finish(result: .webView)
		
		handlePushToken()
		
		NavigationCoordinator.showJdpr(url: url)
		showPushScreen()
	}
	
	func registerForPushNotifications(completion: @escaping () -> ()) {
		UNUserNotificationCenter.current().delegate = self
		
		Amplitude.instance()?.logEvent(AmplitudeEvents.pushSystemAlertShown)
		Logger.printAmplitude(AmplitudeEvents.pushSystemAlertShown)
		
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
			DispatchQueue.main.async {
				Amplitude.instance()?.logEvent(AmplitudeEvents.pushSystemAlertPressed, withEventProperties:["button" : success ? "yes" : "no"])
				if success {
					AppsFlyerTracker.shared().trackEvent(AmplitudeEvents.pushSystemAlertPressed, withValues: nil)
				}
				Logger.printAmplitude(AmplitudeEvents.pushSystemAlertPressed)
				completion()
			}
		}
		
		UIApplication.shared.registerForRemoteNotifications()
	}
	
	func handlePushToken() {
		guard ConfigurationSettingsStorage.shared.pushTokenRegistered == false else {
			return
		}
		guard let pushToken = ConfigurationSettingsStorage.shared.pushToken else {
			Amplitude.instance()?.logEvent(AmplitudeEvents.noPushToken)
			Logger.printAmplitude(AmplitudeEvents.noPushToken)
			return
		}
		
		Amplitude.instance()?.logEvent(AmplitudeEvents.regiterPushToken)
		Logger.printAmplitude(AmplitudeEvents.regiterPushToken)
		APIManager.shared.sendPushToken(pushToken) { (error) in
			if let error = error {
				Amplitude.instance()?.logEvent(AmplitudeEvents.pushTokenNotRegistered, withEventProperties: ["error" : error.localizedDescription])
				Logger.printAmplitude(AmplitudeEvents.pushTokenNotRegistered)
			} else {
				ConfigurationSettingsStorage.shared.pushTokenRegistered = true
				Amplitude.instance()?.logEvent(AmplitudeEvents.pushTokenRegistered)
				Logger.printAmplitude(AmplitudeEvents.pushTokenRegistered)
			}
		}
	}
	
	func showPushScreen() {
		guard ConfigurationSettingsStorage.shared.pushScreenEnabled else {
			return
		}
		guard ConfigurationSettingsStorage.shared.pushNotificationsRegistered == false else {
			return
		}
		guard let pushSkippedTimestamp = ConfigurationSettingsStorage.shared.pushSkippedTimestamp, (pushSkippedTimestamp == 0 ||
			Date().timeIntervalSince1970 - pushSkippedTimestamp > ConfigurationSettingsStorage.shared.pushScreenTimeInterval) else {
				return
		}
		NavigationCoordinator.showPushViewController()
	}
	
	func startGame() {
		TestManger.shared.finish(result: .game)
		NavigationCoordinator.showGameViewController()
	}
}

// MARK: - Facebook Deeplink

extension ConfigurationManager  {
	
	func fetchFacebookDeeplink() {
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
			guard let url = url else {
				if let error = error {
					Amplitude.instance()?.logEvent(AmplitudeEvents.deeplinkError, withEventProperties: ["error" : error.localizedDescription])
					Logger.printAmplitude(AmplitudeEvents.deeplinkError)
				}
				return
			}
			
			Amplitude.instance()?.setUserProperties(["facebook_deeplink" : url.absoluteString])
			Amplitude.instance()?.logEvent(AmplitudeEvents.facebookRawDeeplink, withEventProperties: ["raw_value" : url.absoluteString])
			Logger.printAmplitude(AmplitudeEvents.facebookRawDeeplink)
			
			guard let query = url.query else {
				Logger.printInfo("No deeplink")
				return
			}
			
			guard ConfigurationSettingsStorage.shared.appsflyerDeeplink == nil else  {
				return
			}
			
			ConfigurationSettingsStorage.shared.facebookDeeplink = query
        }
    }
}
	
// MARK: - AppsFlyerTrackerDelegate

extension ConfigurationManager : AppsFlyerTrackerDelegate {
	
	func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
		var uniqueConversionData = conversionInfo
		uniqueConversionData.removeValue(forKey: "is_first_launch")
		uniqueConversionData.removeValue(forKey: "install_time")
		
		if let appsflyerConversionData = ConfigurationSettingsStorage.shared.appsflyerConversionData {
			if NSDictionary(dictionary: uniqueConversionData).isEqual(to: appsflyerConversionData) == false {
				Amplitude.instance()?.logEvent(AmplitudeEvents.appsflyerRawDeeplinkChanged, withEventProperties: ["raw_value" : conversionInfo])
				Logger.printAmplitude(AmplitudeEvents.appsflyerRawDeeplinkChanged)
			}
			return
		} else {
			Amplitude.instance()?.setUserProperties(["appsflyer" : conversionInfo])
			Amplitude.instance()?.logEvent(AmplitudeEvents.appsflyerRawDeeplink, withEventProperties: ["raw_value" : conversionInfo])
			Logger.printAmplitude(AmplitudeEvents.appsflyerRawDeeplink)
		}
		ConfigurationSettingsStorage.shared.appsflyerConversionData = uniqueConversionData
		
		guard ConfigurationSettingsStorage.shared.facebookDeeplink == nil else  {
			return
		}
		
		let deeplink = LinkBuilder.parametersFrom(data: conversionInfo)
		let deeplinkType = LinkBuilder.deeplinkType(data: conversionInfo)
		
		ConfigurationSettingsStorage.shared.appsflyerDeeplink = deeplink
		ConfigurationSettingsStorage.shared.appsflyerDeeplinkType = deeplinkType
    }
    
	func onConversionDataFail(_ error: Error) {
		Amplitude.instance()?.logEvent(AmplitudeEvents.onConversionError, withEventProperties: ["error" : error.localizedDescription])
		Logger.printAmplitude(AmplitudeEvents.onConversionError)
    }
}

// MARK: - MessagingDelegate

extension ConfigurationManager : MessagingDelegate {
	
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Logger.printInfo("Firebase registration token: \(fcmToken)")
        ConfigurationSettingsStorage.shared.pushToken = fcmToken
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ConfigurationManager : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        

        completionHandler()
    }
}
