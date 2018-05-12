//
//  ProfileViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-10.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class ProfileViewController:UIViewController, ASTableDelegate, ASTableDataSource {

    var tableNode = ASTableNode()
    
    var profileHeader:ProfileHeaderView!
    var headerTopAnchor:NSLayoutConstraint!
    var headerHeightAnchor:NSLayoutConstraint!
    
    private let headerHeight:CGFloat = 350.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -20.0).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        tableNode.view.showsVerticalScrollIndicator = false
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.contentInsetAdjustmentBehavior = .never
        
        tableNode.reloadData()
        
        let tableGuide = tableNode.view.safeAreaLayoutGuide
        
        profileHeader = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        tableNode.view.tableHeaderView = nil
        tableNode.view.addSubview(profileHeader)
        
        profileHeader.leadingAnchor.constraint(equalTo: tableGuide.leadingAnchor).isActive = true
        profileHeader.trailingAnchor.constraint(equalTo: tableGuide.trailingAnchor).isActive = true
        headerTopAnchor = profileHeader.topAnchor.constraint(equalTo: tableGuide.topAnchor, constant: -20.0)
        headerTopAnchor.isActive = true
        headerHeightAnchor = profileHeader.heightAnchor.constraint(equalToConstant: headerHeight)
        headerHeightAnchor.isActive = true
        
        tableNode.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
        tableNode.contentOffset = CGPoint(x: 0, y: -headerHeight)
        tableNode.view.separatorStyle = .none
        updateHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileHeader.setLevelProgress(0.67)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = ASTextCellNode()
        cell.text = "Row #\(indexPath.row)"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeader()
    }
    
    func updateHeader() {
        var progress:CGFloat = 1.0
        if tableNode.contentOffset.y < -headerHeight {
            
            headerHeightAnchor.constant = -tableNode.contentOffset.y
        } else {
            //print("Offset: \(-tableNode.contentOffset.y)")
            progress = (-tableNode.contentOffset.y - 108) / (headerHeight - 108)
            headerHeightAnchor.constant = max(-tableNode.contentOffset.y, 108)
            
        }
        print("HEADERHEIGHT: \(headerHeightAnchor.constant)")
        profileHeader.updateProgress(max(progress,0))
        //let progress =
    }
}

class ProfileCellNode:ASCellNode {
    
    var imageContainer = ASDisplayNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = accentColor
        imageContainer.backgroundColor = UIColor.blue
        imageContainer.layer.cornerRadius = 24
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        style.height = ASDimension(unit: .points, value: 240.0)
        imageContainer.style.width = ASDimension(unit: .points, value: 48.0)
        imageContainer.style.height = ASDimension(unit: .points, value: 48.0)
        let centerImage = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: imageContainer)
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(23, 0, 23, 0), child: centerImage)
        return inset
    }
}
