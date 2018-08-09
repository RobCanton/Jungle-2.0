//
//  ViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import DynamicButton
import Pastel

class AuthViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    var pastelView:PastelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pastelView = PastelView(frame:view.bounds)
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight
        
        // Custom Duration
        pastelView.animationDuration = 12
        pastelView.setColors([hexColor(from: "00CA65"),
                              hexColor(from: "00937B")])
        pastelView.isUserInteractionEnabled = false
        
        view.insertSubview(pastelView, at: 0)
        
        
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
        loginButton.clipsToBounds = true
        
        loginContainer.applyShadow(radius: 32.0, opacity: 0.15, offset: CGSize(width: 0, height: 44.0), color: UIColor.black, shouldRasterize: false)
        
        signupButton.layer.cornerRadius = signupButton.bounds.height / 2
        signupButton.clipsToBounds = true
        
        signupButton.layer.borderColor = UIColor.white.cgColor
        signupButton.layer.borderWidth = 3.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startStatic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

