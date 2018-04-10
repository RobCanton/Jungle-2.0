//
//  PostGroupSelectorViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-03-01.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Firebase
import Foundation
import UIKit
import AsyncDisplayKit
import AlignedCollectionViewFlowLayout


class TagsSelectorViewController:UIViewController, ASCollectionDelegate, ASCollectionDataSource {
    @IBOutlet weak var postButton: UIButton!
    
    var newPost:NewPost!
    
    var fetchingSuggested = true
    
    var tags:[Int:[String]] = [
        0:[],
        1:[],
        2:[]
    ]
    
    var selectedTags = [String]() {
        didSet {
            print("SELECTED TAGS: \(selectedTags)")
            
            if let tagsNode = selectedTagsNode {
                tagsNode.selectedTags = self.selectedTags
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                    self.tagsBottomAnchor.constant = self.selectedTags.count > 0 ? 0 : 56
                    self.view.layoutSubviews()
                }, completion: nil)
            }
            
        }
    }
    
    
    func getTagIndex(_ tag:String) -> Int? {
        for i in 0..<selectedTags.count {
            let _tag = selectedTags[i]
            if tag == _tag {
                return i
            }
        }
        return nil
    }
    
    func addTag(_ tag:String) {
        if let _ = getTagIndex(tag) {
            return
        } else {
            selectedTags.append(tag)
            
            for (section, array) in tags {
                for i in 0..<array.count {
                    let _tag = array[i]
                    if tag == _tag {
                        let index = IndexPath(row: i + 1, section: section)
                        collectionNode.selectItem(at: index, animated: true, scrollPosition: [])
                        collectionNode(collectionNode, didSelectItemAt: index)
                    }
                }
            }
        }
    }
    
    func removeTag(_ tag:String) {
        if let index = getTagIndex(tag) {
            selectedTags.remove(at: index)
            for (section, array) in tags {
                for i in 0..<array.count {
                    let _tag = array[i]
                    if tag == _tag {
                        let index = IndexPath(row: i + 1, section: section)
                        collectionNode.deselectItem(at: index, animated: true)
                        collectionNode(collectionNode, didDeselectItemAt: index)
                    }
                }
            }
        }
    }
    
    let tagsBarHeight:CGFloat = 56.0
    var selectedTagsNode:SelectedTagsNode!
    var tagsBottomAnchor:NSLayoutConstraint!
    
    var collectionNode:ASCollectionNode!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postButton.layer.cornerRadius = postButton.bounds.height / 2
        postButton.clipsToBounds = true
        postButton.backgroundColor = accentColor
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.minimumInteritemSpacing = 8.0
        alignedFlowLayout.minimumLineSpacing = 8.0
        collectionNode = ASCollectionNode(collectionViewLayout: alignedFlowLayout)
        collectionNode.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
        collectionNode.backgroundColor = UIColor.white
        collectionNode.view.showsVerticalScrollIndicator = false
        view.addSubview(collectionNode.view)
        
        let layoutGuide = view.safeAreaLayoutGuide
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        collectionNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 12.0).isActive = true
        collectionNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -12.0).isActive = true
        collectionNode.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 12.0).isActive = true
        collectionNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        collectionNode.reloadData()
        
        collectionNode.allowsSelection = true
        collectionNode.allowsMultipleSelection = true
        
        selectedTagsNode = SelectedTagsNode()
        view.addSubview(selectedTagsNode.view)
        
        selectedTagsNode.view.translatesAutoresizingMaskIntoConstraints = false
        
        selectedTagsNode.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        selectedTagsNode.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tagsBottomAnchor = selectedTagsNode.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -tagsBarHeight)
        tagsBottomAnchor.isActive = true
        selectedTagsNode.view.heightAnchor.constraint(equalToConstant: tagsBarHeight).isActive = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textLength = newPost.text.utf16.count
        let textRange = NSRange(location: 0, length: textLength)
         let elements = RegexParser.getElements(from: newPost.text, with: RegexParser.hashtagPattern, range: textRange)
        var writtenTags = [String]()
        for element in elements {
            if let range = Range(element.range, in: newPost.text) {
                let str = newPost.text.substring(with: range)
                    .removeWhitespaces()
                    .replacingOccurrences(of: "#", with: "")
                
                writtenTags.append(str)
            }
        }
        
        self.selectedTags = writtenTags
        
        PostsService.getSuggestedTags(forText: newPost.text) { _tags, _trending in
            print("GOT EM!")
            self.tags[0] = _tags
            self.fetchingSuggested = false
            self.collectionNode.reloadSections(IndexSet(integer: 0))
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            let recentRef = database.child("hashtags/recentlyUsed/\(uid)").queryOrderedByValue().queryLimited(toFirst: 12)
            recentRef.observeSingleEvent(of: .value, with: { snapshot in
                var recent = [String]()
                if let data = snapshot.value as? [String:Any] {
                    for (tag, _) in data {
                        recent.append(tag)
                    }
                }
                self.tags[2] = recent
                self.collectionNode.reloadSections(IndexSet(integer: 2))
            })
        }
        
        let trendingRef = database.child("hashtags/trending").queryOrdered(byChild: "total").queryLimited(toFirst: 12)
        trendingRef.observeSingleEvent(of: .value, with: { snapshot in
            var trending = [String]()
            if let data = snapshot.value as? [String:Any] {
                for (tag, _) in data {
                    trending.append(tag)
                }
            }
            self.tags[1] = trending
            self.collectionNode.reloadSections(IndexSet(integer: 1))
        })
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        
        UploadService.uploadPost(text: newPost.text,
                                 images: newPost.attachments,
                                 tags: selectedTags,
                                 includeLocation:true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return tags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if fetchingSuggested { return 2 }
            return tags[section]!.count > 0 ? tags[section]!.count + 1 : 0
        default:
            return tags[section]!.count > 0 ? tags[section]!.count + 1 : 0
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        var tag:String!
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let textCell = ASTextCellNode()
                textCell.text = fetchingSuggested || tags[0]!.count > 0 ? "Suggested" : "No Suggestions"
                textCell.style.width = ASDimension(unit: .points, value: collectionNode.bounds.width)
                textCell.textAttributes = [
                    NSAttributedStringKey.foregroundColor: UIColor.gray,
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 16.0)
                ]
                textCell.textInsets = UIEdgeInsetsMake(12.0, 12.0, 8.0, 12.0)
                return textCell
            } else {
                if fetchingSuggested {
                    let cell = LoadingCellNode()
                    cell.spinner.startAnimating()
                    return cell
                }
                tag = tags[indexPath.section]![indexPath.row - 1]
            }
        } else {
            if indexPath.row == 0 {
                let textCell = ASTextCellNode()
                textCell.text = indexPath.section == 1 ? "Trending" : "Recently Used"
                textCell.style.width = ASDimension(unit: .points, value: collectionNode.bounds.width)
                textCell.textAttributes = [
                    NSAttributedStringKey.foregroundColor: UIColor.gray,
                    NSAttributedStringKey.font: Fonts.semiBold(ofSize: 16.0)
                ]
                textCell.textInsets = UIEdgeInsetsMake(16.0, 12.0, 8.0, 12.0)
                return textCell
            } else {
                tag = tags[indexPath.section]![indexPath.row - 1]
            }
        }
        let cell = TagCellNode(insets: UIEdgeInsetsMake(8.0, 12.0, 8.0, 12.0))
        cell.textNode.attributedText = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray,NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0)])
        cell.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        cell.style.height = ASDimension(unit: .points, value: 36.0)
        cell.layer.cornerRadius = 18
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            let tag = tags[indexPath.section]![indexPath.row - 1]
            
            let cell = collectionNode.nodeForItem(at: indexPath) as? TagCellNode
            cell?.backgroundColor = accentColor
            cell?.textNode.attributedText = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0)])
            addTag(tag)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            let tag = tags[indexPath.section]![indexPath.row - 1]
            
            let cell = collectionNode.nodeForItem(at: indexPath) as? TagCellNode
            cell?.textNode.attributedText = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray,NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0)])
            cell?.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
            
            removeTag(tag)
        }
    }
}


