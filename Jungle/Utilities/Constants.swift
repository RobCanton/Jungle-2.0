//
//  Constants.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class Fonts {
    
    static func medium(ofSize size: CGFloat) -> UIFont {
         return UIFont(name: "Montserrat-Medium", size: size)!
    }
    
    static func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size)!
    }
    
    static func light(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size)!
    }
    
    static func semiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-SemiBold", size: size)!
    }
    static func bold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size)!
    }
}
