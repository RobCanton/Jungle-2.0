//
//  LoginViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import DynamicButton

class LoginViewController:UIViewController {
    
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passField:UITextField!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitContainer:UIView!
    @IBOutlet weak var submitButton: UIButton!
   
    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func handleSubmit() {
        print("SIGN IN!")
        guard let email = emailField.text else { return }
        guard let pass = passField.text else { return }
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if let user = user {
                print("SIGNED IN!")
            } else if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = submitButton.bounds.height / 2
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor.white
        
        submitContainer.applyShadow(radius: 24.0, opacity: 0.15, offset: CGSize(width: 0, height: 8.0), color: UIColor.black, shouldRasterize: false)

    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        print("keyboardWillShow")
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        self.stackBottomConstraint.constant = keyboardSize.height + 24.0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        
        self.stackBottomConstraint.constant = 98.0
        self.view.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

