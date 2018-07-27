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

class Theme {
    var backgroundColor:UIColor
    var highlightedBackgroundColor:UIColor
    var tabBarColor:UIColor
    var primaryAccentColor:UIColor
    var secondaryAccentColor:UIColor
    var primaryTextColor:UIColor
    var secondaryTextColor:UIColor
    
    init(_ backgroundColor:UIColor,_ highlightedBackgroundColor:UIColor, _ tabBarColor:UIColor,
         _ primaryAccentColor:UIColor,_ secondaryAccentColor:UIColor, _ primaryTextColor:UIColor, _ secondaryTextColor:UIColor) {
        self.backgroundColor = backgroundColor
        self.highlightedBackgroundColor = highlightedBackgroundColor
        self.tabBarColor = tabBarColor
        self.primaryAccentColor = primaryAccentColor
        self.secondaryAccentColor = secondaryAccentColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
    }
    
    static let night = Theme(hexColor(from: "1a1a1a"),
                             hexColor(from: "111111"),
                             hexColor(from: "1a1a1a"),
                             accentColor,
                             tagColor,
                             .white,
                             UIColor(white: 0.4, alpha: 1.0))
    static let day = Theme(.white,
                           UIColor(white: 0.92, alpha: 1.0),
                           .white,
                           accentColor,
                           tagColor,
                           .black,
                           tertiaryColor)
}

var currentTheme = Theme.day
