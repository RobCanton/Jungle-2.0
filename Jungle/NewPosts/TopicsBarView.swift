//
//  TopicsBarView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class TopicsBarView:UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView:UICollectionView!
    
    var topics = ["Movies", "Politics", "Love & Relationships", "Funny", "Thoughtful"]
    
    weak var delegate:AttachmentsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = nil
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 32.0, height: 32.0)
        //layout.minimumLineSpacing = 8.0
        //layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8.0, 0.0, 0.0)
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 8.0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = nil
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        collectionView.register(TopicCell.self, forCellWithReuseIdentifier: "topicCell")
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
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as! TopicCell
        cell.backgroundColor = nil
        cell.titleLabel.text = topics[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = topics[indexPath.row]
        let width = UILabel.size(text: title, height: 32.0, font: TopicCell.titleFont).width + 16
        return CGSize(width: width, height: 32.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
}


class TopicCell: UICollectionViewCell {

    var titleLabel:UILabel!
    
    static let titleFont = Fonts.semiBold(ofSize: 12.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = accentColor.cgColor
        layer.borderWidth = 1.5
        
        layer.cornerRadius = 16.0
        clipsToBounds = true
        
        let layoutGuide = safeAreaLayoutGuide
        
        titleLabel = UILabel(frame: bounds)
        titleLabel.text = "Lil Uzi Vert"
        titleLabel.font = TopicCell.titleFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = accentColor
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                titleLabel.textColor = UIColor.white
                backgroundColor = accentColor
            } else {
                titleLabel.textColor = accentColor
                backgroundColor = nil
            }
        }
    }


}


