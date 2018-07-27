//
//  GIFSelectionVIewController.swift
//  uSTADIUM
//
//  Created by Robert Canton on 2018-03-22.
//  Copyright © 2018 uSTADIUM. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class GIFSelectionViewController:UIViewController, GIFCollectionDelegate {
    //@IBOutlet weak var containerView: UIView!
    
    var collectionNode = GIFCollectionNode()
    var addGIF: ((GIF)->())?
    var searchBar:RCSearchBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        print("GIFSelectionViewController")
        searchBar = RCSearchBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 70.0), topInset: 0)
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = view.safeAreaLayoutGuide
        searchBar.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: layout.topAnchor, constant: -20).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        view.addSubview(collectionNode.view)
        collectionNode.delegate = self
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        collectionNode.view.leadingAnchor.constraint(equalTo: layout.leadingAnchor).isActive = true
        collectionNode.view.trailingAnchor.constraint(equalTo: layout.trailingAnchor).isActive = true
        collectionNode.view.topAnchor.constraint(equalTo: layout.topAnchor,constant: 50).isActive = true
        collectionNode.view.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true
        view.layoutIfNeeded()
        
        searchBar.setup(withDelegate: self)
        searchBar.leftButton.setImage(UIImage(named:"back"), for: .normal)
        searchBar.leftButton.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelect(gif: GIF) {
        addGIF?(gif)
        self.dismiss(animated: true, completion: nil)
    }
}

extension GIFSelectionViewController: RCSearchBarDelegate {
    func searchTextDidChange(_ text: String?) {
        collectionNode.didSearchTextChange(text)
    }
    
    func searchDidBegin() {
        collectionNode.didSearchBegin()
    }
    
    func searchDidEnd() {
        collectionNode.didSearchEnd()
    }
    
    func searchTapped(_ text: String) {
        collectionNode.didSearch(text)
    }
    
    func handleLeftButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
