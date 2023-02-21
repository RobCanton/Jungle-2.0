//
//  GroupsTableNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-07-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

//class GroupsTableNode:ASTableNode, ASTableDelegate, ASTableDataSource {
//    
//    
//    override init(style: UITableViewStyle) {
//        super.init(style: style)
//        backgroundColor = UIColor.clear
//        delegate = self
//        dataSource = self
//        reloadData()
//        
//    }
//    
//    override func didLoad() {
//        super.didLoad()
//        view.separatorStyle = .none
//    }
//    
//    func numberOfSections(in tableNode: ASTableNode) -> Int {
//        return 1
//    }
//    
//    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
//        return 12
//    }
//    
//    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
//        let cell = GroupCellNode(title: "Cell \(indexPath.row)")
//        return cell
//    }
//}
//
//class GroupCellNode:ASCellNode {
//    var titleNode = ASTextNode()
//    required init(title:String) {
//        super.init()
//        automaticallyManagesSubnodes = true
//        titleNode.attributedText = NSAttributedString(string: title, attributes: [
//            NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0),
//            NSAttributedStringKey.foregroundColor: UIColor.white
//            ])
//    }
//    
//    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 24, 12, 24), child: titleNode)
//    }
//}

