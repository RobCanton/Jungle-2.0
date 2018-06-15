//
//  SearchTitleView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class SearchBarView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var searchTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var textFieldLeadingAnchor: NSLayoutConstraint!
    
    func setup() {
        bubbleView.layer.cornerRadius = bubbleView.bounds.height / 2
        bubbleView.clipsToBounds = true
        textField.delegate = self
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.textField.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //textField.textAlignment = .left
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.searchLeadingAnchor.constant = 12.0
            self.searchTrailingAnchor.constant = 72.0
            self.textFieldLeadingAnchor.constant = 12.0
            self.layoutIfNeeded()
            self.cancelButton.alpha = 1.0
        }, completion: nil)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textField.textAlignment = .center
        
        let width = textWidth
        
        var leadingConstant:CGFloat = 12.0
        let bubbleWidth = bubbleView.bounds.width - 24.0
        if width < bubbleWidth {
            leadingConstant += (bubbleWidth - width) / 2
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.searchLeadingAnchor.constant = 44.0
            self.searchTrailingAnchor.constant = 44.0
            self.textFieldLeadingAnchor.constant = leadingConstant
            self.layoutIfNeeded()
            self.cancelButton.alpha = 0.0
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    var textWidth:CGFloat {
        return UILabel.size(text: textField.text ?? "", height: 44.0, font: Fonts.regular(ofSize: 16.0)).width
    }
}
