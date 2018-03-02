//
//  PostGroupSelectorViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit



class PostGroupViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var postButton: UIButton!
    
    var groups = [
        Group(key: "funny", name: "Funny", desc: "Funny or die!"),
        Group(key: "movie-buffs", name: "Movie Buffs", desc: "For movie lovers."),
        Group(key: "love-and-relationships", name: "Love & Relationships", desc: ""),
        Group(key: "star-wars", name: "Star Wars", desc: "May the Force be with you."),
        Group(key: "gaming", name: "Gaming", desc: "Game talk."),
    ]
    
    var newPost:NewPost!
    
    var group:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postButton.layer.cornerRadius = postButton.bounds.height / 2
        postButton.clipsToBounds = true
        postButton.backgroundColor = accentColor
        
        let nib = UINib(nibName: "GroupCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "groupCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsetsMake(0, 16 + 48 + 12, 0, 0)
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        UploadService.uploadPost(text: newPost.text,
                                 images: newPost.attachments,
                                 includeLocation:true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return groups.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = "The Jungle"
            break
        case 1:
            let group = groups[indexPath.row]
            cell.titleLabel.text = group.name
            cell.subtitleLabel.text = group.desc
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        group = groups[indexPath.row]
    }
}
