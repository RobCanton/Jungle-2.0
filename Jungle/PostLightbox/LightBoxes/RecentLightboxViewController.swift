//
//  RecentLightboxViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley
import DynamicButton
import Pastel

class RecentLightboxViewController:LightboxViewController {
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getRecentPosts(lastPost: state.posts.last , completion: completion)
    }
}

class PopularLightboxViewController:LightboxViewController {
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        PostsService.getPopularPosts(offset: state.posts.count, completion: completion)
    }
}

class NearbyLightboxViewController:LightboxViewController {
    var proximity:UInt = 0
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.searchNearby(proximity: proximity, offset: state.posts.count, completion: completion)
    }
}

class SearchLightboxViewController:LightboxViewController {
    var type:SearchType = .popular
    var searchText:String?
    var initialSearch:String?
    var initialPosts:[Post]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let search = initialSearch, let posts = initialPosts {
            self.state = PostsStateController.handleAction(.endBatchFetch(posts: posts), fromState: .empty)
            context?.cancelBatchFetching()
            self.pagerNode.reloadData()
            searchText = search
            initialSearch = nil
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

class MyPostsLightboxViewController:LightboxViewController {
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.myPosts(offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}

class MyCommentsLightboxViewController:LightboxViewController {
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.myComments(offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}
class MyLikesLightboxViewController:LightboxViewController {
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.likedPosts(offset: self.state.posts.count) { posts in
            completion(posts)
        }
    }
}

class UserPostsLightboxViewController:LightboxViewController {
    var username:String!
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.userPosts(username: username, offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}

class UserCommentsLightboxViewController:LightboxViewController {
    var username:String!
    
    override func fetchData(state: PostsStateController.State, completion: @escaping ([Post]) -> ()) {
        SearchService.userComments(username: username, offset: state.posts.count) { posts in
            completion(posts)
        }
    }
}

