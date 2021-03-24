//
//  NotificationManager.swift

import UIKit
import UserNotifications

class NotificationManager: NSObject {

	static let shared = NotificationManager()
	
	func setupUserNotification(application: UIApplication) {
		// For iOS 10 display notification (sent via APNS)
		UNUserNotificationCenter.current().delegate = application as? UNUserNotificationCenterDelegate
		
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: {_, _ in })
		
		application.registerForRemoteNotifications()
	}
	
}
