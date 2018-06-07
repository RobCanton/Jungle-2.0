//
//  PopularPostsTableViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-20.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class PopularPostsTableViewController: PostsTableViewController {
 
    override func handleRefresh() {
    }
    
    override func fetchData(state: PostsTableViewController.State, completion: @escaping ([Post], Bool) -> ()) {
        PostsService.getPopularPosts(existingKeys: state.postKeys, lastScore: state.lastScore, completion: completion)
    }
}
