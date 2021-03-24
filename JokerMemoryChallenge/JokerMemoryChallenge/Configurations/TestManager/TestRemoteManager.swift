//
//  TestRemoteManager.swift


import UIKit

class TestRemoteManager: RemoteConfigurable {
	
	func requestGameConfiguration(onComplete completeBlock: @escaping (_ agree: String?) -> Void) {

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			TestManger.shared.testConfig?.configureRemoteResponse()
			DispatchQueue.main.async {
				completeBlock(nil)
			}
		}
	}
}
