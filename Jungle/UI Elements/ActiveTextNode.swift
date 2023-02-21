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
    
    
    public func setBlockedText() {
        let title = "Content Blocked"
        let subtitle = "Contains muted word(s)."
        let str = "\(title)\n\(subtitle)"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let text = NSMutableAttributedString(string: str)
        text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: str.count))
        text.addAttribute(NSAttributedStringKey.font, value: Fonts.semiBold(ofSize: 15.0), range: NSRange(location: 0, length: title.count))
        text.addAttribute(NSAttributedStringKey.font, value: Fonts.regular(ofSize: 15.0), range: NSRange(location: title.count + 1, length: subtitle.count))
        self.attributedText = text
    }
    
    public func setText(text: String, withFont font: UIFont, normalColor: UIColor, activeColor: UIColor) {
        self.delegate = self
        self.isUserInteractionEnabled = true
        self.passthroughNonlinkTouches = true
        
        self.linkAttributeNames = [
            ActiveTextType.hashtag.rawValue,
            ActiveTextType.mention.rawValue,
            ActiveTextType.link.rawValue]
        let attributedString = NSMutableAttributedString(string: text)
        let count = attributedString.length
        
        //self.callBack = callBack
        self.attrString = attributedString
        self.textString = text
        
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: count))
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: normalColor, range: NSRange(location: 0, length: count))
        
        // Call a custom set Hashtag and Mention Attributes Function
        setAttrWithName(color: activeColor, text: text)
        
    }
    
    
    private func setAttrWithName(color: UIColor, text: String) {

        let textLength = text.utf16.count
        let textRange = NSRange(location: 0, length: textLength)
        
        let elements = RegexParser.getElements(from: text, with: RegexParser.hashtagPattern, range: textRange)
        //print("ELEMENTS: \(elements)")
        for element in elements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            attrString?.addAttributes([
                NSAttributedStringKey(rawValue: ActiveTextType.hashtag.rawValue): str,
                NSAttributedStringKey.foregroundColor: color
                ], range: element.range)
        }
        
        let mentionElements = RegexParser.getElements(from: text, with: RegexParser.mentionPattern, range: textRange)
        //print("ELEMENTS: \(elements)")
        for element in mentionElements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            attrString?.addAttributes([
                NSAttributedStringKey(rawValue: ActiveTextType.mention.rawValue): str,
                NSAttributedStringKey.foregroundColor: color
                ], range: element.range)
        }
        
        let linkElements = RegexParser.getElements(from: text, with: RegexParser.urlPattern, range: textRange)
        
        for element in linkElements {
            let range = Range(element.range, in: text)!
            let str = text.substring(with: range)
            attrString?.addAttributes([
                NSAttributedStringKey(rawValue: ActiveTextType.link.rawValue): str,
                NSAttributedStringKey.foregroundColor: color
                ], range: element.range)
        }
        
        self.attributedText = attrString
    }
    
    func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        print("LETS GET IT!")
        guard let textValue = value as? String else { return }
        switch attribute {
        case ActiveTextType.hashtag.rawValue:
            tapHandler?(.hashtag, textValue.removeWhitespaces())
            break
        case ActiveTextType.mention.rawValue:
            tapHandler?(.mention, textValue)
            break
        case ActiveTextType.link.rawValue:
            tapHandler?(.link, textValue.removeWhitespaces())
            break
        default:
            break
        }
    }
    
    func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
}
