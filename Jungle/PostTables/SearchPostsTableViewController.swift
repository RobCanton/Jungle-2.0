//
//  SearchPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-15.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class SearchPostsTableViewController: PostsTableViewController {
    
    var type:SearchType = .recent
    var searchText:String?
    var groupResults = [Group]()
    
    override func numberOfHeaderCells() -> Int {
        
        return groupResults.count > 0 ? groupResults.count + 1 : 0
    }
    
    override func headerCell(for indexPath: IndexPath) -> ASCellNode {
        if indexPath.row == groupResults.count {
            let cell = ASCellNode()
            cell.style.height = ASDimension(unit: .points, value: 16)
            cell.selectionStyle = .none
            return cell
        }
        let cell = FeaturedGroupCellNode(group: groupResults[indexPath.row])
        return cell
    }
    
    
    override func headerCell(didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < groupResults.count {
            openGroup(groupResults[indexPath.row])
        }
    }
    
    func openGroup(_ group:Group) {
        let controller = GroupViewController()
        controller.group = group
        pushTransitionManager.navBarHeight = nil
        controller.interactor = pushTransitionManager.interactor
        controller.transitioningDelegate = pushTransitionManager
        self.present(controller, animated: true, completion: nil)
    }
    
    
    override func lightBoxVC() -> LightboxViewController {
        let lightbox = SearchLightboxViewController()
        lightbox.type = type
        lightbox.searchText = searchText
        return lightbox
    }
    
    func setSearch(text:String?) {
        
        context?.cancelBatchFetching()
        state = .empty
        self.tableNode.reloadData()
        searchText = text
        if let text = text {
            searchGroups(text)
        }
        
    }
    
    override func handleRefresh() {
        context?.cancelBatchFetching()
        
        state = .empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            if let searchText = self.searchText {
                SearchService.searchFor(text: searchText, type: self.type, limit: 15, offset: self.state.posts.count) { posts in
                    
                    let action = PostsStateController.Action.endBatchFetch(posts: posts)
                    let oldState = self.state
                    self.state = PostsStateController.handleAction(action, fromState: oldState)
                    self.tableNode.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    func searchGroups(_ text:String) {
        let data:[String:Any] = [
            "text": text
        ]
        functions.httpsCallable("searchGroups").call(data) { results, error in
            if let data = results?.data as? [String:Any],
                let groupKeys = data["groups"] as? [String] {
                
                var groups = [Group]()
                for key in groupKeys {
                    if let group = GroupsService.groupsDict[key] {
                        groups.append(group)
                    }
                }
                self.groupResults = groups
                self.tableNode.performBatchUpdates({
                    self.tableNode.reloadSections(IndexSet(integer: 0), with: .automatic)
                }, completion: nil)
                
            }
        }
    }
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        if let searchText = searchText {
            SearchService.searchFor(text: searchText, type: type, limit: 15, offset: state.posts.count) { posts in
                
                completion(posts)
            }
        } else {
            super.fetchData(state: state, completion: completion)
        }
    }
}
