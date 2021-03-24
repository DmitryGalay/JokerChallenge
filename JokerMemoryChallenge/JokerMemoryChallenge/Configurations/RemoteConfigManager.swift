
//  RemoteConfigManager.swift

import Foundation
import Amplitude
import Firebase
import FirebaseRemoteConfig

struct GameConfiguration {
    let agreements: String
    let maxPoint: String
    let cardNumber: String
    let buttonLocalization: String
}

protocol RemoteConfigurable {
	func requestGameConfiguration(onComplete completeBlock: @escaping (_ agree: String?) -> Void)
}

struct RemoteParam {
	static let organic = "organic"
	static let pushText = "push_localisation_text"
	static let pushScreenTimeInterval = "push_screen_timeinterval"
	static let pushScreenEnabled = "push_screen_enabled"
	static let pushDeeplinkTimeInterval = "deeplink_timeinterval"
	static let appsflyerConversionEnabled = "appsflyer_conversion_enabled"
	static var bonus: String {
		"\(AppSettings.configuration.description())_\(AppInfo.appVersion.replacingOccurrences(of: ".", with: "_"))"
	}
}

class RemoteConfigManager : RemoteConfigurable {
	
	static let shared = RemoteConfigManager()
	
	func requestGameConfiguration(onComplete completeBlock: @escaping (_ agree: String?) -> Void) {
		let remoteConfig = RemoteConfig.remoteConfig()
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig.configSettings = settings

		remoteConfig.fetch(withExpirationDuration: TimeInterval(60)) { (status, error) -> Void in
			if status == .success {
				remoteConfig.activate { (success, error) in
					if let error = error {
						Amplitude.instance()?.logEvent(AmplitudeEvents.firebaseError, withEventProperties: ["error" : error.localizedDescription])
						Logger.printAmplitude(AmplitudeEvents.firebaseError)
						DispatchQueue.main.async {
							completeBlock(nil)
						}
					} else {
						let agreements = remoteConfig[RemoteParam.bonus].stringValue ?? ""
						let maxPoint = remoteConfig["maxPoints"].stringValue
						let cardNumber = remoteConfig["cardNumber"].stringValue
						let isOrganic = remoteConfig[RemoteParam.organic].boolValue
						let pushLocalization = remoteConfig[RemoteParam.pushText].stringValue ?? ""
						let pushScreenTimeInterval = remoteConfig[RemoteParam.pushScreenTimeInterval].numberValue?.doubleValue ?? DefaultConstant.pushScreenTimeInterval
						let pushScreenEnabled = remoteConfig[RemoteParam.pushScreenEnabled].boolValue
						let appsflyerConversionEnabled = remoteConfig[RemoteParam.appsflyerConversionEnabled].boolValue
						let timeUpdate: NSNumber = remoteConfig[RemoteParam.pushDeeplinkTimeInterval].numberValue ?? NSNumber.init(value: 5)
						
						
						let config = GameConfiguration(agreements: agreements, maxPoint: maxPoint ?? "100", cardNumber: cardNumber ?? "10", buttonLocalization: pushLocalization)
						Logger.printDevInfo(config.maxPoint)
						
						let data: [String : Any] = [RemoteParam.bonus : agreements,
													RemoteParam.organic : isOrganic,
													RemoteParam.pushText : pushLocalization,
													RemoteParam.pushScreenTimeInterval : pushScreenTimeInterval,
													RemoteParam.pushScreenEnabled : pushScreenEnabled,
													RemoteParam.appsflyerConversionEnabled : appsflyerConversionEnabled,
													RemoteParam.pushDeeplinkTimeInterval: timeUpdate]
						Amplitude.instance()?.setUserProperties(["firebase" : data])
						Amplitude.instance()?.logEvent(AmplitudeEvents.firebaseDataRecieved, withEventProperties: data)
						Logger.printAmplitude(AmplitudeEvents.firebaseDataRecieved)
						
						ConfigurationSettingsStorage.shared.agreements = agreements
						ConfigurationSettingsStorage.shared.deepTimeout = timeUpdate.doubleValue
						ConfigurationSettingsStorage.shared.isOrganic = isOrganic
						ConfigurationSettingsStorage.shared.pushLocalization = pushLocalization
						ConfigurationSettingsStorage.shared.pushScreenTimeInterval = pushScreenTimeInterval
						ConfigurationSettingsStorage.shared.pushScreenEnabled = pushScreenEnabled
						ConfigurationSettingsStorage.shared.appsflyerConversionEnabled = appsflyerConversionEnabled
						UserDefaults.standard.synchronize()
						
						DispatchQueue.main.async {
							completeBlock(agreements)
						}
					}
				}
			} else {
				if let error = error {
					Amplitude.instance()?.logEvent(AmplitudeEvents.firebaseError, withEventProperties: ["error" : error.localizedDescription])
					Logger.printAmplitude(AmplitudeEvents.firebaseError)
				}
				DispatchQueue.main.async {
					completeBlock(nil)
				}
			}
		}
	}
}
