//  GameStorage.swift


import UIKit

struct DefaultConstant {
	static let deeplinkTimeout: Double = 2
	static let pushScreenTimeInterval: Double = 60 * 60 * 3
}

private struct ConfigurationSettingsStorageKey {
	
	static let userAccount = "kSettingUserAccount"
	static let userId = "kSettingUserId"
	static let agreements = "kSettingAgreements"
	static let organic = "kSettingOrganic"
	static let pushLocalization = "kSettingPushLocalization"
	static let pushScreenTimeInterval = "kSettingPushScreenTimeInterval"
	static let appsflyerConversionEnabled = "kSettingAppsFlyerConversionEnabled"
	
	static let appsflyerConversionData = "kSettingAppsflyerConversionData"
	static let afDeeplink = "afDeeplink"
	static let afDeeplinkType = "afDeeplinkType"
	static let fbDeeplink = "fbDeeplink"
	static let pushToken = "kSettingPushToken"
	static let deeplinkTimeout = "kSettingDeeplinkTimeout"
	static let appsflayerUserId = "kSettingAppsflayerUserId"
	
	static let pushNotificationsRegistered = "kSettingPushRegistered"
	
	static let pushSkippedTimestamp = "kSettingPushSkippedTimestamp"
	static let pushScreenEnabled = "kSettingPushScreenEnabled"
	
	static let pushTokenRegistered = "kSettingpushTokenRegistered"
	
	static let isFirstLaunch = "kSettingIsFirstLaunch"
}

class ConfigurationSettingsStorage: NSObject {
	
	static let appsFlayerDevKey = "BDREFvBLEZQKVYEhZafc85"
	static let amplitudeKey = "2dd2890637d34db4c56b70b143e75f73"
	
	static let shared = ConfigurationSettingsStorage()
	
	var agreements: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.agreements)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.agreements)
		}
	}
	
	var isOrganic: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.organic)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.organic)
		}
	}
	
	var pushLocalization: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushLocalization)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.pushLocalization)
		}
	}
		
	var hasAgreements: Bool {
		if let agreements = agreements, agreements.count > 0 {
			return true
		}
		return false
	}
	
	var hasDeeplink: Bool {
		if appsflyerConversionEnabled {
			if let deeplink = appsflyerDeeplink, deeplink.count > 0 {
				return true
			}
			if appsflyerDeeplinkType != nil {
				return true
			}
		}
		if let deeplink = facebookDeeplink, deeplink.count > 0 {
			return true
		}
		return false
	}
	
	var appsflyerConversionData: [AnyHashable : Any]? {
		set {
			let conversionData = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
			UserDefaults.standard.set(conversionData, forKey: ConfigurationSettingsStorageKey.appsflyerConversionData)
			UserDefaults.standard.synchronize()
		}
		get {
			if let data = UserDefaults.standard.data(forKey: ConfigurationSettingsStorageKey.appsflyerConversionData),
				let conversionData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable : Any]? {
				return conversionData
			}
			return nil
		}
	}
	
	var appsflyerDeeplink: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.afDeeplink)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.afDeeplink)
		}
	}
	
	var appsflyerDeeplinkType: DeeplinkOrganicType? {
		set {
			UserDefaults.standard.set(newValue?.rawValue, forKey: ConfigurationSettingsStorageKey.afDeeplinkType)
			UserDefaults.standard.synchronize()
		}
		get {
			if let type = UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.afDeeplinkType) {
				return DeeplinkOrganicType.init(rawValue: type)
			} else {
				return nil
			}
		}
	}
	
	var facebookDeeplink: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.fbDeeplink)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.fbDeeplink)
		}
	}
	
	var deepTimeout: Double {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.deeplinkTimeout)
			UserDefaults.standard.synchronize()
		}
		get {
			let timeout = UserDefaults.standard.double(forKey: ConfigurationSettingsStorageKey.deeplinkTimeout)
			return timeout > 0 ? timeout : DefaultConstant.deeplinkTimeout
		}
	}
	
	var userId: String? {
		set {
			if let newValue = newValue {
				Keychain.setPassword(newValue, forAccount: ConfigurationSettingsStorageKey.userAccount)
			}
		}
		get {
			return Keychain.password(forAccount: ConfigurationSettingsStorageKey.userAccount)
		}
	}
	
	var appsflyerId: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.appsflayerUserId)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.appsflayerUserId)
		}
	}
	
	var pushToken: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushToken)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: ConfigurationSettingsStorageKey.pushToken)
		}
	}
	
	var pushNotificationsRegistered: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushNotificationsRegistered)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.pushNotificationsRegistered)
		}
	}
	
	var pushSkippedTimestamp: TimeInterval? {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushSkippedTimestamp)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.double(forKey: ConfigurationSettingsStorageKey.pushSkippedTimestamp)
		}
	}
	
	var pushScreenTimeInterval: TimeInterval {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushScreenTimeInterval)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.double(forKey: ConfigurationSettingsStorageKey.pushScreenTimeInterval)
		}
	}
	
	var pushScreenEnabled: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushScreenEnabled)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.pushScreenEnabled)
		}
	}
	
	var pushTokenRegistered: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.pushTokenRegistered)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.pushTokenRegistered)
		}
	}
	
	var appsflyerConversionEnabled: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: ConfigurationSettingsStorageKey.appsflyerConversionEnabled)
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.appsflyerConversionEnabled)
		}
	}
	
	var isFirstLaunch: Bool {
		set {
			UserDefaults.standard.set(!newValue, forKey: ConfigurationSettingsStorageKey.isFirstLaunch)
			UserDefaults.standard.synchronize()
		}
		get {
			return !UserDefaults.standard.bool(forKey: ConfigurationSettingsStorageKey.isFirstLaunch)
		}
	}
	
}
