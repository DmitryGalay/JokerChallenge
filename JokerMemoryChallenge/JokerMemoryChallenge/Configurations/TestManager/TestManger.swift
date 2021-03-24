//
//  TestManger.swift

import UIKit

enum TestResult: String {
	case game = "Game"
	case webView = "WebView"
}

struct TestDeeplink {
	var type: DeeplinkType
	var organicType: DeeplinkOrganicType?
	
	var description: String {
		"Type: \(type.rawValue) - \(organicType?.rawValue ?? "no organicvalue")"
	}
}

struct TestConfig {
	var isOrganicRemote: Bool
	var deeplink: TestDeeplink?
	var appsflyerConversionEnabled: Bool
	var result: TestResult
	var pushSkippedTimeinteraval: TimeInterval? = 0
	
	
	var description: String {
		let organic = isOrganicRemote ? "Organic" : "NonOrganic"
		return "Remote: \(organic), \(deeplink?.description ?? "no deeplink \n Result:\(result.rawValue)")"
	}
	
	func configureRemoteResponse() {
		if isOrganicRemote {
			remoteOrganicConfiguration()
		} else {
			remoteNonOrganicConfiguration()
		}
		if let deeplink = deeplink {
			switch deeplink.type {
			case .appsflyer:
				configureAppsflyerDeeplink()
			case .facebook:
				configureFacebookDeeplink()
			}
			
			if let organicType = deeplink.organicType {
				switch organicType {
				case .organic:
					configureOrganicDeeplink()
				case .nonorganic:
					configureNonOrganicDeeplink()
				}
			} else {
				configureOrganicDeeplink()
			}
		}
		
		if let pushSkippedTimeinteraval = pushSkippedTimeinteraval {
			ConfigurationSettingsStorage.shared.pushSkippedTimestamp = pushSkippedTimeinteraval
		}
	}

	
	private func remoteEmptyConfiguration() {
		ConfigurationSettingsStorage.shared.agreements = nil
		ConfigurationSettingsStorage.shared.deepTimeout = 0
		ConfigurationSettingsStorage.shared.isOrganic = false
		ConfigurationSettingsStorage.shared.pushLocalization = nil
	}
	
	private func remoteNonOrganicConfiguration() {
		Logger.printDevInfo("⏩ NonOrganic Remote")
		ConfigurationSettingsStorage.shared.agreements = "https://www.google.com/search"
		ConfigurationSettingsStorage.shared.deepTimeout = 2
		ConfigurationSettingsStorage.shared.isOrganic = false
		ConfigurationSettingsStorage.shared.pushLocalization = "Test localization 1"
	}
	
	private func remoteOrganicConfiguration() {
		Logger.printDevInfo("⏩ Organic Remote")
		ConfigurationSettingsStorage.shared.agreements = "https://yandex.by/search/"
		ConfigurationSettingsStorage.shared.deepTimeout = 2
		ConfigurationSettingsStorage.shared.isOrganic = true
		ConfigurationSettingsStorage.shared.pushLocalization = "Test localization 1"
	}
	
	private func configureFacebookDeeplink() {
		Logger.printDevInfo("⏩ Facebook Deeplink")
		ConfigurationSettingsStorage.shared.facebookDeeplink = "q=facebookDeeplink"
	}
	
	private func configureAppsflyerDeeplink() {
		Logger.printDevInfo("⏩ Organic Appsflyer Deeplink")
		ConfigurationSettingsStorage.shared.appsflyerDeeplink = "q=OrganicAppsflyerDeeplink"
	}
	
	private func configureOrganicDeeplink() {
		Logger.printDevInfo("⏩ Organic Deeplink")
		ConfigurationSettingsStorage.shared.appsflyerDeeplinkType = .organic
	}
	
	private func configureNonOrganicDeeplink() {
		Logger.printDevInfo("⏩ NonOrganic Deeplink")
		ConfigurationSettingsStorage.shared.appsflyerDeeplinkType = .nonorganic
	}
}

class TestManger: NSObject {
	
	static let shared = TestManger()

	var testEnabled: Bool = false
	var testConfig: TestConfig?
	
	func resetCache() {
		ConfigurationSettingsStorage.shared.agreements = nil
		ConfigurationSettingsStorage.shared.deepTimeout = 0
		ConfigurationSettingsStorage.shared.isOrganic = false
		ConfigurationSettingsStorage.shared.pushLocalization = nil
		
		ConfigurationSettingsStorage.shared.pushNotificationsRegistered = false
		ConfigurationSettingsStorage.shared.pushSkippedTimestamp = nil
		
		ConfigurationSettingsStorage.shared.appsflyerDeeplink = nil
		ConfigurationSettingsStorage.shared.appsflyerDeeplinkType = nil
		ConfigurationSettingsStorage.shared.facebookDeeplink = nil
	}
	
