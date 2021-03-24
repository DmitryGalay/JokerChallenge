//  Copyright © 2018. All rights reserved.

import UIKit

@objc class APIManager: NSObject {
    static let shared = APIManager()
    
	func sendPushToken(_ deviceToken: String, onComplete completeBlock: @escaping (_ error : Error?) -> Void) {
        
		var params = [String : String]()
		if let bundleIdentifier = Bundle.main.bundleIdentifier {
			params["appBundle"] = bundleIdentifier
		}
	
		if let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString {
			params["deviceId"] = identifierForVendor
		}
		if let langStr = Locale.current.languageCode {
			params["locale"] = langStr
		}
		params["deviceToken"] = deviceToken
		
		
		let url = URL(string: "https://sevas.site/loguser")!
		SessionManager.request(url, method: .post, parameters: params, headers: ["Content-Type" : "application/json"]) { (response, error) in
			completeBlock(error)
		}
    }
    
}