class SelectedTagsNode:ASDisplayNode, ASCollectionDelegate, ASCollectionDataSource {
    
    var collectionNode:ASCollectionNode!
    
    var selectedTags = [String]() {
        didSet {
            collectionNode?.reloadData()
        }
    }
    
    override init() {
        super.init()
        self.backgroundColor = accentColor
        automaticallyManagesSubnodes = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.contentInset = UIEdgeInsetsMake(0, 12.0, 0, 12.0)
        collectionNode.style.height = ASDimension(unit: .points, value: 36.0)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.backgroundColor = UIColor.clear
        collectionNode.reloadData()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: collectionNode)
    }
    
    override func didLoad() {
        super.didLoad()
        self.clipsToBounds = false
        self.view.applyShadow(radius: 12.0, opacity: 0.18, offset: .zero, color: UIColor.black, shouldRasterize: false)
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.showsVerticalScrollIndicator = false
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return selectedTags.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let tag = selectedTags[indexPath.item]
        let cell = TagCellNode(insets: UIEdgeInsetsMake(8.0, 12.0, 8.0, 12.0))
        cell.textNode.attributedText = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0)])
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        cell.style.height = ASDimension(unit: .points, value: 36.0)
        cell.layer.cornerRadius = 18
        return cell
    }
}
