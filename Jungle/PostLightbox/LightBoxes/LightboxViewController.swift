//
//  FullscreenImageViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-27.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley
import DynamicButton
import Pastel

class LightboxViewController:UIViewController, ASPagerDelegate, ASPagerDataSource {
    
    var state = PostsStateController.State.empty
    
    var closeButton:DynamicButton!
    var moreButton:UIButton!
    var pagerNode:ASPagerNode!
    
    var initialIndex:Int?
    var context:ASBatchContext?
    
    var pushTransitionManager = PushTransitionManager()
    
    var dimView:UIView!
    var contentView:UIView!
    var pastelView:PastelView!
    var deviceInsets:UIEdgeInsets!
    
    var groupButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        deviceInsets = UIApplication.deviceInsets
        contentView = UIView(frame: view.bounds)
        view.addSubview(contentView)
        
        pagerNode = ASPagerNode()
        pagerNode.leadingScreensForBatching = 3
        pagerNode.backgroundColor = UIColor.clear
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.isHidden = true
        
        let pagerView = pagerNode.view
        contentView.addSubview(pagerView)
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pagerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        pagerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        pagerNode.reloadData()
    
        dimView = UIView(frame:contentView.bounds)
        dimView.backgroundColor = UIColor.black
        contentView.addSubview(dimView)
        dimView.isUserInteractionEnabled = false
        dimView.alpha = 0.0
        
