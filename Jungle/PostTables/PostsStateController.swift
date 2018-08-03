//
//  PostsController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-08-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class PostsStateController {
    
    struct State {
        var posts: [Post]
        var fetchingMore: Bool
        var endReached:Bool
        var isFirstLoad:Bool
        static let empty = State(posts: [], fetchingMore: false, endReached: false, isFirstLoad: true)
    }
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(posts: [Post])
        case insertNewBatch(posts: [Post])
        case removePost(at:Int)
        case firstLoadComplete()
    }
    
    static func handleAction(_ action: Action, fromState state: State) -> State {
        var state = state
        switch action {
        case .beginBatchFetch:
            state.fetchingMore = true
            break
        case let .endBatchFetch(posts):
            state.endReached = posts.count == 0
            state.posts.append(contentsOf: posts)
            state.fetchingMore = false
            break
        case let .insertNewBatch(posts):
            state.posts.insert(contentsOf: posts, at: 0)
            break
        case let .removePost(at):
            state.posts.remove(at: at)
            break
        case .firstLoadComplete:
            state.isFirstLoad = false
            break
        }
        return state
    }
}
