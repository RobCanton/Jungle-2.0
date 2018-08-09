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
import Pastel
import SwiftMessages

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
        submitButton.setTitle("Signing In...", for: .normal)
        submitButton.setTitleColor(UIColor.lightGray, for: .normal)
        submitButton.isEnabled = false
        submitButton.alpha = 0.8
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if let user = user {
                print("SIGNED IN!")
            } else if let error = error {
                print("ERROR: \(error.localizedDescription)")
                self.showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    func showErrorMessage(_ msg:String) {
        let error = MessageView.viewFromNib(layout: .cardView)
        
        error.configureContent(title: "Error", body: msg, iconImage: Icon.errorLight.image)
        error.button?.removeFromSuperview()
        error.accessibilityPrefix = "error"
        error.configureTheme(.error, iconStyle: .default)
        error.configureDropShadow()
        error.configureTheme(backgroundColor: UIColor(white: 0.4, alpha: 1.0), foregroundColor: .white)
        var config = SwiftMessages.Config.init()
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 4.0)
        
        SwiftMessages.show(config: config, view: error)
        
        submitButton.setTitle("Sign In", for: .normal)
        submitButton.setTitleColor(hexColor(from: "68CD98"), for: .normal)
        submitButton.isEnabled = true
        submitButton.alpha = 1.0
    }
    
    var pastelView:PastelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pastelView = PastelView(frame:view.bounds)
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight
        
        // Custom Duration
        pastelView.animationDuration = 12
        pastelView.setColors([hexColor(from: "00CA65"),
                              hexColor(from: "00937B")])
        pastelView.isUserInteractionEnabled = false
        
        view.insertSubview(pastelView, at: 0)
        
        submitButton.layer.cornerRadius = submitButton.bounds.height / 2
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor.white
        
        submitContainer.applyShadow(radius: 24.0, opacity: 0.15, offset: CGSize(width: 0, height: 8.0), color: UIColor.black, shouldRasterize: false)

        emailField.delegate = self
        passField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startStatic()
        
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

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passField.becomeFirstResponder()
            break
        case passField:
            handleSubmit()
            break
        default:
            break
        }
        return true
    }
}