        closeButton = DynamicButton(style: .close)
        closeButton.highlightStokeColor = UIColor.white
        closeButton.strokeColor = UIColor.white
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: deviceInsets.top).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.tintColor = UIColor.white
        closeButton.applyShadow(radius: 6.0, opacity: 0.3, offset: .zero, color: .black, shouldRasterize: false)
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        groupButton = UIButton(type: .custom)
        groupButton.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14)
        
        groupButton.layer.borderColor = UIColor.white.cgColor
        groupButton.layer.borderWidth = 1.5
        groupButton.layer.cornerRadius = 14
        groupButton.clipsToBounds = true
        groupButton.sizeToFit()
        
        groupButton.addTarget(self, action: #selector(openGroup), for: .touchUpInside)
        
        view.addSubview(groupButton)
        groupButton.translatesAutoresizingMaskIntoConstraints = false
        groupButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        groupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        groupButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        groupButton.widthAnchor.constraint(lessThanOrEqualToConstant: view.bounds.width - 64 * 2).isActive = true
        
        moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        moreButton.setImage(UIImage(named:"more_white"), for: .normal)
        moreButton.tintColor = UIColor.white
        view.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
    }
    
    @objc func handleMore() {
        let index = pagerNode.currentPageIndex
        guard index >= 0, index < state.posts.count else { return }
        let post = state.posts[pagerNode.currentPageIndex]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if post.isYourPost {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let confirmAlert = UIAlertController(title: "Delete post?", message: "This action is irreversible.\nIt can take up 15 minutes for a post to be completely deleted.", preferredStyle: .alert)
                let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.handleDismiss()
                    UploadService.deletePost(post) { success in }
                })
                confirmAlert.addAction(delete)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
                confirmAlert.addAction(cancel)
                self.present(confirmAlert, animated: true, completion: nil)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                let reportSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let inappropriate = UIAlertAction(title: "It's Inappropriate", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .inappropriate)
                })
                reportSheet.addAction(inappropriate)
                let spam = UIAlertAction(title: "It's Spam", style: .destructive, handler: { _ in
                    ReportService.reportPost(post, type: .spam)
                })
                reportSheet.addAction(spam)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
                reportSheet.addAction(cancel)
                self.present(reportSheet, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let initialIndex = initialIndex {
            DispatchQueue.main.async {
                let post = self.state.posts[initialIndex]
                if let group = GroupsService.groupsDict[post.groupID] {
                    self.setGroupButton(withGroup: group)
                }
                
                self.pagerNode.scrollToPage(at: initialIndex, animated: false)
                self.pagerNode.isHidden = false
                self.initialIndex = nil
            }
        } else {
            let index = self.pagerNode.currentPageIndex
            if index >= 0, index < self.state.posts.count {
                self.groupButton.isHidden = false
                let post = self.state.posts[pagerNode.currentPageIndex]
                if let group = GroupsService.groupsDict[post.groupID] {
                    self.setGroupButton(withGroup: group)
                }
            } else {
                self.groupButton.isHidden = true
            }
            
        }
        statusBarHidden = true
        UIView.animate(withDuration: 0.05, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cells = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
        if cells.count > 0 {
            cells[0].stopObservingPost()
            cells[0].observePost()
        }
    }


    func setCurrentCellVolume(_ volume:CGFloat) {
        let cellNodes = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
        if cellNodes.count > 0 {
            cellNodes[0].contentNode.videoNode.player?.volume = Float(volume)
        }
    }

    var statusBarHidden = false
    override var prefersStatusBarHidden: Bool {
        get {
            return statusBarHidden
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return state.posts.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let post = state.posts[index]
        if let group = GroupsService.groupsDict[post.groupID] {
            let cell = SinglePostCellNode(post: post,
                                          group: group,
                                          deviceInsets: deviceInsets)
            cell.delegate = self
            return cell
        }
        return ASCellNode()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        guard !state.endReached else { return }
        self.context = context
        DispatchQueue.main.async {
            let oldState = self.state
            let action = PostsStateController.Action.beginBatchFetch
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
        }
        
        fetchData(state: state) { posts in
            
            let action = PostsStateController.Action.endBatchFetch(posts: posts)
            let oldState = self.state
            self.state = PostsStateController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
            if self.state.isFirstLoad {
                let oldState = self.state
                self.state = PostsStateController.handleAction(.firstLoadComplete(), fromState: oldState)
            }
        }
    }
    
    fileprivate func renderDiff(_ oldState: PostsStateController.State) {
        
        self.pagerNode.performBatchUpdates({
            // Add or remove items
            let rowCountChange = state.posts.count - oldState.posts.count
            if rowCountChange > 0 {
                let indexPaths = (oldState.posts.count..<state.posts.count).map { index in
                    IndexPath(item: index, section: 0)
                }
                self.pagerNode.insertItems(at: indexPaths)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }
            
        }, completion: nil)

    }
    
    func fetchData(state:PostsStateController.State, completion: @escaping (_ posts:[Post])->()) {
        DispatchQueue.main.async {
            return completion([])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let centerX = offsetX + scrollView.bounds.width / 2
        
        let page = Int(centerX / scrollView.bounds.width)
        if page >= 0, page < state.posts.count {
            
            groupButton.isHidden = false
            let post = state.posts[page]
            if let group = GroupsService.groupsDict[post.groupID] {
                setGroupButton(withGroup: group)
            }
            moreButton.isHidden = false
        } else {
            groupButton.isHidden = true
            moreButton.isHidden = false
        }
        
    }
    
    func setGroupButton(withGroup group:Group) {
        if GroupsService.myGroupKeys[group.id] != nil {
            
            let attrStr = NSMutableAttributedString(string: "\(group.name) ✓", attributes: [
                NSAttributedStringKey.foregroundColor: UIColor(white: 0.15, alpha: 1.0),
                NSAttributedStringKey.font: Fonts.bold(ofSize: 13.0)
                ])
            
            attrStr.addAttribute(NSAttributedStringKey.font,
                                 value:  UIFont.boldSystemFont(ofSize: 13.0),
                                 range: NSRange(location: group.name.count + 1, length: 1))
            
            groupButton.setAttributedTitle(attrStr, for: .normal)
            groupButton.backgroundColor = UIColor.white
        } else {
            groupButton.setTitle(group.name, for: .normal)
            groupButton.setTitleColor(UIColor.white, for: .normal)
            
            let attrStr = NSMutableAttributedString(string: "\(group.name)", attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: Fonts.bold(ofSize: 13.0)
                ])
            
            groupButton.setAttributedTitle(attrStr, for: .normal)
            groupButton.backgroundColor = UIColor.clear
        }
    }
}

extension LightboxViewController : SinglePostDelegate {
    func postOpen(profile: Profile) {
        let controller = UserProfileViewController()
        controller.profile = profile
        pushTransitionManager.navBarHeight = nil
        controller.interactor = pushTransitionManager.interactor
        controller.transitioningDelegate = pushTransitionManager
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func openGroup() {
        let post = state.posts[pagerNode.currentPageIndex]
        guard let group = GroupsService.groupsDict[post.groupID] else { return }
        let controller = GroupViewController()
        controller.group = group
        pushTransitionManager.navBarHeight = nil
        controller.interactor = pushTransitionManager.interactor
        controller.transitioningDelegate = pushTransitionManager
        self.present(controller, animated: true, completion: nil)
    }
    
    func openTag(_ tag: String) {
        pushTransitionManager.navBarHeight = nil
        
        let vc = SearchViewController()
        vc.initialSearch = tag
        
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        self.present(vc, animated: true, completion: nil)
    }
    
    func openComments(_ post:Post, _ showKeyboard:Bool) {
        let commentsVC = pulleyViewController?.drawerContentViewController as! CommentsDrawerViewController
        commentsVC.setup(withPost: post, showKeyboard: showKeyboard)
        self.pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
    
    func searchLocation(_ locationStr:String) {
        pushTransitionManager.navBarHeight = nil
        let vc = SearchViewController()
        vc.initialSearch = locationStr
        
        vc.interactor = pushTransitionManager.interactor
        vc.transitioningDelegate = pushTransitionManager
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension LightboxViewController: PulleyPrimaryContentControllerDelegate {
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let progress = min(max((distance) / (view.bounds.height / 2), 0), 1)
        
        let reverseAlpha = 1 - progress
        closeButton.alpha = reverseAlpha
        moreButton.alpha = reverseAlpha
        groupButton.alpha = reverseAlpha
        
        let scale = 1 - 0.04 * progress
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 12 * progress
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        setCurrentCellVolume(1 - progress)
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        switch drawer.drawerPosition {
        case PulleyPosition.collapsed:
            let cells = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
            if cells.count > 0 {
                cells[0].contentNode.videoNode.play()
            }
            break
        case PulleyPosition.open:
            let cells = pagerNode.visibleNodes as? [SinglePostCellNode] ?? []
            if cells.count > 0 {
                cells[0].contentNode.videoNode.pause()
            }
            break
        default:
            break
        }
    }
}
