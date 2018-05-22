//
//  MutedWordsViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class ContentSettingsViewController:UIViewController, ASTableDelegate, ASTableDataSource {
    
    var tableNode:ASTableNode!
    var doneButton:UIBarButtonItem!
    
    var commentBar:JCommentBar!
    var commentBarBottomAnchor:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationItem.title = "Content Settings"
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: Fonts.bold(ofSize: 16.0)]
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        doneButton.tintColor = accentColor
        navigationItem.rightBarButtonItem = doneButton
        
        tableNode = ASTableNode()
        let layout = view.safeAreaLayoutGuide
        view.addSubview(tableNode.view)
        tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        tableNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        tableNode.view.topAnchor.constraint(equalTo: layout.topAnchor).isActive = true
        tableNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.tableFooterView = UIView()
        tableNode.view.tableHeaderView = UIView()
        tableNode.backgroundColor = bgColor
        tableNode.reloadData()
        
        commentBar = JCommentBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        
        view.addSubview(commentBar)
        
        commentBar.translatesAutoresizingMaskIntoConstraints = false
        commentBar.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        commentBar.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        commentBarBottomAnchor = commentBar.bottomAnchor.constraint(equalTo: layout.bottomAnchor, constant: 0)
        commentBarBottomAnchor?.isActive = true
        commentBar.activeColor = accentColor
        commentBar.delegate = self
        commentBar.placeHolderLabel.font = Fonts.semiBold(ofSize: 14.0)
        commentBar.textView.font = Fonts.bold(ofSize: 14.0)
        commentBar.prepareTextView()
        commentBar.textBox.backgroundColor = UIColor.clear
        commentBar.placeHolderLabel.text = "Add word"
        commentBar.sendButton.setImage(UIImage(named:"Plus"), for: .normal)
        
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        commentBar.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.leadingAnchor.constraint(equalTo: commentBar.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: commentBar.trailingAnchor).isActive = true
        divider.topAnchor.constraint(equalTo: commentBar.topAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ContentSettings.blockedWordsList.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        switch indexPath.section {
        case 0:
            let cell = MutedWordCellNode(word: ContentSettings.blockedWordsList[indexPath.row])
            cell.delegate = self
            return cell
        case 1:
            let cell = ASTextCellNode()
            cell.text = "When you mute words, posts that include the muted words will be blocked."
            cell.textAttributes = [ NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0)]
            cell.backgroundColor = UIColor.white
            return cell
        default:
            return ASCellNode()
        }
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        
        self.commentBarBottomAnchor?.constant = -keyboardSize.height
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        print("keyboardWillHide")
        
        self.commentBarBottomAnchor?.constant = 0.0
        self.view.layoutIfNeeded()
    }
    
}

extension ContentSettingsViewController: CommentBarDelegate, MutedWordCellDelegate {
    func commentSend(text: String) {
        guard text.count > 0 else { return }
        commentBar.textView.text = ""
        commentBar.textViewDidChange(commentBar.textView)
        commentBar.textView.resignFirstResponder()
        ContentSettings.addBlockedWord(text)
        tableNode.reloadData()
    }
    
    func removeMutedWord(_ word: String) {
        ContentSettings.removeBlockedWord(word)
        tableNode.reloadData()
    }
}

protocol MutedWordCellDelegate:class {
    func removeMutedWord( _ word:String)
}

class MutedWordCellNode:ASCellNode {
    var textNode = ASTextNode()
    var removeButton = ASButtonNode()
    
    var delegate:MutedWordCellDelegate?
    var word:String?
    required init(word:String) {
        super.init()
        self.word = word
        automaticallyManagesSubnodes = true
        selectionStyle = .none
        backgroundColor = UIColor.white
        
        textNode.attributedText = NSAttributedString(string: word, attributes: [ NSAttributedStringKey.font: Fonts.bold(ofSize: 15.0)])
        
        removeButton.setImage(UIImage(named:"Remove2"), for: .normal)
        removeButton.addTarget(self, action: #selector(handleRemove), forControlEvents: .touchUpInside)
    }
    
    @objc func handleRemove() {
        guard let word = word else { return }
        delegate?.removeMutedWord(word)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerText = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: textNode)
        let centerButton = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: removeButton)
        
        let stack = ASStackLayoutSpec.horizontal()
        stack.children = [centerText, centerButton]
        centerText.style.flexGrow = 1.0
        centerButton.style.flexShrink = 1.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 15, 5, 15), child: stack)
    }
}
