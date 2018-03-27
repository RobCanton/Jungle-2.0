//
//  NewReplyViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AsyncDisplayKit
import Firebase

class NewReplyViewController: UIViewController {
    
    var post:Post! {
        didSet {
            tableNode.reloadData()
        }
    }
    
    @IBAction func handleSend(_ sender: Any) {
        guard let text = editText else { return }
        guard let user = Auth.auth().currentUser else { return }
        user.getIDToken() { token, error in
            let parameters: [String: Any] = [
                "uid" : user.uid,
                "text" : text
            ]
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token!)", "Accept": "application/json", "Content-Type" :"application/json"]
            Alamofire.request("\(API_ENDPOINT)/addReply/\(self.post.key)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                DispatchQueue.main.async {
                    if let dict = response.result.value as? [String:Any], let success = dict["success"] as? Bool, success {
                        print("RESPONSE: \(dict)")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    @IBAction func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        //textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    var tableNode = ASTableNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutGuide:UILayoutGuide!
        
        layoutGuide = view.safeAreaLayoutGuide
        
        tableNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0).isActive = true
        tableNode.view.contentInsetAdjustmentBehavior = .never
        tableNode.view.separatorStyle = .none
        
        tableNode.allowsSelection = false
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editCell?.textNode.becomeFirstResponder()
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    var editText:String? {
        if let cell = tableNode.nodeForRow(at: IndexPath(row: 0, section: 1)) as? EditTextCellNode {
            return cell.textNode.attributedText?.string
        }
        return nil
    }
    
    var editCell:EditTextCellNode? {
        return tableNode.nodeForRow(at: IndexPath(row: 0, section: 1)) as? EditTextCellNode
    }
}

extension NewReplyViewController:ASTableDelegate, ASTableDataSource {
    
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == 0 {
            let cell = ASTextCellNode()
            if post != nil {
                cell.text = post.text
            }
            return cell
        } else {
            let cell = EditTextCellNode()
            cell.style.height = ASDimension(unit: .points, value: UIScreen.main.bounds.height)
            return cell
        }
    }
    
   
}

class EditTextCellNode:ASCellNode {
    
    var textNode = ASEditableTextNode()
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        textNode.maximumLinesToDisplay = 0
        textNode.scrollEnabled = false
        textNode.attributedPlaceholderText = NSAttributedString(string: "Your reply", attributes: [
            NSAttributedStringKey.font: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor: UIColor.darkGray
        ])
        
        textNode.typingAttributes = [
            NSAttributedStringKey.font.rawValue: Fonts.regular(ofSize: 15.0),
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray
        ]
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16.0,16.0,16.0,16.0), child: textNode)
    }
}
