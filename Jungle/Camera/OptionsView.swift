//
//  OptionsView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-31.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol OptionsDelgate:class {
    func didSelectGroup(_ group:Group?)
    func didSelectNewGroup()
}

class OptionsView:UIView, ASTableDelegate, ASTableDataSource {
    
    var tableNode:ASTableNode!
    
    weak var delegate:OptionsDelgate?
    
    var myGroups = [Group]()
    var groups = [Group]()
    
    var region:Region? {
        didSet {
            if let locationNode = locationNode{
                locationNode.region = region
            }
        }
    }
    //var isCreatingNewGroup = false
    var locationNode:MyLocationCellNode!
    
    var includeLocation:Bool {
        return locationNode.includeLocation
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        self.layer.cornerRadius = 8
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.clipsToBounds = true
        
        tableNode = ASTableNode()
        addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.backgroundColor = UIColor.clear
        tableNode.view.separatorStyle = .none
        tableNode.view.showsVerticalScrollIndicator = false
        
        locationNode = MyLocationCellNode(isTop: true, isBottom: true)
        
        locationNode.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 60)
        tableNode.view.tableHeaderView = locationNode.view
        locationNode.region = self.region
        tableNode.contentInset = UIEdgeInsetsMake(0, 0, 16, 0)
        
        loadGroups()
    }
    
    func loadGroups() {
        GroupsService.sortGroups()
        myGroups = GroupsService.myGroups
        groups = GroupsService.allGroups
        tableNode.reloadData()
    }
    
    func selectGroup(_ group:Group) {
        for i in 0..<myGroups.count {
            if myGroups[i].id == group.id {
                let indexPath = IndexPath(row: i, section:2)
                tableNode.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                tableNode(tableNode, didSelectRowAt: indexPath)
                return
            }
        }
        
        for j in 0..<groups.count {
            if groups[j].id == group.id {
                let indexPath = IndexPath(row: j, section:4)
                tableNode.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                tableNode(tableNode, didSelectRowAt: indexPath)
                return
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 5
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return myGroups.count > 0 || GroupsService.createdGroupKeys.count == 0 ? 1 : 0
        case 2:
            var count = myGroups.count
//            if GroupsService.createdGroupKeys.count == 0 {
//                count += 1
//            }
            return count + 1
        case 3:
            return groups.count > 0 ? 1 : 0
        case 4:
            return groups.count
        default:
            return 0
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        switch indexPath.section {
        case 0:
            return ASCellNode()
        case 1:
            let cell = ASTextCellNode()
            cell.text = "MY GROUPS"
            cell.textInsets = UIEdgeInsetsMake(8, 2, 4, 2)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            cell.textAttributes = [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5),
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
            
            return cell
        case 2:
            if indexPath.row == myGroups.count {
                let cell = GroupCellNode(isTop: myGroups.count == 0,
                                         isBottom: true,
                                         group: nil)
                cell.selectionStyle = .none
                return cell
            }
            let cell = GroupCellNode(isTop: indexPath.row == 0,
                                     isBottom: false,
                                     group: myGroups[indexPath.row])
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = ASTextCellNode()
            cell.text = "ALL GROUPS"
            cell.textInsets = UIEdgeInsetsMake(8, 2, 4, 2)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            cell.textAttributes = [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5),
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
            return cell
        case 4:
            let cell = GroupCellNode(isTop: indexPath.row == 0,
                                     isBottom: indexPath.row == groups.count - 1,
                                     group: groups[indexPath.row])
            cell.selectionStyle = .none
            return cell
        default:
            return ASCellNode()
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? GlassCellNode
        cell?.setHighlighted(true)
        switch indexPath.section {
        case 2:
            if indexPath.row == myGroups.count {
                tableNode.deselectRow(at: indexPath, animated: true)
                let cell = tableNode.nodeForRow(at: indexPath) as? GlassCellNode
                cell?.setHighlighted(false)
                delegate?.didSelectGroup(nil)
                delegate?.didSelectNewGroup()
            } else {
                delegate?.didSelectGroup(myGroups[indexPath.row])
            }
            break
        case 4:
            delegate?.didSelectGroup(groups[indexPath.row])
            break
        default:
            break
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? GlassCellNode
        cell?.setHighlighted(false)
        delegate?.didSelectGroup(nil)
    }
    
    func tableNode(_ tableNode: ASTableNode, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? GlassCellNode
        cell?.setHighlighted(true)
    }
    
    func tableNode(_ tableNode: ASTableNode, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath) as? GlassCellNode
        cell?.setHighlighted(false)
    }

}
