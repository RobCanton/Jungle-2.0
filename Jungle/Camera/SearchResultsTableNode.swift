//
//  SearchResultsTableNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-04.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

//
//  SearchResultsTableNode.swift
//  uSTADIUM
//
//  Created by Robert Canton on 2018-03-24.
//  Copyright © 2018 uSTADIUM. All rights reserved.
//
import Foundation
import UIKit
import AsyncDisplayKit

class SearchResultsTableNode:ASTableNode, ASTableDelegate, ASTableDataSource {
    
    var selectedSearchResult:((_ result:String)->())?
    var results = [String]() {
        didSet {
            self.isHidden = results.count == 0
            self.reloadData()
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        isHidden = true
        
    }
    
    override func didLoad() {
        super.didLoad()
        view.separatorStyle = .none
        view.isScrollEnabled = false
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = ASTextCellNode()
        cell.textAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 18)!
        ]
        cell.textInsets = UIEdgeInsetsMake(13, 26.0, 13, 26.0)
        cell.text = results[indexPath.row]
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        selectedSearchResult?(result)
        
    }
}
