//
//  HomeTitleView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

enum HomeHeader {
    case home, popular, nearby
}

protocol HomeTitleDelegate:class {
    func scrollTo(header: HomeHeader)
}

class HomeTitleView:UIView {
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var nearbyButton: UIButton!
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var barLeadingAnchor: NSLayoutConstraint!
    
    weak var delegate:HomeTitleDelegate?
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        barView.backgroundColor = accentColor
        homeButton.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        popularButton.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        nearbyButton.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
    }
    
    func setup() {
        
    }
    
    func setProgress(_ progress:CGFloat) {
        let superview = barView.superview!
        barLeadingAnchor.constant = superview.bounds.width * progress
        
        
    }
    
    @objc func handleButton(_ sender:UIButton) {
        switch sender {
        case homeButton:
            delegate?.scrollTo(header: .home)
            break
        case popularButton:
            delegate?.scrollTo(header: .popular)
            break
        case nearbyButton:
            delegate?.scrollTo(header: .nearby)
            break
        default:
            break
        }
    }
}
