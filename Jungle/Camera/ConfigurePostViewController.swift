//
//  ConfigurePostViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AsyncDisplayKit

class ConfigurePostViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var videoURL:URL!
    var header:ComposeHeaderView!
    var tableNode = ASTableNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        let titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        titleView.backgroundImage.image = nil
        titleView.backgroundColor = currentTheme.backgroundColor
        titleView.titleLabel.text = "NEW POST"
        titleView.titleLabel.textColor = UIColor.black
        titleView.leftButton.setImage(UIImage(named:"back"), for: .normal)
        titleView.leftButton.tintColor = UIColor.black
        titleView.leftButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        tableNode.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorColor = currentTheme.highlightedBackgroundColor
        tableNode.view.showsVerticalScrollIndicator = true
        tableNode.view.delaysContentTouches = false
        tableNode.view.backgroundColor = hexColor(from: "#eff0e9")
        tableNode.view.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = ASCellNode()
        cell.style.height = ASDimension(unit: .points, value: 300)
        cell.backgroundColor = UIColor.blue
        return cell
    }
}


class ComposeHeaderView:UIView {
    
    var previewBox = UIView()
    var previewView = UIView()
    var stackView = UIStackView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        previewBox = UIView(frame: .zero)
        
        previewBox.backgroundColor = UIColor.clear
        addSubview(previewBox)
        previewBox.translatesAutoresizingMaskIntoConstraints = false
        previewBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        previewBox.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        previewBox.widthAnchor.constraint(equalToConstant: 96).isActive = true
        previewBox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        previewView = UIView(frame: .zero)
        
        previewView.backgroundColor = UIColor.blue
        previewBox.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.leadingAnchor.constraint(equalTo: previewBox.leadingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: previewBox.topAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: previewBox.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: previewBox.bottomAnchor).isActive = true
        
        previewView.layer.cornerRadius = 8.0
        previewView.clipsToBounds = true
        previewBox.clipsToBounds = false
        previewBox.applyShadow(radius: 4.0, opacity: 0.20, offset: CGSize(width: 0, height: 4.0), color: .black, shouldRasterize: false)
        
        let communityLabel = UILabel(frame: .zero)
        communityLabel.font = Fonts.semiBold(ofSize: 15.0)
        communityLabel.textColor = UIColor.black
        communityLabel.text = "Choose a community"
        
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        textView.font = Fonts.semiBold(ofSize: 15.0)
        textView.textColor = UIColor.gray
        
        stackView.addArrangedSubview(communityLabel)
        stackView.addArrangedSubview(textView)
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: previewBox.trailingAnchor, constant: 12).isActive = true
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        layoutIfNeeded()
    }
    
    func setVideo(url:URL) {
        let item = AVPlayerItem(url: url)
        
        let videoPlayer = AVPlayer()
        videoPlayer.replaceCurrentItem(with: item)
        
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(playerLayer, at: 0)
        
        playerLayer.player?.play()
        playerLayer.player?.actionAtItemEnd = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
