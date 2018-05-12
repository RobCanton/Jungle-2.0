//
//  AttachmentsView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-18.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Photos
import MobileCoreServices

protocol AttachmentsDelegate:class {
    func attachmentsOpenGIFs()
    func attachments(didSelect images: [SelectedImage])
}

class AttachmentsView:UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView:UICollectionView!
    
    var libraryAssets = [SelectedImage]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var buttonContainer:UIView!
    var attachmentButton:UIButton!
    
    var collectionBottomAnchor:NSLayoutConstraint!
    var buttonBottomAnchor:NSLayoutConstraint!
    
    weak var delegate:AttachmentsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 82, height: 82)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8.0, 0.0, 0.0)
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 8.0, 8.0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = nil
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        
        collectionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
        collectionBottomAnchor = collectionView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        collectionBottomAnchor.isActive = true
        
        collectionView.register(AttachmentCollectionCell.self, forCellWithReuseIdentifier: "attachmentCell")
        collectionView.register(GIFSelectorCell.self, forCellWithReuseIdentifier: "gifCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        let fetchedAssets = self.fetchLatestPhotos(forCount: 32)
    
        var assets = [SelectedImage]()
        for i in 0..<fetchedAssets.count {
            let fetchedAsset = fetchedAssets[i]
            let id = fetchedAsset.localIdentifier
            let size = CGSize(width: fetchedAsset.pixelWidth, height: fetchedAsset.pixelHeight)
            let asset = SelectedImage(id: id, asset: fetchedAsset, dimensions: size, sourceType: .library)
            assets.append(asset)
        }
        self.libraryAssets = assets
        self.collectionView.reloadData()
        
        buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        buttonContainer.backgroundColor = nil
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.applyShadow(radius: 6, opacity: 0.15, offset: .zero, color: .black, shouldRasterize: false)
        self.addSubview(buttonContainer)
        
        buttonContainer.heightAnchor.constraint(equalToConstant: 48).isActive = true
        buttonContainer.widthAnchor.constraint(equalToConstant: 48).isActive = true
        buttonContainer.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -12).isActive = true
        buttonBottomAnchor = buttonContainer.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 48.0)
        buttonBottomAnchor.isActive = true
        attachmentButton = UIButton(frame: buttonContainer.bounds)
        buttonContainer.addSubview(attachmentButton)
        
        attachmentButton.layer.cornerRadius = 24.0
        attachmentButton.clipsToBounds = true
        attachmentButton.backgroundColor = UIColor.white
        attachmentButton.setImage(UIImage(named:"clip"), for: .normal)
        attachmentButton.tintColor = UIColor(white: 0.6, alpha: 1.0)
        attachmentButton.addTarget(self, action: #selector(handleAttachmentButton), for: .touchUpInside)
    }
    
    @objc func handleAttachmentButton() {
        toggleAttachments(minimzed: false)
    }
    
    var isMinimized = false
    
    func toggleAttachments(minimzed:Bool) {
        if minimzed == self.isMinimized { return }
        self.isMinimized = minimzed
        print("MINIMIZE: \(minimzed)")
        if minimzed {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {
                self.collectionBottomAnchor.constant = self.bounds.height
                self.buttonBottomAnchor.constant = -12
                self.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {
                self.collectionBottomAnchor.constant = 0
                self.buttonBottomAnchor.constant = 48
                self.layoutIfNeeded()
            })
        }
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
            return 1
        }
        return libraryAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifCell", for: indexPath) as! GIFSelectorCell
            cell.setGIF()
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentCollectionCell
            cell.backgroundColor = nil
            cell.imageView.image = nil
            let asset = libraryAssets[indexPath.row]
            cell.setAsset(asset, hideGIFTag: false)
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82, height: 82)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            delegate?.attachmentsOpenGIFs()
        } else if indexPath.section == 1 {
            let asset = libraryAssets[indexPath.row]
            delegate?.attachments(didSelect: [asset])
        }
    }
    

}

class GIFSelectorCell: UICollectionViewCell {
    var imageView:UIImageView!

    var gifButton:UIButton!
    
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
        
        imageView.layer.borderColor = UIColor(white: 0.80, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 0.5

        gifButton = UIButton(frame: bounds)
        addSubview(gifButton)
        gifButton.setImage(UIImage(named:"Search"), for: .normal)
        gifButton.tintColor = UIColor.white
        gifButton.translatesAutoresizingMaskIntoConstraints = false
        gifButton.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        gifButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        gifButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        gifButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        gifButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        gifButton.layer.cornerRadius = 16.0
        gifButton.clipsToBounds = true
        gifButton.alpha = 0.75
        gifButton.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var gifImage:UIImage?
    func setGIF() {
        GIFService.getTopTrendingGif { _gif in
            if let gif = _gif {
                let thumbnailDataTask = URLSession.shared.dataTask(with: gif.thumbnail_url) { data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data {
                            self.gifImage = UIImage.gif(data: data)
                            self.imageView.image = self.gifImage
                        }
                    }
                }
                thumbnailDataTask.resume()
            }
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
        
        imageView.layer.borderColor = UIColor(white: 0.80, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 0.5
        //self.applyShadow(radius: 8.0, opacity: 0.15, offset: CGSize(width: 0, height: 6.0), color: UIColor.black, shouldRasterize: false)
        //self.clipsToBounds = false
        
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
    
    func setGIF() {
        imageView.backgroundColor = UIColor.lightGray
        GIFService.getTopTrendingGif { _gif in
            if let gif = _gif {
                let thumbnailDataTask = URLSession.shared.dataTask(with: gif.thumbnail_url) { data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data, self.imageView.image == nil {
                            let gifImage = UIImage.gif(data: data)
                            self.imageView.image = gifImage
                        }
                    }
                }
                thumbnailDataTask.resume()
            }
        }
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
//            if isSelected {
//                imageView.layer.borderWidth = 3.0
//            } else {
//                imageView.layer.borderWidth = 0.5
//            }
        }
    }
    
}

