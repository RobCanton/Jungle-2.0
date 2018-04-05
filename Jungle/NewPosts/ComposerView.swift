//
//  ComposerView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ComposerView:UIView, UITextViewDelegate {
    
    var scrollView = UIScrollView()
    var contentView:UIView!
    var textView:UITextView!
    var imagesView:ComposerImagesView!
    
    var textHeightAnchor:NSLayoutConstraint?
    
    var topicsBar:TopicsBarView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        textView = UITextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        scrollView.frame = bounds
        addSubview(scrollView)
        let layoutGuide = safeAreaLayoutGuide
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        scrollView.contentSize = scrollView.bounds.size
        
        // let scrollLayoutGuide = scrollView.safeAreaLayoutGuide
        scrollView.addSubview(contentView)
        contentView.frame = scrollView.bounds

       // contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
        
        let contentLayoutGuide = contentView.safeAreaLayoutGuide
        
//        topicsBar = TopicsBarView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 32.0))
//        contentView.addSubview(topicsBar)
//        topicsBar.translatesAutoresizingMaskIntoConstraints = false
//        topicsBar.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 0.0).isActive = true
//        topicsBar.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
//        topicsBar.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: 0.0).isActive = true
//        topicsBar.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
//
//        let topicsLayoutGuide = topicsBar.safeAreaLayoutGuide
        
        textView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 30.0)
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        textView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        textView.isEditable = true
        
        textView.contentInset  = .zero
        textView.text = ""
        textView.keyboardType = .twitter
        textView.delegate = self
        textView.isScrollEnabled = false
        textHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 36.0)
        textHeightAnchor?.isActive = true
        textView.font = Fonts.regular(ofSize: 16.0)
        
        imagesView = ComposerImagesView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 200.0))
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imagesView)
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        imagesView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor).isActive = true
        imagesView.topAnchor.constraint(equalTo: textView.safeAreaLayoutGuide.bottomAnchor, constant: 8.0).isActive = true
        imagesView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).isActive = true
        imagesView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: textHeightAnchor!.constant)
        
        scrollView.contentSize = contentView.bounds.size
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textHeightAnchor?.constant = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: textHeightAnchor!.constant)
        
        scrollView.contentSize = contentView.bounds.size
    }
}

class ComposerImagesView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var selectedImages = [SelectedImage]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var collectionView:UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200.0, height: 200.0)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = nil
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        collectionView.register(AttachmentCollectionCell.self, forCellWithReuseIdentifier: "attachmentCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentCollectionCell
        let selectedAsset = selectedImages[indexPath.row]
        cell.setAsset(selectedAsset, hideGIFTag: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedImages.count == 1 {
            return CGSize(width: collectionView.bounds.width - 32.0, height: 200.0)
        }
        return CGSize(width: 200.0, height: 200.0)
    }
}
