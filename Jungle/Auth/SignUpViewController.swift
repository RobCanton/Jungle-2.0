//
//  PhoneNumberViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController:UIViewController {
    
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passField:UITextField!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitContainer:UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    
    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func handleSubmit() {
        guard let email = emailField.text else { return }
        guard let pass = passField.text else { return }
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: pass)
        print("CREDENTIAL: \(credential)")
        user.linkAndRetrieveData(with: credential) { user, error in
            if let user = user?.user, error == nil {
                print("WE GUCCI!")
                let ref = firestore.collection("users").document(user.uid)
                ref.setData(["type": "authenticated"])
                
                Auth.auth().signIn(withEmail: email, password: pass) { user, error in
                    if let user = user {
                        
                        appProtocol.listenToAuth()
                    } else if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    }
                }
            } else {
                print("WE NO GUCCI!: error\(error?.localizedDescription)")
                
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
        UIView.animate(withDuration: 0.05, animations: {
            self.titleLabel1.alpha = 0.0
            self.titleLabel2.alpha = 0.0
        })
        self.stackBottomConstraint.constant = keyboardSize.height + 24.0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        
        UIView.animate(withDuration: 0.05, delay: 0.15, options: [], animations: {
            self.titleLabel1.alpha = 1.0
            self.titleLabel2.alpha = 1.0
        }, completion: nil)
        
        self.stackBottomConstraint.constant = 98.0
        self.view.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}
