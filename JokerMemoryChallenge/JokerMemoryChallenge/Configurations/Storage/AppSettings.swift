//
//  AppSettings.swift

import Foundation

enum Orientation: Int {
	case portrait = 0
	case landsacape = 1
	
	func description() -> String {
		switch self {
		case .portrait:
			return "portrait"
		case .landsacape:
			return "landsacape"
		}
	}
}

enum ConfigurationType: Int {
	case free = 0
	case hd = 1
	
	func description() -> String {
		switch self {
		case .free:
			return "free"
		case .hd:
			return "hd"
		}
	}
}

enum InfoPlistKey {
	static let isHD = "HD" //Bool
	static let orientation = "Orientation" //NSnumber 0 - Portraite, 1 - Landscape
	static let appId = "AppIdentifier" //String
	static let admobAppId = "GADApplicationIdentifier" //String
	static let admobBannerId = "GADBannerIdentifier" //String
	static let leaderboardId = "LeaderboardIdentifier" //String
	static let targetName = "TargetName" // value $(TARGET_NAME)
}

struct AppSettings {
	
	static let version = "2.4.1"
	static let isDebug = false // true - check admob banner
	
	private static var infoDict: [String: Any] {
		if let dict = Bundle.main.infoDictionary {
			return dict
		} else {
			fatalError("Info Plist file not found")
		}
	}
	
	static let targetName = infoDict[InfoPlistKey.targetName] as? String
	static let appId = infoDict[InfoPlistKey.appId] as? String
	static let admobAppId = infoDict[InfoPlistKey.admobAppId] as? String
	static let admobBannerId = infoDict[InfoPlistKey.admobBannerId] as? String
	static let leaderboardId = infoDict[InfoPlistKey.leaderboardId] as? String
	static var configuration: ConfigurationType {
		if let value = infoDict[InfoPlistKey.isHD] as? Bool {
			return ConfigurationType(rawValue: value ? 1 : 0) ?? .free
		}
		return .free
	}
	static var orientation: Orientation  {
		if let value = infoDict[InfoPlistKey.orientation] as? NSNumber {
			return Orientation(rawValue: value.intValue) ?? .portrait
		}
		return .portrait
	}
	
	static let hdValue = infoDict[InfoPlistKey.isHD] as? Bool
	static let orientationValue = infoDict[InfoPlistKey.orientation] as? NSNumber
	
	
	static let facebookId = infoDict["FacebookAppID"] as? String
	static let faceBookDisplayName = infoDict["FacebookDisplayName"] as? String
	
	static func urlsSchemeName() -> String? {
		guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
		let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
		let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
		let externalURLScheme = urlSchemes.first as? String else { return nil }
		return externalURLScheme
	}
	static func urlSchemeId() -> String? {
		guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
			let urlValueDictionary = urlTypes.last as? [String: AnyObject],
			let urlSchemeId = urlValueDictionary["CFBundleURLName"] as? String else { return nil }
		return urlSchemeId
	}
	
	static func urlScheme() -> String? {
		guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
			let urlValueDictionary = urlTypes.last as? [String: AnyObject],
			let urlSchemeValues = urlValueDictionary["CFBundleURLSchemes"] as? [AnyObject],
			let urlSchemeValue = urlSchemeValues.first as? String else { return nil }
		return urlSchemeValue
	}
	
	static func externalURLScheme() -> String? {
		guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
			let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
			let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
			let externalURLScheme = urlSchemes.first as? String else { return nil }
		
		guard let urlValueDictionary = urlTypes.last as? [String: AnyObject],
			let urlSchemeName = urlValueDictionary["CFBundleURLName"] as? String,
			let urlSchemeValues = urlValueDictionary["CFBundleURLSchemes"] as? [AnyObject],
			let urlSchemeValue = urlSchemeValues.first as? String
			else {
			return nil
		}

		return "\(externalURLScheme): \(urlSchemeName) - \(urlSchemeValue)"
	}
	
	static func getHighResolutionAppIconName() -> String? {
		guard let infoPlist = Bundle.main.infoDictionary else { return nil }
		guard let bundleIcons = infoPlist["CFBundleIcons"] as? NSDictionary else { return nil }
		guard let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary else { return nil }
		guard let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? NSArray else { return nil }
		guard let appIcon = bundleIconFiles.lastObject as? String else { return nil }
		return appIcon
	}
	
}
