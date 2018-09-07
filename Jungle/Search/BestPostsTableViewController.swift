//
//  LeaderboardViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-06.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley

class BestPostsTableViewController: PostsTableViewController {
    
    var featuredGroups = [Group]()
    
    override func headerCell(for indexPath: IndexPath) -> ASCellNode {
        let group = featuredGroups[indexPath.row]
        if indexPath.row == 0 {
            let cell = FeaturedGroupBannerCellNode(group: group)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = FeaturedGroupCellNode(group: group)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func numberOfHeaderCells() -> Int {
        return featuredGroups.count
    }
    
    override func headerCell(didSelectRowAt indexPath: IndexPath) {
        let group = featuredGroups[indexPath.row]
        
        let bannerCell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupBannerCellNode
        bannerCell?.setHighlighted(true)
        
        let cell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupCellNode
        cell?.setHighlighted(true)
        openGroup(group)
    }
    
    override func headerCell(didDeselectRowAt indexPath: IndexPath) {
        let bannerCell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupBannerCellNode
        bannerCell?.setHighlighted(false)
        
        let cell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupCellNode
        cell?.setHighlighted(false)
    }
    
    override func headerCell(didHighlightRowAt indexPath: IndexPath) {
        let bannerCell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupBannerCellNode
        bannerCell?.setHighlighted(true)
        
        let cell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupCellNode
        cell?.setHighlighted(true)
    }
    
    override func headerCell(didUnhighlightRowAt indexPath: IndexPath) {
        let bannerCell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupBannerCellNode
        bannerCell?.setHighlighted(false)
        
        let cell = tableNode.nodeForRow(at: indexPath) as? FeaturedGroupCellNode
        cell?.setHighlighted(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = hexColor(from: "#EFEFEF")
        tableNode.backgroundColor = hexColor(from: "#EFEFEF")
    }
    
    override func handleRefresh() {
        reloadGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if featuredGroups.count == 0 {
            reloadGroups()
        }
    }
    
    func reloadGroups() {
        var _groups = [Group]()
        for groupID in GroupsService.trendingGroupKeys {
            if let group = GroupsService.groupsDict[groupID] {
                _groups.append(group)
            }
        }
        
        featuredGroups = _groups
        refreshControl.endRefreshing()
        tableNode.reloadData()
    }
    
    func openGroup(_ group:Group) {
        let controller = GroupViewController()
        controller.group = group
        pushTransitionManager.navBarHeight = nil
        controller.interactor = pushTransitionManager.interactor
        controller.transitioningDelegate = pushTransitionManager
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
}
