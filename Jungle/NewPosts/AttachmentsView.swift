//
//  AttachmentsView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-18.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

protocol AttachmentsDelegate:class {
    func attachments(didSelect images: [SelectedImage])
}

class AttachmentsView:UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView:UICollectionView!
    
    var libraryAssets = [SelectedImage]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate:AttachmentsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = nil
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
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
        
        collectionView.register(AttachmentCollectionCell.self, forCellWithReuseIdentifier: "attachmentCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        let collectionLayoutGuide = collectionView.safeAreaLayoutGuide
        
//        let bar = TopicsBarView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 40.0))
//        addSubview(bar)
//        bar.translatesAutoresizingMaskIntoConstraints = false
//        bar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
//        bar.topAnchor.constraint(equalTo: collectionLayoutGuide.bottomAnchor, constant: 8.0).isActive = true
//        bar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
//        bar.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
//        bar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        let fetchedAssets = self.fetchLatestPhotos(forCount: 32)
    
        var assets = [SelectedImage]()
        for i in 0..<fetchedAssets.count {
            let fetchedAsset = fetchedAssets[i]
            let id = fetchedAsset.localIdentifier
            
            let asset = SelectedImage(id: id, asset: fetchedAsset, sourceType: .library)
            assets.append(asset)
        }
        self.libraryAssets = assets
        self.collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchLatestPhotos(forCount count: Int?) -> PHFetchResult<PHAsset> {
        
        // Create fetch options.
        let options = PHFetchOptions()
        
        // If count limit is specified.
        if let count = count { options.fetchLimit = count }
        
        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        print("COOOOOL")
        
        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return libraryAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentCollectionCell
        cell.backgroundColor = nil
        cell.imageView.image = nil
        if indexPath.section == 1 {
            let asset = libraryAssets[indexPath.row]
            cell.setAsset(asset, hideGIFTag: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let asset = libraryAssets[indexPath.row]
            delegate?.attachments(didSelect: [asset])
        }
    }
    

}


class AttachmentCollectionCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    
    var asset:PHAsset?
    var representedAssetIdentifier = ""
    
    var gifView:UIView!
    var gifLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFill
        let layoutGuide = safeAreaLayoutGuide
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        imageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        imageView.layer.cornerRadius = 16.0
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = accentColor.cgColor
        imageView.layer.borderWidth = 0.0
        self.applyShadow(radius: 8.0, opacity: 0.15, offset: CGSize(width: 0, height: 6.0), color: UIColor.black, shouldRasterize: false)
        self.clipsToBounds = false
        
        gifView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 25.0))
        gifView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        addSubview(gifView)
        gifView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 6.0).isActive = true
        gifView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -6.0).isActive = true
        gifView.translatesAutoresizingMaskIntoConstraints = false
    
        
        let gifViewLayoutGuide = gifView.safeAreaLayoutGuide
        gifLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 25.0))
        gifView.addSubview(gifLabel)
        gifLabel.text = "GIF"
        gifLabel.font = Fonts.semiBold(ofSize: 9.0)
        gifLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        gifLabel.textAlignment = .center
        gifLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gifLabel.leadingAnchor.constraint(equalTo: gifViewLayoutGuide.leadingAnchor, constant: 4.0).isActive = true
        gifLabel.topAnchor.constraint(equalTo: gifViewLayoutGuide.topAnchor).isActive = true
        gifLabel.trailingAnchor.constraint(equalTo: gifViewLayoutGuide.trailingAnchor, constant: -4.0).isActive = true
        gifLabel.bottomAnchor.constraint(equalTo: gifViewLayoutGuide.bottomAnchor).isActive = true
        gifLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        gifView.isHidden = false
        
        gifView.layer.cornerRadius = gifView.bounds.height / 2
        gifView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAsset(_ asset: SelectedImage, hideGIFTag:Bool) {
        
        // Here we bind the asset with the cell.
        representedAssetIdentifier = asset.asset.localIdentifier
        // Request the image.
        
        gifView.isHidden = asset.assetType != .gif || hideGIFTag
        
        PHImageManager.default().requestImage(for: asset.asset,
                                              targetSize: UIScreen.main.bounds.size,
                                              contentMode: .aspectFill,
                                              options: nil) { (image, _) in
                                                // By the time the image is returned, the cell may has been recycled.
                                                // We update the UI only when it is still on the screen.
                                                if self.representedAssetIdentifier == asset.asset.localIdentifier {
                                                    asset.image = image
                                                    self.imageView.image = image
                                                }
        }
    }
    
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                imageView.layer.borderWidth = 3.0
            } else {
                imageView.layer.borderWidth = 0.0
            }
        }
    }
    
}

