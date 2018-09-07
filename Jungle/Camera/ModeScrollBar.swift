//
//  ModeScrollBar.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-30.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit



class ModeScrollBar:UIView, UIScrollViewDelegate {
    
    var titleLeadingAnchor:NSLayoutConstraint!
    var title1:UIButton!
    var title2:UIButton!
    var title3:UIButton!
    
    var delegate:TabScrollDelegate?
    
    var anchorZeroVal:CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.translatesAutoresizingMaskIntoConstraints = false
        title1 = UIButton(type: .custom)
        title1.setTitle("PHOTO", for: .normal)
        title1.titleLabel?.font = Fonts.bold(ofSize: 14.0)
        title1.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12)
        title1.sizeToFit()
        title1.alpha = 0.4
        addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
         anchorZeroVal = bounds.width / 2 - title1.bounds.width / 2
        titleLeadingAnchor = title1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: anchorZeroVal)
        titleLeadingAnchor.isActive = true
        title1.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        title2 = UIButton(type: .custom)
        title2.setTitle("VIDEO", for: .normal)
        title2.titleLabel?.font = Fonts.bold(ofSize: 14.0)
        title2.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12)
        title2.sizeToFit()
        title2.alpha = 1.0
        addSubview(title2)
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.leadingAnchor.constraint(equalTo: title1.trailingAnchor, constant: 0.0).isActive = true
        title2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        title3 = UIButton(type: .custom)
        title3.setTitle("TEXT", for: .normal)
        title3.titleLabel?.font = Fonts.bold(ofSize: 14.0)
        title3.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12)
        title3.sizeToFit()
        title3.alpha = 0.4
        addSubview(title3)
        title3.translatesAutoresizingMaskIntoConstraints = false
        title3.leadingAnchor.constraint(equalTo: title2.trailingAnchor, constant: 0.0).isActive = true
        title3.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        titleLeadingAnchor.constant = anchorZeroVal - title1.bounds.width
        self.layoutIfNeeded()
        
        title1.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
        title2.addTarget(self, action: #selector(handleTab), for: .touchUpInside)

        title3.addTarget(self, action: #selector(handleTab), for: .touchUpInside)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress:CGFloat, index:Int) {
        
        if index == 0 {
            titleLeadingAnchor.constant = anchorZeroVal - title1.bounds.width * progress
            title1.alpha = (1 - progress) * 0.6 + 0.4
            title2.alpha = progress * 0.6 + 0.4
            title3.alpha = 0.4
        } else {
            titleLeadingAnchor.constant = anchorZeroVal - title1.bounds.width - title2.bounds.width * progress
            title1.alpha = 0.4
            title2.alpha = (1 - progress) * 0.6 + 0.4
            title3.alpha = progress * 0.6 + 0.4
        }
        
        self.layoutIfNeeded()
        
    }
    
    @objc func handleTab(_ sender:UIButton) {
        
        switch sender {
        case title1:
            delegate?.tabScrollTo(index: 0)
            break
        case title2:
            delegate?.tabScrollTo(index: 1)
            break
        case title3:
            delegate?.tabScrollTo(index: 2)
            break
        default:
            break
        }
    }
}
