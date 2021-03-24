//
//  SessionManager.swift

import UIKit

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
internal  enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

/// A dictionary of parameters to apply to a `URLRequest`.
internal  typealias Parameters = [String: Any]

/// A dictionary of headers to apply to a `URLRequest`.
internal  typealias HTTPHeaders = [String: String]

internal class SessionManager: NSObject {

	static public func request(
        _ url: URL,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
		headers: HTTPHeaders? = nil,
		response: @escaping (_ json: [String : Any]?, _ error: Error?) -> ()) {
        var request = URLRequest(url: url)
			
		request.httpMethod = method.rawValue
		
		if let headers = headers {
            for (headerField, headerValue) in headers {
				request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
		if method == .post {
			guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters as Any, options: []) else {
				return
			}
			if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
			
			request.httpBody = httpBody
		}
		
		if method == .put {
			if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
			}
			if let parameters = parameters {
				request.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
			}
		}
		let userAgent = UserAgentBuilder.defaultMobileUserAgent().userAgent()
		request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
		
		let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				do {
					if let data = data,
						let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
						response(json , error)
					} else {
						response(nil, error)
					}
				} catch let error {
					response(nil, error)
				}
			}
		}
		task.resume()
    }
	
    private static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
	
	/// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    private static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
		} else {
			components.append((escape(key), escape("\(value)")))
		}
        return components
    }
	
	/// Returns a percent-escaped string following RFC 3986 for a query string key or value.
	   ///
	   /// RFC 3986 states that the following characters are "reserved" characters.
	   ///
	   /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
	   /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
	   ///
	   /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
	   /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
	   /// should be percent-escaped in the query string.
	   ///
	   /// - parameter string: The string to be percent-escaped.
	   ///
	   /// - returns: The percent-escaped string.
	   private static func escape(_ string: String) -> String {
		   let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
		   let subDelimitersToEncode = "!$&'()*+,;="

		   var allowedCharacterSet = CharacterSet.urlQueryAllowed
		   allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

		   var escaped = ""

		   //==========================================================================================================
		   //
		   //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
		   //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
		   //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
		   //  info, please refer to:
		   //
		   //      - https://github.com/Alamofire/Alamofire/issues/206
		   //
		   //==========================================================================================================

		   if #available(iOS 8.3, *) {
			   escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
		   } else {
			   let batchSize = 50
			   var index = string.startIndex

			   while index != string.endIndex {
				   let startIndex = index
				   let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
				   let range = startIndex..<endIndex

				   let substring = string[range]

				   escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)

				   index = endIndex
			   }
		   }

		   return escaped
	   }
	
}


extension NSNumber {
	fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
