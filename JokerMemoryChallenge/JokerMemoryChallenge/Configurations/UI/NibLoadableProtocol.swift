//
//  NibLoadableProtocol.swift
// --------Integration// --------
//
//Set SubClass Name to File's onwer
//!Not View
//
//
// Implement in view subclass:
//
//required init?(coder: NSCoder) {
//	super.init(coder: coder)
//	setupFromNib()
//}
//
//override init(frame: CGRect) {
//	super.init(frame: frame)
//	setupFromNib()
//}


import UIKit

public protocol NibLoadable {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {

	static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

	static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
		
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
		
		embeded(view)
    }
}

extension UIView {
    func embeded(_ view: UIView) -> Void{
		addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
	
	func embeded(_ view: UIView, attribute: NSLayoutConstraint.Attribute) -> Void{
		addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
		view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
		if attribute == .top {
			view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		}
		if attribute == .bottom {
			view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		}
    }
	
	func embededCenterHorizontally(_ view: UIView, attribute: NSLayoutConstraint.Attribute) -> Void{
		addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
		if attribute == .top {
			view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		}
		if attribute == .bottom {
			view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		}
    }
}

