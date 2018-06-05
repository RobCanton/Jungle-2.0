//
//  ConfigurePostViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-02.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import Hero
import UIKit
import AVFoundation

class ConfigurePostViewController:UIViewController {
    
    var videoURL:URL!
    var header:ComposeHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = UIColor.white
        
        header = ComposeHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 144))
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        header.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: 144.0).isActive = true
        
        view.layoutIfNeeded()
        header.setVideo(url: videoURL)
        
        let backButton = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = UIColor.lightGray
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
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
