//
//  Constants.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

let gradientGroups = [
    [hexColor(from: "74276C"),
     hexColor(from: "C53364"),
     hexColor(from: "FD8263")],
    [hexColor(from: "274B74"),
     hexColor(from: "8233C5"),
     hexColor(from: "E963FD")],
    [hexColor(from: "879AF2"),
     hexColor(from: "D3208B"),
     hexColor(from: "FDA000")],
    [hexColor(from: "8929AD"),
     hexColor(from: "436AAC"),
     hexColor(from: "43B7B8")],
    [hexColor(from: "276174"),
     hexColor(from: "33C58E"),
     hexColor(from: "63FD88")],
    [hexColor(from: "574BCD"),
     hexColor(from: "2999AD"),
     hexColor(from: "41E975")],
    [hexColor(from: "363553"),
     hexColor(from: "903775"),
     hexColor(from: "E8458B")],
    [hexColor(from: "5C2774"),
     hexColor(from: "335CC5"),
     hexColor(from: "637FFD")],
    [hexColor(from: "EA5A6F"),
     hexColor(from: "DE791E"),
     hexColor(from: "FCCF3A")],
    [hexColor(from: "F17B4A"),
     hexColor(from: "E05BA2"),
     hexColor(from: "CD4BC9")],
    [hexColor(from: "FCE38A"),
     hexColor(from: "F38181")],
    [hexColor(from: "F54EA2"),
     hexColor(from: "FF7676")],
    [hexColor(from: "17EAD9"),
     hexColor(from: "6078EA")],
    [hexColor(from: "622774"),
     hexColor(from: "C53364")],
    [hexColor(from: "42E695"),
     hexColor(from: "3BB2B8")],
    [hexColor(from: "65799B"),
     hexColor(from: "5E2563")],
    [hexColor(from: "184E68"),
     hexColor(from: "57CA85")],
    [hexColor(from: "5B247A"),
     hexColor(from: "1BCEDF")]
    
]

class Emojis {
    
    static let all = [smiliesAndPeople]
    static let _smiliesAndPeople = "😀😃😄😁😆😅😂🤣☺️😊😇🙂🙃😉😌😍😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🤩😏😒😞😔😟😕🙁☹️😣😖😫😩😢😭😤😠😡🤬🤯😳😱😨😰😥😓🤗🤔🤭🤫🤥😶😐😑😬🙄😯😦😧😮😲😴🤤😪😵🤐🤢🤮🤧😷🤒🤕🤑🤠😈👿👹👺🤡💩👻💀☠️👽👾🤖🎃😺😸😹😻😼😽🙀😿😾🤲👐🙌👏🤝👍👎👊✊🤛🤞✌️🤟🤘👌👈👉👆👇☝️✋🤚🖐🖖👋🤙💪🖕✍️🙏💍💄💋👄👅👂👃👣👁👀🧠🗣👤👥👶👧🧒👩🧑👨👱‍♀️👱‍♂️🧔👵🧓👴👲👳‍♀️👳‍♂️🧕👮‍♀️👮‍♂️👷‍♀️👷‍♂️💂‍♀️💂‍♂️👶🕵️‍♀️👶🕵️‍♂️👩‍⚕️👨‍⚕️👩‍🌾👨‍🌾👩‍🍳👨‍🍳👩‍🎓👨‍🎓👩‍🎤👨‍🎤👩‍🏫👨‍🏫👩‍🏭👨‍🏭👩‍💻👨‍💻👩‍💼👨‍💼👩‍🔧👨‍🔧👩‍🔬👨‍🔬👩‍🎨👨‍🎨👩‍🚒👨‍🚒👩‍✈️👨‍✈️👩‍🚀👨‍🚀👩‍⚖️👨‍⚖️👰🤵👸🤴🤶🎅🧙‍♀️🧙‍♂️🧝‍♀️🧝‍♂️🧛‍♀️🧛‍♂️🧟‍♀️🧟‍♂️🧞‍♀️🧞‍♂️🧜‍♀️🧜‍♂️🧚‍♀️🧚‍♂️👼🤰🤱🙇‍♀️🙇‍♂️💁‍♀️💁‍♂️🙅‍♀️🙅‍♂️🙆‍♀️🙆‍♂️🙋‍♀️🙋‍♂️🤦‍♀️🤦‍♂️🤷‍♀️🤷🏽‍♂️🙎‍♀️🙎‍♂️🙍‍♀️🙍‍♂️💇‍♀️💇‍♂️💆‍♀️💆‍♂️🧖‍♀️🧖‍♂️💅🤳💃🕺👯‍♀️👯‍♂️🕴🚶‍♀️🚶‍♂️🏃‍♀️🏃‍♂️👫👭👬💑👩‍❤️‍👩👨‍❤️‍👨💏👩‍❤️‍💋‍👩👨‍❤️‍💋‍👨👪👨‍👩‍👧👨‍👩‍👧‍👦👨‍👩‍👦‍👦👨‍👩‍👧‍👧👩‍👩‍👦👩‍👩‍👧👩‍👩‍👧‍👦👩‍👩‍👦‍👦👩‍👩‍👧‍👧👨‍👨‍👦👨‍👨‍👧👨‍👨‍👧‍👦👨‍👨‍👦‍👦👨‍👨‍👧‍👧👩‍👦👩‍👧👩‍👧‍👦👩‍👦‍👦👩‍👧‍👧👨‍👦👨‍👧👨‍👧‍👦👨‍👦‍👦👨‍👧‍👧🧥👚👕👖👔👗👙👘👠👡👢👞👟🧦🧤🧣🎩🧢👒🎓⛑👑👝👛👜💼🎒👓🕶🌂"
    
    static var smiliesAndPeople = [Character]()
    
    static func processEmojis() {
        smiliesAndPeople = []
        for character in _smiliesAndPeople {
            smiliesAndPeople.append(character)
        }
    }

}

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
    
    static let night = Theme(hexColor(from: "333742"),
                             hexColor(from: "111111"),
                             hexColor(from: "333742"),
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
