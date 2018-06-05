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
    
    static let montserrat = "Montserrat"
    static let antenna = "Antenna"
    static let usual = "Usual"
    static let bentonSans = "BentonSans"
    static let bioSans = "BioSans"
    static let houschka = "Houschka"
    static let primaryFontName = Fonts.montserrat
    
    static func medium(ofSize size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size, weight: .medium)//UIFont(name: "\(primaryFontName)-Medium", size: size)!
    }
    
    static func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)//UIFont(name: "\(primaryFontName)-Regular", size: size)!
    }
    
    static func light(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)//UIFont(name: "\(primaryFontName)-Light", size: size)!
    }
    
    static func semiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)//UIFont(name: "\(primaryFontName)-SemiBold", size: size)!
    }
    static func bold(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)//UIFont(name: "\(primaryFontName)-Bold", size: size)!
    }
}
