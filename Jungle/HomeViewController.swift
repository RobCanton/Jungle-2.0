//
//  HomeViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase


class HomeViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, HomeTitleDelegate {
    
    var pagerNode:ASPagerNode!
    var titleView:HomeTitleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = nil
        view.addSubview(pagerNode.view)
        
        titleView = UINib(nibName: "HomeTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeTitleView
        titleView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44.0)
        titleView.delegate = self
        view.addSubview(titleView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 44).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        pagerNode.reloadData()
   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.navigationBar.tintColor = UIColor.gray
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named:"Back"), style: .plain, target: nil, action: nil)
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = index % 2 == 0 ? UIColor.blue : UIColor.yellow
        
        var type:PostsTableType!
        switch index {
        case 0:
            type = .newest
            break
        case 1:
            type = .popular
            break
        case 2:
            type = .nearby
            break
        default:
            return cellNode
        }
        let controller = PostsTableViewController(type: type)
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        controller.view.frame = cellNode.bounds
        cellNode.addSubnode(controller.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagerNode.view else { return }
        let progress = scrollView.contentOffset.x / scrollView.contentSize.width
        titleView.setProgress(progress)
    }
    
    func scrollTo(header: HomeHeader) {
        switch header {
        case .home:
            pagerNode.scrollToPage(at: 0, animated: true)
            break
        case .popular:
            pagerNode.scrollToPage(at: 1, animated: true)
            break
        case .nearby:
            pagerNode.scrollToPage(at: 2, animated: true)
            break
        }
    }
}
