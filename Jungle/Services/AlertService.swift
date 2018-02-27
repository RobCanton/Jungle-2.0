//
//  AlertService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

struct Alerts {
    
    static func showSuccessAlert(withMessage message: String, inWrapper wrapper:SwiftMessages?=nil){
        
        let alert = MessageView.viewFromNib(layout: .statusLine)
        alert.backgroundView.backgroundColor = accentColor
        alert.bodyLabel?.textColor = UIColor.white
        alert.bodyLabel?.font = Fonts.semiBold(ofSize: 12.0)
        alert.configureContent(body: message)
        
        var config = SwiftMessages.defaultConfig
        config.duration = SwiftMessages.Duration.seconds(seconds: 2.0)
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        if wrapper != nil {
            wrapper!.hideAll()
            wrapper!.show(config: config, view: alert)
        } else {
            SwiftMessages.hideAll()
            SwiftMessages.show(config: config, view: alert)
        }
    }
    
    static func showInfoAlert(withMessage message: String, inWrapper wrapper:SwiftMessages?=nil){
        
        let alert = MessageView.viewFromNib(layout: .statusLine)
        alert.backgroundView.backgroundColor = UIColor.white
        alert.bodyLabel?.textColor = UIColor.gray
        alert.bodyLabel?.font = Fonts.semiBold(ofSize: 12.0)
        alert.configureContent(body: message)
        
        var config = SwiftMessages.defaultConfig
        config.duration = SwiftMessages.Duration.forever
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        if wrapper != nil {
            wrapper!.hideAll()
            wrapper!.show(config: config, view: alert)
        } else {
            SwiftMessages.hideAll()
            SwiftMessages.show(config: config, view: alert)
        }
    }
    
}
