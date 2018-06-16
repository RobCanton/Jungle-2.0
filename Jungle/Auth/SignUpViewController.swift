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
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passField:UITextField!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitContainer:UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func handleSubmit() {
        guard let username = usernameField.text else { return }
        guard let email = emailField.text else { return }
        guard let pass = passField.text else { return }
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: pass)
        print("CREDENTIAL: \(credential)")
        user.linkAndRetrieveData(with: credential) { user, error in
            if let user = user?.user, error == nil {
                print("WE GUCCI!")
                let ref = firestore.collection("users").document(user.uid)
                ref.setData(["username":username, "type": "authenticated"])
            } else {
                print("WE NO GUCCI!: error\(error?.localizedDescription)")
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = submitButton.bounds.height / 2
        submitButton.clipsToBounds = true
        
        submitContainer.applyShadow(radius: 32.0, opacity: 0.15, offset: CGSize(width: 0, height: 44.0), color: UIColor.black, shouldRasterize: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        print("keyboardWillShow")
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.stackBottomConstraint.constant = keyboardSize.height + 24.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        UIView.animate(withDuration: 0.15, animations: {
            self.stackBottomConstraint.constant = 98.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}
