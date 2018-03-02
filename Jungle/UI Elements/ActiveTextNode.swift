//
//  ActiveTextNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-22.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit

enum ActiveTextType:String {
    case hashtag = "hashtag"
    case mention = "mention"
    case link = "link"
}


class ActiveTextNode:ASTextNode, ASTextNodeDelegate {
    
    var textString: String?
    var attrString: NSMutableAttributedString?
    
    var tapHandler:((_ type: ActiveTextType, _ value: String)->())?
    
    
    public func setText(text: String, withFont font: UIFont, normalColor: UIColor, activeColor: UIColor) {
        self.delegate = self
        self.isUserInteractionEnabled = true
        self.passthroughNonlinkTouches = true
        
        self.linkAttributeNames = [ActiveTextType.hashtag.rawValue, ActiveTextType.mention.rawValue]
        
        let attributedString = NSMutableAttributedString(string: text)
        let count = attributedString.length
        
        //self.callBack = callBack
        self.attrString = attributedString
        self.textString = text
        
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: count))
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: normalColor, range: NSRange(location: 0, length: count))
        
        // Call a custom set Hashtag and Mention Attributes Function
        setAttrWithName(attrName: ActiveTextType.hashtag.rawValue, wordPrefix: "#", color: activeColor, text: text, font: font)
        setAttrWithName(attrName: ActiveTextType.mention.rawValue, wordPrefix: "@", color: activeColor, text: text, font: font)
        setAttrWithName(attrName: ActiveTextType.link.rawValue, wordPrefix: "http://", color: activeColor, text: text, font: font)
        setAttrWithName(attrName: ActiveTextType.link.rawValue, wordPrefix: "https://", color: activeColor, text: text, font: font)
        
    }
    
    
    private func setAttrWithName(attrName: String, wordPrefix: String, color: UIColor, text: String, font: UIFont) {
//        //Words can be separated by either a space or a line break
//        let charSet = CharacterSet(charactersIn: " \n")
//        let words = text.components(separatedBy: charSet)
//
//        //Filter to check for the # or @ prefix
//        for word in words.filter({$0.hasPrefix(wordPrefix)}) {
//            let range = textString!.range(of: word)!
//            let nsRange = NSRange(range, in: textString!)
//            attrString?.addAttributes([NSAttributedStringKey(rawValue: attrName): word,
//                                       NSAttributedStringKey.foregroundColor: color], range: nsRange)
//        }
//        self.attributedText = attrString

        var textLength = text.utf16.count
        var textRange = NSRange(location: 0, length: textLength)
        let elements = getElements(from: text, with: "(?:^|\\s|$)#[\\p{L}0-9_]*", range: textRange)
        //print("ELEMENTS: \(elements)")
        for element in elements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            print("ELEMENT: \(range) -> \(str)")
            attrString?.addAttributes([NSAttributedStringKey(rawValue: attrName): str,
                                                  NSAttributedStringKey.foregroundColor: color], range: element.range)
            
        }
                self.attributedText = attrString
    }
    
    func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }
    
    func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            return createdRegex
        } else {
            return nil
        }
    }
    
    func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        
        guard let textValue = value as? String else { return }
        print("TAPPED: \(textValue)")
        switch attribute {
        case ActiveTextType.hashtag.rawValue:
            
            tapHandler?(.hashtag, textValue)
            break
        case ActiveTextType.mention.rawValue:
            tapHandler?(.mention, textValue)
            break
        case ActiveTextType.link.rawValue:
            tapHandler?(.link, textValue)
            break
        default:
            break
        }
    }
}
