//
//  InitialViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InitialViewController:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().signInAnonymously() { (user, error) in
            if user != nil && error == nil {
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
    }
}
