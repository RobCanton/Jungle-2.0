//
//  GroupViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import MXParallaxHeader
import Firebase

class GroupViewController:UIViewController, ASPagerDelegate, ASPagerDataSource, MXScrollViewDelegate {
    
    var interactor:Interactor? = nil
    var group:Group!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let percentThreshold:CGFloat = 0.3
        let verticalMovement = translation.x / view.bounds.width
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.shouldFinish = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    lazy var scrollView = MXScrollView()
    var pagerNode = ASPagerNode()
    
    var headerView:GroupHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameHeight = UILabel.size(text: group.name,
                                       width: view.bounds.width - 88,
                                       font: Fonts.bold(ofSize: 20.0)).height
        let nameHeightWithPadding = nameHeight > 0 ? nameHeight + 12 : 0
        
        let descHeight = UILabel.size(text: group.desc,
                                      width: view.bounds.width - 48,
                                      font: Fonts.light(ofSize: 14.0)).height
        
        
        let descHeightWithPadding = descHeight > 0 ? descHeight + 12 : 0
        view.backgroundColor = UIColor.white
        let topInset = UIApplication.deviceInsets.top
        let bottomheight = descHeightWithPadding + 44 + 32.0 - 8
        let x:CGFloat = 100 + (nameHeight - 10) + bottomheight
        headerView = GroupHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: x + 50  + 32 + topInset), topInset: topInset, nameHeight: nameHeightWithPadding, descHeight: descHeightWithPadding, includeAvatar: false)
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = x + 50  + 32 + topInset
        scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        scrollView.parallaxHeader.minimumHeight = 50 + topInset
        scrollView.delegate = self
        headerView.backgroundColor = accentColor
        
        if scrollView.superview == nil {
            view.addSubview(scrollView)
        }
        
        pagerNode.view.frame = CGRect(x: 0, y: 0,
                                      width: view.bounds.width,
                                      height: view.bounds.height - (50 + 32 + topInset))
        if pagerNode.view.superview == nil {
            scrollView.addSubview(pagerNode.view)
        }
        pagerNode.setDelegate(self)
        pagerNode.setDataSource(self)
        pagerNode.reloadData()
        
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
        view.isUserInteractionEnabled = true
        
        headerView.titleView.leftButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        headerView.titleView.rightButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
        //headerView.tabScrollView.delegate = self
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = view.frame
        scrollView.frame = frame
        scrollView.contentSize = frame.size
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        headerView.setGroup(group)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        
        let cellNode = ASCellNode()
        
        cellNode.frame = pagerNode.bounds
        cellNode.backgroundColor = hexColor(from: "#EFEFEF")
        var controller:PostsTableViewController!
        switch index {
        case 0:
            controller = GroupPostsTableViewController(groupID: group.id)
            break
        case 1:
            controller = GroupPostsTableViewController(groupID: group.id)
            break
        default:
            break
        }
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
    // MARK: - Table view data source
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let progress = scrollView.parallaxHeader.progress
            
            if progress.isNaN {
                return
            }
            
            headerView.setProgress(progress)
        } else if scrollView == self.pagerNode.view {
            let offsetX = scrollView.contentOffset.x
            let viewWidth = view.bounds.width
            let progress = offsetX / viewWidth
            //headerView.tabScrollView.setProgress(progress, index: 0)
        }
    }
    
    @objc func handleMore() {
        print("HANDLE IT!")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
            let reportAlert = UIAlertController(title: "Why are you reporting this group?", message: "", preferredStyle: .alert)
            reportAlert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = ""
            }
            let saveAction = UIAlertAction(title: "Send", style: .default, handler: { action in
                let textField = reportAlert.textFields![0] as UITextField
                let text = textField.text
                
                let ref = database.child("groups/reports/\(self.group.id)/\(uid)")
                let report:[String:Any] = [
                    "message": text ?? "",
                    "timestamp": [".sv" : "timestamp"]
                ]
                
                ref.setValue(report) { error, ref in
                    if let _ = error {
                        Alerts.showFailureAlert(withMessage: "Failed to send report.")
                    } else {
                        Alerts.showSuccessAlert(withMessage: "Report sent!")
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            reportAlert.addAction(saveAction)
            reportAlert.addAction(cancelAction)
            
            self.present(reportAlert, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension GroupViewController: TabScrollDelegate {
    func tabScrollTo(index: Int) {
        pagerNode.scrollToPage(at: index, animated: true)
    
    }
}

