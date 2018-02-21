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

protocol AttachmentsDelegate:class {
    func attachments(didSelect images: [SelectedImage])
}

class AttachmentsView:UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView:UICollectionView!
    
    var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil {
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
        
        
        self.latestPhotoAssetsFetched = self.fetchLatestPhotos(forCount: 12)
        
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
        
        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return latestPhotoAssetsFetched?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentCollectionCell
        cell.backgroundColor = nil
        cell.imageView.image = nil
        if indexPath.section == 1 {
            // Get the asset. If nothing, return the cell.
            guard let asset = self.latestPhotoAssetsFetched?[indexPath.item] else {
                return cell
            }
            
            // Here we bind the asset with the cell.
            cell.representedAssetIdentifier = asset.localIdentifier
            // Request the image.
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: UIScreen.main.bounds.size,
                                                  contentMode: .aspectFill,
                                                  options: nil) { (image, _) in
                                                    // By the time the image is returned, the cell may has been recycled.
                                                    // We update the UI only when it is still on the screen.
                                                    if cell.representedAssetIdentifier == asset.localIdentifier {
                                                        cell.imageView.image = image
                                                    }
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? AttachmentCollectionCell else { return }
            guard let image = cell.imageView.image else { return }
            let label = cell.representedAssetIdentifier
            let selectedImage = SelectedImage(id: label, image: image, type: .library)
            delegate?.attachments(didSelect: [selectedImage])
        }
    }
    

}


class AttachmentCollectionCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    
    var representedAssetIdentifier = ""
    
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
        
        imageView.layer.borderColor = UIColor.green.cgColor
        imageView.layer.borderWidth = 0.0
        self.applyShadow(radius: 8.0, opacity: 0.15, offset: CGSize(width: 0, height: 6.0), color: UIColor.black, shouldRasterize: false)
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

