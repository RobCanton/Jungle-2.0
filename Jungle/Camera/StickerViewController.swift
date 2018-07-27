//
//  StickerDrawerViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-05.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Pulley



public extension UIViewController {
    
    /// If this viewController pertences to a PulleyViewController, return it.
    public var pulleyViewController: PulleyViewController? {
        var parentVC = parent
        while parentVC != nil {
            if let pulleyViewController = parentVC as? PulleyViewController {
                return pulleyViewController
            }
            parentVC = parentVC?.parent
        }
        return nil
    }
}


class StickerViewController:UIViewController, ASCollectionDelegate, ASCollectionDataSource {
    var collectionNode:ASCollectionNode!
    var addSticker: ((_ sticker:UIImage)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurView.frame = view.bounds
//        view.addSubview(blurView)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width/2, height: view.bounds.width/2)
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.clear
        let collectionView = collectionNode.view
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.layoutIfNeeded()
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pulleyViewController?.setDrawerPosition(position: .collapsed, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.pulleyViewController?.bounceDrawer()
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return StickerService.packs.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let cell = StickerCellNode(stickerPack: StickerService.packs[indexPath.row])
        cell.style.width = ASDimension(unit: .points, value: collectionNode.bounds.width / 2)
        cell.style.height = ASDimension(unit: .points, value: collectionNode.bounds.width / 2)
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        let cell = collectionNode.nodeForItem(at: indexPath) as! StickerCellNode
        addSticker?(cell.imageNode.image!)
    }
}

class StickerCellNode:ASCellNode {
    var imageNode = ASNetworkImageNode()
    var titleNode = ASTextNode()
    required init(stickerPack:StickerPack) {
        super.init()
        
        automaticallyManagesSubnodes = true
        //imageNode.image = sticker
        imageNode.url = stickerPack.url
        imageNode.contentMode = .scaleAspectFit
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        titleNode.attributedText = NSAttributedString(string: stickerPack.name, attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
       
        let vStack = ASStackLayoutSpec.vertical()
        let imageInset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 12, 12, 12), child: imageNode)
        imageInset.style.flexGrow = 1.0
        titleNode.style.flexShrink = 1.0
         titleNode.style.height = ASDimension(unit: .fraction, value: 0.25)
        imageInset.style.height = ASDimension(unit: .fraction, value: 0.75)
        vStack.children = [imageInset,titleNode]
        vStack.spacing = 0.0
        
        return vStack
    }
}

extension StickerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return view.bounds.height * 3/5 + bottomSafeArea
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        self.collectionNode.view.isScrollEnabled = drawer.drawerPosition == .open
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }

}
