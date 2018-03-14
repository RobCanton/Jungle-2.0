//
//  ViewRepliesCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//


import Foundation
import AsyncDisplayKit
import UIKit

class ViewRepliesCellNode: ASCellNode {
    let spinner = SpinnerNode()
    
    var imageNode = ASRoundShadowedImageNode(imageCornerRadius: 12.0, imageShadowRadius: 0.0)
    var titleNode = ASTextNode()
    var dividerNode = ASDisplayNode()
    
    required init(reply: Reply) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        imageNode.style.width = ASDimension(unit: .points, value: 24)
        imageNode.style.height = ASDimension(unit: .points, value: 24)
        
        titleNode.tintColor = UIColor.gray
        titleNode.tintColorDidChange()
        
        setTitle(name: "SillyDeer", numReplies: reply.numReplies)
        
        dividerNode.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        
    }
    
    override func didLoad() {
        super.didLoad()
        spinner.activityIndicatorView.hidesWhenStopped = true
        spinner.activityIndicatorView.stopAnimating()
    }
    
    func fetching() {
        titleNode.isHidden = true
        imageNode.isHidden = true
        spinner.activityIndicatorView.startAnimating()
    }
    
    func setTitle(name:String, numReplies:Int) {
        let numRepliesStr = "\(numReplies) Replies"
        let str = "\(name) Replied · \(numRepliesStr)"
        let attributes = [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: UIColor.gray
        ]
        
        let title = NSMutableAttributedString(string: str, attributes: attributes) //1
        
        let usernameAttributes = [
            NSAttributedStringKey.font : Fonts.semiBold(ofSize: 12.0)
        ]
        title.addAttributes(usernameAttributes, range: NSRange(location: 0, length: name.characters.count))
        
        titleNode.attributedText = title
    }
    
//    func setMessageLabel(username:String, message:String, date: Date) {
//        let timeStr = " \(date.timeStringSinceNow())"
//        let str = "\(username)\(message)\(timeStr)"
//        let msg = message.utf16
//        let attributes: [String: AnyObject] = [
//            NSFontAttributeName : UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
//        ]
//
//        let title = NSMutableAttributedString(string: str, attributes: attributes) //1
//        let a: [String: AnyObject] = [
//            NSFontAttributeName : UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold),
//            ]
//        title.addAttributes(a, range: NSRange(location: 0, length: username.characters.count))
//
//
//        let a2: [String: AnyObject] = [
//            NSForegroundColorAttributeName : UIColor(white: 0.67, alpha: 1.0)
//        ]
//        title.addAttributes(a2, range: NSRange(location: username.characters.count + msg.count, length: timeStr.characters.count))
//
//        messageLabel.attributedText = title
//
//    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        dividerNode.style.height = ASDimension(unit: .points, value: 0.5)
        
        let centerImage = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: imageNode)
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [centerImage, centerTitle]
        horizontalStack.spacing = 8.0
        
        let mainInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 16 + 36 + 8, 4, 16), child: horizontalStack)
        let mainVerticalStack = ASStackLayoutSpec.vertical()
        mainVerticalStack.children = [mainInset, dividerNode]
        mainVerticalStack.spacing = 4.0
        
        let overlay = ASOverlayLayoutSpec(child: mainVerticalStack, overlay: spinner)
        return overlay
    }
    
}


