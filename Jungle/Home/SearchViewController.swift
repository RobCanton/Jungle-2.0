//
//  SearchViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class SearchViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, UITextFieldDelegate {
    
    var initialSearch:String?
    var pagerNode:ASPagerNode!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var searchTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldLeadingAnchor: NSLayoutConstraint!
    var latestPostsVC:SearchPostsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bubbleView.layer.cornerRadius = bubbleView.bounds.height / 2
        bubbleView.clipsToBounds = true
        textField.delegate = self
        pagerNode = ASPagerNode()
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.backgroundColor = nil
        contentView.addSubview(pagerNode.view)
        
        let layoutGuide = contentView.safeAreaLayoutGuide
        pagerNode.view.translatesAutoresizingMaskIntoConstraints = false
        pagerNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        pagerNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        pagerNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        pagerNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0.0).isActive = true
        pagerNode.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let search = initialSearch {
            textField.text = search
            let width = textWidth
            
            var leadingConstant:CGFloat = 12.0
            let bubbleWidth = bubbleView.bounds.width - 24.0
            if width < bubbleWidth {
                leadingConstant += (bubbleWidth - width) / 2
            }
            self.textFieldLeadingAnchor.constant = leadingConstant
            self.view.layoutIfNeeded()
            latestPostsVC?.setSearch(text: search)
            initialSearch = nil
        }
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.frame = contentView.bounds
        
        latestPostsVC = SearchPostsViewController()
        latestPostsVC.willMove(toParentViewController: self)
        self.addChildViewController(latestPostsVC)
        latestPostsVC.view.frame = contentView.bounds
        cellNode.addSubnode(latestPostsVC.node)
        let layoutGuide = cellNode.view.safeAreaLayoutGuide
        latestPostsVC.view.translatesAutoresizingMaskIntoConstraints = false
        latestPostsVC.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        latestPostsVC.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        latestPostsVC.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        latestPostsVC.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0.0).isActive = true
        
        return cellNode
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 1
    }
    @IBAction func handleDismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func handleCancel(_ sender: Any) {
        self.textField.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //textField.textAlignment = .left
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.searchLeadingAnchor.constant = 12.0
            self.searchTrailingAnchor.constant = 72.0
            self.textFieldLeadingAnchor.constant = 12.0
            self.view.layoutIfNeeded()
            self.backButton.alpha = 0.0
            self.cancelButton.alpha = 1.0
        }, completion: nil)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textField.textAlignment = .center
        
        let width = textWidth
        
        var leadingConstant:CGFloat = 12.0
        let bubbleWidth = bubbleView.bounds.width - 24.0
        if width < bubbleWidth {
            leadingConstant += (bubbleWidth - width) / 2
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.searchLeadingAnchor.constant = 44.0
            self.searchTrailingAnchor.constant = 44.0
            self.textFieldLeadingAnchor.constant = leadingConstant
            self.view.layoutIfNeeded()
            self.backButton.alpha = 1.0
            self.cancelButton.alpha = 0.0
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        latestPostsVC?.setSearch(text: textField.text)
        return true
    }
    
    var textWidth:CGFloat {
        return UILabel.size(text: textField.text ?? "", height: 44.0, font: Fonts.regular(ofSize: 16.0)).width
    }
    
}
