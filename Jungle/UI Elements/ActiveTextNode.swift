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
    
    
    public func setText(text: String, withSize size: CGFloat, normalColor: UIColor, activeColor: UIColor) {
        self.delegate = self
        self.isUserInteractionEnabled = true
        self.passthroughNonlinkTouches = true
        
        self.linkAttributeNames = [ActiveTextType.hashtag.rawValue, ActiveTextType.mention.rawValue]
        let attributedString = NSMutableAttributedString(string: text)
        let count = attributedString.length
        
        //self.callBack = callBack
        self.attrString = attributedString
        self.textString = text
        
        let font = Fonts.medium(ofSize: size)
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: count))
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: normalColor, range: NSRange(location: 0, length: count))
        
        // Call a custom set Hashtag and Mention Attributes Function
        setAttrWithName(color: activeColor, text: text, size: size)
        
    }
    
    
    private func setAttrWithName(color: UIColor, text: String, size: CGFloat) {

        let textLength = text.utf16.count
        let textRange = NSRange(location: 0, length: textLength)
        
        let elements = RegexParser.getElements(from: text, with: RegexParser.hashtagPattern, range: textRange)
        //print("ELEMENTS: \(elements)")
        for element in elements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            attrString?.addAttributes([NSAttributedStringKey.font: Fonts.semiBold(ofSize: size)], range: element.range)
        }
        
        let mentionElements = RegexParser.getElements(from: text, with: RegexParser.mentionPattern, range: textRange)
        //print("ELEMENTS: \(elements)")
        for element in mentionElements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            attrString?.addAttributes([NSAttributedStringKey.foregroundColor: color], range: element.range)
            
        }
        
        self.attributedText = attrString
    }
    
    func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        
        guard let textValue = value as? String else { return }
        switch attribute {
        case ActiveTextType.hashtag.rawValue:
            let hasthag = textValue.removeWhitespaces()
            tapHandler?(.hashtag, hasthag)
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
    
    func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
}
