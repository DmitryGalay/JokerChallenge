//
//  LinkBuilder.swift

import UIKit

enum DeeplinkType: String {
	case facebook = "facebook"
	case appsflyer = "appsflyer"
}

enum DeeplinkOrganicType: String {
	case organic = "Organic"
	case nonorganic = "Non-organic"
}

class LinkBuilder: NSObject {

	static func jdprLink(agreements: String, params: String) -> String {
		var link = agreements
		
		var defaultParams = [String : String]()
		
		if let appsflyerId = ConfigurationSettingsStorage.shared.appsflyerId {
			defaultParams["sub_id_10"] = appsflyerId
		}
		
		if let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString {
			defaultParams["sub_id_7"] = identifierForVendor
		}
		link.appendQueryParameters(defaultParams.toQueryParameters())
		link.appendQueryParameters(params)
		return link
	}
	
	static func deeplinkType(data: [AnyHashable : Any]) -> DeeplinkOrganicType? {
		guard let typeString = data["af_status"] as? String else {
			return nil
		}
		guard let type = DeeplinkOrganicType(rawValue: typeString) else{
			return nil
		}
		return type
	}
	
	static func parametersFrom(data: [AnyHashable : Any]) -> String? {
		var params: [String : String] = [:]
		
		if let campaignId = data["campaign_id"] as? String  {
			params["sub_id_4"] = campaignId
		}
		
		if let adset = data["adset"] as? String  {
			params["sub_id_3"] = adset
		}
		
		if let adset = data["af_adset"] as? String  {
			params["sub_id_3"] = adset
		}
		
		if let campaign = data["campaign"] as? String {
			let subComponents = campaign.components(separatedBy: "_")
			
			if let buyerId = subComponents[safeIndex: 1] {
				params["sub_id_2"] = buyerId
			}
			
			if let lastComponent = subComponents[safeIndex: 7] {
				let teemSubComponents = lastComponent.components(separatedBy: "%20")
				if let teamId = teemSubComponents.first {
					params["sub_id_1"] = teamId
				}
			}
		}
		return params.toQueryParameters()
	}
}

extension Array {
	
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}

private extension Dictionary where Key == String, Value == String {
	
    func toQueryParameters() -> String? {
		guard self.keys.count != 0 else {
			return nil
		}
		var queryParamString = ""
		for (key, value) in self {
			if queryParamString.count != 0 {
				queryParamString.append("&")
			}
			queryParamString.append("\(key)=\(value)")
		}
		return queryParamString
	}
}

private extension String {
	
	mutating func appendQueryParameters(_ parameters: String?) {
		guard let parameters = parameters else {
			return
		}
		let concatSymbol: String
		if let query = URL(string: self)?.query {
			concatSymbol = query.count > 0 ? "&" : "?"
		} else {
			concatSymbol = self.count > 0 ? "?" : ""
		}
		

		if parameters.count > 0 {
			self.append("\(concatSymbol)\(parameters)")
		}
	}
}
