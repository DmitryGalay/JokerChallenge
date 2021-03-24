//
//  Logger.swift

import UIKit

internal class Logger: NSObject {

	internal static func printError(_ object: String) {
	  // Only allowing in DEBUG mode
		#if DEBUG
		Swift.print("[Debug App] ❗️ Error: \(object)")
	  #endif
	}

	internal static func printInfo(_ object: String) {
		// Only allowing in DEBUG mode
		Swift.print("[Debug App] 🔸 Info: \(object)")
	}
	
	internal static func printAmplitude(_ object: String) {
		// Only allowing in DEBUG mode
		Swift.print("[Debug App] 📈 Amplitued: \(object)")
	}

	internal static func printWarning(_ object: String) {
		// Only allowing in DEBUG mode
		Swift.print("[Debug App] ⚠️ Warning: \(object)")
	}
	
	internal static func printDevInfo(_ object: String) {
		// Only allowing in DEBUG mode
//		if Environment.debugMode {
			Swift.print("[Debug App] ⚙️ Develop: \(object)")
//		}
	}

	internal static func print(_ object: Any) {
	  // Only allowing in DEBUG mode
//	  #if DEBUG
		  Swift.print("[Debug App]: \(object)")
//	  #endif
	}
}