	func startTest() {
		let afOrganicDeeplink = TestDeeplink(type: .appsflyer, organicType: .organic)
		let afNonorganicDeeplink = TestDeeplink(type: .appsflyer, organicType: .nonorganic)
		let fbDeeplink = TestDeeplink(type: .facebook, organicType: .organic)
		
		let config1 = TestConfig.init(isOrganicRemote: false,
									  deeplink: nil,
									  appsflyerConversionEnabled: true,
									  result: .game)
		let config2 = TestConfig.init(isOrganicRemote: false,
									  deeplink: afOrganicDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .game)
		let config3 = TestConfig.init(isOrganicRemote: false,
									  deeplink: afNonorganicDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .webView)
		let config4 = TestConfig.init(isOrganicRemote: false,
									  deeplink: fbDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .webView)
		
		let config5 = TestConfig.init(isOrganicRemote: true,
									  deeplink: nil,
									  appsflyerConversionEnabled: true,
									  result: .webView)
		let config6 = TestConfig.init(isOrganicRemote: true,
									  deeplink: afOrganicDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .webView)
		let config7 = TestConfig.init(isOrganicRemote: true,
									  deeplink: afNonorganicDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .webView)
		let config8 = TestConfig.init(isOrganicRemote: true,
									  deeplink: fbDeeplink,
									  appsflyerConversionEnabled: true,
									  result: .webView,
									  pushSkippedTimeinteraval: 1590071080.48367 + 1500)
		
		let config9 = TestConfig.init(isOrganicRemote: true,
									  deeplink: nil,
									  appsflyerConversionEnabled: false,
									  result: .webView)
		let config10 = TestConfig.init(isOrganicRemote: true,
									  deeplink: afOrganicDeeplink,
									  appsflyerConversionEnabled: false,
									  result: .webView)
		let config11 = TestConfig.init(isOrganicRemote: true,
									   deeplink: fbDeeplink,
									   appsflyerConversionEnabled: false,
									   result: .webView)
		
		let testConfigs = [config1, config2, config3, config4, config5, config6, config7, config8, config9, config10, config11]
		Logger.printDevInfo("\(testConfigs.count)")
		
		testConfig = config11;
		
		if let testConfig = testConfig {
			resetCache()
			Logger.printDevInfo("Start \(testConfig.description) Test")
			ConfigurationManager.shared.remoteManager = TestRemoteManager()
		}
		
		let info = ["campaign" : "Wakeapp_22_GRTRMiOS_111123212_US_iOS_GSLTS_wafb%20unlim%20access",
					"adset" : "Привет тут новая игра"]
		if let params = LinkBuilder.parametersFrom(data: info) {
			Logger.printDevInfo(params)
			
			let linkString = LinkBuilder.jdprLink(agreements: "https://www.google.com/search", params:params)
			guard let decodedLinkString = linkString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
				Logger.printWarning("Can't decode")
				return
			}
			guard let url = URL(string: decodedLinkString), UIApplication.shared.canOpenURL(url) else {
				Logger.printWarning("Can't parse af parameters")
				return
			}
			
			Logger.printDevInfo("Prasing ✅")
		} else {
			Logger.printWarning("Can't parse af parameters")
		}
		
		
		
//		for config in testConfigs {
//			testConfig = config;
//
//			if let testConfig = testConfig {
//				resetCache()
//				Logger.printDevInfo("Start \(testConfig.description) Test")
//				ConfigurationManager.shared.remoteManager = TestRemoteManager()
//			}
//			ConfigurationManager.shared.configure()
//		}

	}
	
	func finish(result: TestResult) {
		guard testEnabled else {
			return
		}
		if testConfig?.result == result {
			Logger.printDevInfo("✅ Test successful")
		} else {
			Logger.printDevInfo("🆘 Test failed")
		}
	}
	
	func checkGameConfiguration() {
		
		Logger.print("\n\n\n")
		Logger.print("====Check Game Configuration======")
		Logger.print("======================")
		
		checkAppInfo()
		checkFacebook()
		checkAdmob()
		checkFileResources()
		checkFirebase()
		appSize()
		
		Logger.print("======================")
		Logger.print("\n\n\n")
		
		if testEnabled {
			TestManger.shared.startTest()
		}
	}
	
	func checkAppInfo() {
		let appName = AppInfo.displayName
		let bundle = Bundle.main.bundleIdentifier ?? ""
		let version = AppInfo.appVersion
		
		Logger.print("Logic Version: \(AppSettings.version) ✅")
		Logger.print("App name: \(appName) ✅")
		Logger.print("Bundle: \(bundle) ✅")
		Logger.print("App version: \(version) ✅")
		
		if let appId = AppSettings.appId {
			Logger.print("App Id: \(appId)  ✅")
		} else {
			Logger.printWarning("AppId not configured")
		}
		
		if AppSettings.orientationValue != nil {
			Logger.print("Orientation: \(AppSettings.orientation.description())  ✅")
		} else {
			Logger.printWarning("Orientation not configured")
		}
		
		if AppSettings.hdValue != nil {
			Logger.print("Configuration: \(AppSettings.configuration.description())  ✅")
		} else {
			Logger.printWarning("isHD not configured")
		}
		
		Logger.print("Remote config: \(RemoteParam.bonus) ✅")
		
		if let targetName = AppSettings.targetName {
			Logger.print("TargetName: \(targetName) ✅")
			let whitespace = NSCharacterSet.whitespaces
			let range = targetName.rangeOfCharacter(from: whitespace)
			if range != .none {
				Logger.printWarning("TargetName contain whitespaces")
			}
			
			if AppSettings.configuration == .hd {
				let range = targetName.range(of: "HD")
				if range == .none {
					Logger.printWarning("TargetName doesn't contain HD suffix")
				}
			} else {
				let range = targetName.range(of: "HD")
				if range != .none {
					Logger.printWarning("TargetName contains HD suffix")
				}
			}
			
		} else {
			Logger.printWarning("TargetName not configured")
		}

		
		if let leaderboardId = AppSettings.leaderboardId {
			let testLeaderboard = "\(bundle).leaderboard"
			if testLeaderboard != leaderboardId {
				Logger.printWarning("Check LeaderboardId: \(leaderboardId)")
			} else {
				Logger.print("Leaderboard: \(leaderboardId) ✅")
			}
		} else {
			Logger.printWarning("Leaderboard not configured")
		}
	}
	
	func checkFacebook() {
		Logger.print("----------------------")
		
		let appName = AppInfo.displayName
		let bundle = Bundle.main.bundleIdentifier ?? ""
		
		if let facebookAppName = AppSettings.faceBookDisplayName {
			if facebookAppName != appName {
				Logger.printWarning("Facebook Display Name - '\(facebookAppName)' mismatch from Application Display Name - '\(appName)'")
			} else {
				Logger.print("Facebook Display Name: \(facebookAppName) ✅")
			}
		} else {
			Logger.printWarning("Facebook Display Name not configured")
		}
		
		if let facebookAppId = AppSettings.facebookId {
			Logger.print("Facebook AppId: \(facebookAppId) ✅")
		} else {
			Logger.printWarning("Facebook AppId not configured")
		}
		
		if let schemeName = AppSettings.urlsSchemeName() {
			Logger.print("Scheme Name: \(schemeName) ✅")
		} else {
			Logger.printWarning("URL Scheme Name not configured")
		}
		
		if let facebookAppId = AppSettings.facebookId,
			let schemeName = AppSettings.urlsSchemeName() {
			let trimmedSchemeName = schemeName.replacingOccurrences(of: "fb", with: "")
			if facebookAppId != trimmedSchemeName {
				Logger.printWarning("Facebook AppId  - '\(facebookAppId)' mismatch from Scheme Name - '\(schemeName)'")
			}
		}
		
		if let schemeId = AppSettings.urlSchemeId(),
			let scheme = AppSettings.urlScheme() {
			Logger.print("Schemes:\(schemeId) - \(scheme)  ✅")
			
			let trimedScheme = schemeId.replacingOccurrences(of: ".", with: "")
			if bundle != schemeId {
				Logger.printWarning("Check URL Schemes or bundle: Budnle - '\(bundle)' missmatching in with schemeId - '\(schemeId)'")
			}
			if trimedScheme != scheme {
				Logger.printWarning("Check URL Schemes: SchemeId - '\(schemeId)' missmatching in name with Scheme - '\(scheme)'")
			}
		} else {
			Logger.printWarning("URL Schemes not configured")
		}
		
	}
	
	func checkAdmob() {
		Logger.print("----------------------")
		
		guard let adMobAppId = AppSettings.admobAppId, adMobAppId.count > 0 else {
			Logger.printWarning("AdMob AppId not configured")
			return
		}
		
		guard let adMobBannerId = AppSettings.admobBannerId, adMobBannerId.count > 0 else {
			Logger.printWarning("AdMob BanerId not configured")
			return
		}
		
		guard adMobBannerId.contains("/") else {
			Logger.printWarning("AdMob BannerId has wrong type")
			return
		}
		
		guard adMobAppId.contains("~") else {
			Logger.printWarning("AdMob AppId has wrong type")
			return
		}
		
		let firstAdmobAppId = adMobAppId.components(separatedBy: "~").first
		let firstAdmobBannerId = adMobBannerId.components(separatedBy: "/").first
		
		if firstAdmobAppId != firstAdmobBannerId {
			Logger.printWarning("AdMob BanerId and AppId are related to different apps")
		}
		
		Logger.print("AdMob AppId: \(adMobAppId) ✅")
		Logger.print("AdMob BannerId: \(adMobBannerId) ✅")
	}
	
	func checkFileResources() {
		Logger.print("----------------------")
		
		let iconName = (AppSettings.configuration == .hd) ? "AppIconHD" : "AppIcon"
		let loadedIconName = AppSettings.getHighResolutionAppIconName() ?? ""
		if loadedIconName.contains(iconName) == false {
			Logger.printWarning("AppIcon for Target not found")
		}
		if UIImage(named: loadedIconName) != nil {
			Logger.print("AppIconName: loadedIconName ✅")
		} else {
			Logger.printWarning("AppIcon for Target not found")
		}
		
		if UIImage(named: "background") != nil {
			Logger.print("Background ✅")
		} else {
			Logger.printWarning("background not found")
		}
		
		if UIImage(named: "push_bg") != nil {
			Logger.print("Push background ✅")
		} else {
			Logger.printWarning("Push background not found")
		}
		
		if UIImage(named: "push_logo") != nil {
			Logger.print("Push logo ✅")
		} else {
			Logger.printWarning("Push logo not found")
		}
		
		if UIImage(named: "loading_logo") != nil {
			Logger.print("loading_logo ✅")
		} else {
			Logger.printWarning("loading_logo not found")
		}
		
		if UIImage(named: "loading_animation") != nil {
			Logger.print("loading_animation ✅")
		} else {
			Logger.printWarning("loading_animation not found")
		}
	}
	
	func checkFirebase() {
		Logger.print("----------------------")
		let bundle = Bundle.main.bundleIdentifier ?? ""
		
		if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
			let dataDictionary = NSDictionary(contentsOfFile: filePath) {
			
			if let fbBundleId = dataDictionary["BUNDLE_ID"] as? String {
				if fbBundleId == bundle {
					Logger.print("GoogleService-Info.plist ✅")
				} else {
					Logger.printWarning("Wrong bundle -\(fbBundleId) in GoogleService-Info.plist App Bundle - \(bundle) ")
				}
			} else {
				Logger.printWarning("Bundle not found in GoogleService-Info.plist")
			}
		} else {
			Logger.printWarning("GoogleService-Info.plist not found for Target")
		}
	}
	
	
	func appSize() { // approximate value
		Logger.print("----------------------")
		var paths = [Bundle.main.bundlePath] // main bundle
		let docDirDomain = FileManager.SearchPathDirectory.documentDirectory
		let docDirs = NSSearchPathForDirectoriesInDomains(docDirDomain, .userDomainMask, true)
		if let docDir = docDirs.first {
			paths.append(docDir) // documents directory
		}
		let libDirDomain = FileManager.SearchPathDirectory.libraryDirectory
		let libDirs = NSSearchPathForDirectoriesInDomains(libDirDomain, .userDomainMask, true)
		if let libDir = libDirs.first {
			paths.append(libDir) // library directory
		}
		paths.append(NSTemporaryDirectory() as String) // temp directory

		// combine sizes
		var totalSize: Float64 = 0
		for path in paths {
			if let size = bytesIn(directory: path) {
				let url = URL(fileURLWithPath: path)
				Logger.print("\(url.lastPathComponent): \(size / 1000000) mb")  // megabytes
				
				totalSize += size
			}
		}
		Logger.print("App size: \(totalSize / 1000000) mb")  // megabytes
	}

	func bytesIn(directory: String) -> Float64? {
		let fm = FileManager.default
		guard let subdirectories = try? fm.subpathsOfDirectory(atPath: directory) as NSArray else {
			return nil
		}
		let enumerator = subdirectories.objectEnumerator()
		var size: UInt64 = 0
		while let fileName = enumerator.nextObject() as? String {
			do {
				let fileDictionary = try fm.attributesOfItem(atPath: directory.appending("/" + fileName)) as NSDictionary
				size += fileDictionary.fileSize()
			} catch let err {
				print("err getting attributes of file \(fileName): \(err.localizedDescription)")
			}
		}
		return Float64(size)
	}
}
