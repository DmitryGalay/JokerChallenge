//
//  LoadingView.swift

import UIKit

class LoadingView: UIView, NibLoadable {

	@IBOutlet weak var animatedView: UIView!
	@IBOutlet var progressLabel: UILabel!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupFromNib()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFromNib()
	}
	
	
	func startAnimating() {
		animatedView.rotate360Degrees()
	}
	
	func stopAnimating() {
		animatedView.stopRotating()
	}
}

extension UIView {
	func rotate360Degrees(duration: CFTimeInterval = 2.0) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.fromValue = 0.0
		rotateAnimation.toValue = CGFloat.pi * 2
		rotateAnimation.duration = duration
		rotateAnimation.repeatCount = Float.infinity
		self.layer.add(rotateAnimation, forKey: nil)
	}
	
	func stopRotating(){
		self.layer.sublayers?.removeAll()
		//or
		self.layer.removeAllAnimations()
	}
}
