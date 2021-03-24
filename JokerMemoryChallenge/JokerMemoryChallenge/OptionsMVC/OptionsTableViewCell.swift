//
//  OptionsTableViewCell.swift

import UIKit

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var circleImageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    
    enum OptionsCellState {
        case inactive
        case active
        case selected
    }
    
    var state: OptionsCellState = .inactive {
        didSet {
            switch state {
            case .inactive:
                backgroundImageView.isHighlighted = false
                circleImageView.image = #imageLiteral(resourceName: "check_nonactive")
            case .active:
                backgroundImageView.isHighlighted = true
                circleImageView.image = #imageLiteral(resourceName: "check_empty")
            case .selected:
                backgroundImageView.isHighlighted = true
                circleImageView.image = #imageLiteral(resourceName: "check_selected")
            }
        }
    }
    
    var title = "" {
        didSet {
            label.attributedText = title.outlineAttributedText
        }
    }
    
    var priceTitle: String? {
        didSet {
            if let text = priceTitle {
                priceLabel.attributedText = text.outlineAttributedText
                priceLabel.isHidden = false
            } else {
                priceLabel.isHidden = true
            }
        }
    }
}
