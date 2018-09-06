//
//  GroupsSwiperView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-06.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Koloda

class GroupsSwiperView: UIView {
    
    var contentView:UIView!
    var kolodaView:KolodaView!
    
    var groups = [Group]()
    
    var joinView:UIView!
    var skipView:UIView!
    
    var joinButton:UIButton!
    var skipButton:UIButton!
    
    var closeHandler: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        contentView = UIView()
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        GroupsService.sortGroups()
        
        groups = GroupsService.allGroups
        
        kolodaView = KolodaView()
        contentView.addSubview(kolodaView)
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        kolodaView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        kolodaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        kolodaView.heightAnchor.constraint(equalTo: kolodaView.widthAnchor).isActive = true
        kolodaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.countOfVisibleCards = 3
        kolodaView.reloadData()
        
        let emptyLabel = UILabel()
        emptyLabel.text = "No more groups!"
        emptyLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        emptyLabel.font = Fonts.bold(ofSize: 24)
        emptyLabel.textAlignment = .center
        contentView.insertSubview(emptyLabel, at: 0)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.centerYAnchor.constraint(equalTo: kolodaView.centerYAnchor).isActive = true
        emptyLabel.centerXAnchor.constraint(equalTo: kolodaView.centerXAnchor).isActive = true
        emptyLabel.isHidden = true
        
        let titleContentView = UIView()
        contentView.insertSubview(titleContentView, at: 0)
        
        titleContentView.translatesAutoresizingMaskIntoConstraints = false
        titleContentView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleContentView.bottomAnchor.constraint(equalTo: kolodaView.topAnchor).isActive = true
        titleContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        let title = UILabel()
        title.text = "Discover Groups!"
        title.textColor = UIColor.white
        title.font = Fonts.bold(ofSize: 32)
        title.textAlignment = .center
        titleContentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: titleContentView.centerYAnchor, constant: -32).isActive = true
        title.centerXAnchor.constraint(equalTo: titleContentView.centerXAnchor).isActive = true
        
        let desc = UILabel()
        desc.text = "Swipe right to join a group, swipe left to skip it"
        desc.textColor = UIColor.white
        desc.font = Fonts.regular(ofSize: 14)
        desc.textAlignment = .center
        titleContentView.addSubview(desc)
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
        desc.centerXAnchor.constraint(equalTo: titleContentView.centerXAnchor).isActive = true
        
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        contentView.insertSubview(spinner, at: 0)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: kolodaView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: kolodaView.centerYAnchor).isActive = true
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        let buttonView = UIView()
        contentView.insertSubview(buttonView, at: 0)
        //buttonView.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.topAnchor.constraint(equalTo: kolodaView.bottomAnchor, constant: 16.0).isActive = true
        buttonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44).isActive = true
        
        joinView = UIView()
        //joinView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        buttonView.addSubview(joinView)
        joinView.translatesAutoresizingMaskIntoConstraints = false
        joinView.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        joinView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        joinView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor).isActive = true
        
        skipView = UIView()
        //skipView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        buttonView.addSubview(skipView)
        skipView.translatesAutoresizingMaskIntoConstraints = false
        skipView.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        skipView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        skipView.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor).isActive = true
        
        joinView.widthAnchor.constraint(equalTo: skipView.widthAnchor).isActive = true
        joinView.leadingAnchor.constraint(equalTo: skipView.trailingAnchor).isActive = true
        
        joinButton = UIButton(type: .custom)
        joinButton.setImage(UIImage(named:"Join"), for: .normal)
        
        joinButton.layer.cornerRadius = 32
        joinButton.clipsToBounds = true
        joinView.addSubview(joinButton)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.centerXAnchor.constraint(equalTo: joinView.centerXAnchor).isActive = true
        joinButton.centerYAnchor.constraint(equalTo: joinView.centerYAnchor).isActive = true
        joinButton.addTarget(self, action: #selector(handleJoinButton), for: .touchUpInside)
        
        skipButton = UIButton(type: .custom)
        skipButton.setImage(UIImage(named:"Skip"), for: .normal)
        
        skipButton.layer.cornerRadius = 32
        skipButton.clipsToBounds = true
        skipView.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.centerXAnchor.constraint(equalTo: skipView.centerXAnchor).isActive = true
        skipButton.centerYAnchor.constraint(equalTo: skipView.centerYAnchor).isActive = true
        skipButton.addTarget(self, action: #selector(handleSkipButton), for: .touchUpInside)
        
        contentView.isUserInteractionEnabled = true
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(handleClose))
        //contentView.addGestureRecognizer(closeTap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.contentView.addGestureRecognizer(closeTap)
            spinner.stopAnimating()
            emptyLabel.isHidden = false
        })
    }
    @objc func handleClose() {
        closeHandler?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleJoinButton() {
        kolodaView.swipe(.right, force: true)
    }
    
    @objc func handleSkipButton() {
        kolodaView.swipe(.left, force: true)
    }
    
}


extension GroupsSwiperView: KolodaViewDelegate, KolodaViewDataSource {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
        print("DID RUN OUT!")
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        print("HEY!: \(index)")
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let group = groups[index]
        if direction == .bottomRight ||
            direction == .right ||
            direction == .topRight {
            GroupsService.joinGroup(id: group.id) { _ in }
        } else if direction == .bottomLeft ||
            direction == .left ||
            direction == .topLeft {
        }
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return groups.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = GroupCardView()
        view.setup(withGroup: groups[index])
        return view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return CardOverlayView()
    }
}


