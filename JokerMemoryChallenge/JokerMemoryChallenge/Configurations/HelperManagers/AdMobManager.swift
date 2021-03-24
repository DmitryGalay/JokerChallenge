//  AdMobMnager.swift

import UIKit
import GoogleMobileAds

class AdMobMnager: NSObject {
	
	static var shared: AdMobMnager = AdMobMnager()
	var banner: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
	
	func setup() {
		GADMobileAds.sharedInstance().start(completionHandler: nil)
		
		func setupAdmobBanner(_ banner: GADBannerView) {
			GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)]
		}
	}
	
	func addBanner(viewController: UIViewController, bannerPosition: NSLayoutConstraint.Attribute) {
		if AppSettings.isDebug {
			banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
		} else {
			banner.adUnitID = AppSettings.admobBannerId
		}
		banner.rootViewController = viewController
		
		banner.load(GADRequest())
		viewController.view.embededCenterHorizontally(banner, attribute: bannerPosition)
	}
}
