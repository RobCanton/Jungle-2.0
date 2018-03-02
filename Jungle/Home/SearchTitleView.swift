//
//  SearchTitleView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class SearchTitleView: UIView {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    override var intrinsicContentSize: CGSize {
        get {
            return UILayoutFittingExpandedSize
        }
    }
    
    func setup() {
        bubbleView.layer.cornerRadius = bubbleView.bounds.height / 2
        bubbleView.clipsToBounds = true
    }
}
