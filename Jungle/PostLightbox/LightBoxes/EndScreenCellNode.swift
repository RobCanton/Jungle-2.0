//
//  EndScreenCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-10.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class EndScreenCellNode:ASCellNode {
    
    var imageNode = ASNetworkImageNode()
    var contentNode = ASDisplayNode()
    var titleNode = ASTextNode()
    
    var descNode = ASTextNode()
    var joinButton = ASButtonNode()
    var joinSpinner = SpinnerNode()
    weak var group:Group?
    required init(group:Group) {
        super.init()
        self.group = group
        backgroundColor = UIColor.black
        self.automaticallyManagesSubnodes = true
        
        imageNode.url = group.avatar_high
        imageNode.alpha = 0.35
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        titleNode.textContainerInset = UIEdgeInsetsMake(0, 32, 0, 32)
        titleNode.attributedText = NSAttributedString(string: group.name, attributes: [
            NSAttributedStringKey.font: Fonts.extraBold(ofSize: 24),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        
        descNode.textContainerInset = UIEdgeInsetsMake(0, 32, 0, 32)
        descNode.attributedText = NSAttributedString(string: group.desc, attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 16),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        
        joinSpinner.activityIndicatorView.activityIndicatorViewStyle = .white
        joinSpinner.activityIndicatorView.hidesWhenStopped = true
        joinSpinner.stopAnimating()
        joinButton.setTitle("Join Group", with: Fonts.bold(ofSize: 16.0), with: UIColor.white, for: .normal)
        joinButton.style.height = ASDimension(unit: .points, value: 32.0)
        joinButton.layer.cornerRadius = 16.0
        joinButton.layer.borderColor = UIColor.white.cgColor
        joinButton.layer.borderWidth = 1.5
        joinButton.clipsToBounds = true
        joinButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16)
        contentNode.automaticallyManagesSubnodes = true
        contentNode.layoutSpecBlock = { _, _ in
            
            let spinnerCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.joinSpinner)
            let spinnerOverlay = ASOverlayLayoutSpec(child: self.joinButton, overlay: spinnerCenter)
            let joinCenter = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: spinnerOverlay)
            let joinInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8, 0, 0, 0), child: joinCenter)
            
            let stack = ASStackLayoutSpec.vertical()
            
            stack.children = [self.titleNode,
                              self.descNode,
                              joinInset]
            return stack
        }
        
        joinButton.addTarget(self, action: #selector(toggleJoin), forControlEvents: .touchUpInside)
        
    }
    override func didLoad() {
        super.didLoad()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: contentNode)
        return ASOverlayLayoutSpec(child: imageNode, overlay: contentCenter)
    }
    
    @objc func toggleJoin() {
        guard let group = self.group else { return }
        
        joinButton.isEnabled = false
        joinButton.setTitle(joinButton.titleNode.attributedText?.string ?? "", with: Fonts.bold(ofSize: 16.0), with: UIColor.clear, for: .normal)
        joinButton.backgroundColor = UIColor.clear
        joinSpinner.startAnimating()
        
        if GroupsService.myGroupKeys[group.id] != nil {
            GroupsService.leaveGroup(id: group.id) { _ in
                self.refreshJoinButton()
            }
        } else {
            GroupsService.joinGroup(id: group.id) { _ in
                self.refreshJoinButton()
            }
        }
        
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        refreshJoinButton()
    }
    
    func refreshJoinButton() {
        guard let group = self.group else { return }
        joinSpinner.stopAnimating()
        joinButton.isEnabled = true
        if GroupsService.myGroupKeys[group.id] == true {
            joinButton.setTitle("Joined ✓", with: Fonts.bold(ofSize: 16.0), with: UIColor(white: 0.15, alpha: 1.0), for: .normal)
            joinButton.backgroundColor = UIColor.white
        } else {
            joinButton.setTitle("Join Group", with: Fonts.bold(ofSize: 16.0), with: UIColor.white, for: .normal)
            joinButton.backgroundColor = UIColor.clear
        }
    }
}
