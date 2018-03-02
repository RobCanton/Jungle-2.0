//
//  LoginViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController:UIViewController {
    
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var loginContainer:UIView!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    
    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
        loginButton.clipsToBounds = true
        
        loginContainer.applyShadow(radius: 32.0, opacity: 0.15, offset: CGSize(width: 0, height: 44.0), color: UIColor.black, shouldRasterize: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        print("keyboardWillShow")
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.stackBottomConstraint.constant = keyboardSize.height + 24.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        UIView.animate(withDuration: 0.15, animations: {
            self.stackBottomConstraint.constant = 128.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}
