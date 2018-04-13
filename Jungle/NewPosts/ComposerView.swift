//
//  ComposerView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Photos
import MobileCoreServices
import SwiftGifOrigin

class ComposerView:UIView, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage:SelectedImage? {
        didSet {
            
            
            if let image = selectedImage {
                selectedGIF = nil
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                
                PHImageManager.default().requestImageData(for: image.asset, options: option, resultHandler: { imageData, UTI, _, _ in
                    
                    if let data = imageData {
                        if let uti = UTI, UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                            // save data here
                            self.imageView.image = UIImage.gif(data: data)
                        } else {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                    
                })
            } else {
                self.imageView.image = nil
            }
        }
    }
    
    var selectedGIF:GIF? {
        didSet {
            if let gif = selectedGIF {
                selectedImage = nil
                let thumbnailDataTask = URLSession.shared.dataTask(with: gif.thumbnail_url) { data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data, self.imageView.image == nil {
                            let gifImage = UIImage.gif(data: data)
                            self.imageView.image = gifImage
                        }
                    }
                }
                thumbnailDataTask.resume()
                
                let dataTask = URLSession.shared.dataTask(with: gif.original_url) { data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data {
                            let gifImage = UIImage.gif(data: data)
                            self.imageView.image = gifImage
                        }
                    }
                }
                
                dataTask.resume()
            } else {
                self.imageView.image = nil
            }
        }
    }
    var textHeightAnchor:NSLayoutConstraint?
    
    var topicsBar:TopicsBarView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        
        textView.isEditable = true
        textView.contentInset  = .zero
        textView.text = ""
        textView.keyboardType = .twitter
        textView.delegate = self
        textView.isScrollEnabled = false
        textHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 36.0)
        textHeightAnchor?.isActive = true
        textView.font = Fonts.regular(ofSize: 16.0)
        
       
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textHeightAnchor?.constant = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        //contentView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: textHeightAnchor!.constant + 200.0)

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
        
        collectionView.register(AttachmentPreviewCollectionCell.self, forCellWithReuseIdentifier: "attachmentCell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentPreviewCollectionCell
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

class AttachmentPreviewCollectionCell: UICollectionViewCell {
    
    var imageView = ASNetworkImageNode()
    var asset:PHAsset?
    var representedAssetIdentifier = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        imageView.view.frame = bounds
        addSubview(imageView.view)
        
        imageView.contentMode = .scaleAspectFill
        let layoutGuide = safeAreaLayoutGuide
        imageView.view.translatesAutoresizingMaskIntoConstraints = true
        
        imageView.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        imageView.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        imageView.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        imageView.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        imageView.layer.cornerRadius = 16.0
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor(white: 0.80, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 0.5
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGIF() {
        imageView.backgroundColor = UIColor.lightGray
    }
    
    func setAsset(_ asset: SelectedImage, hideGIFTag:Bool) {
        
        // Here we bind the asset with the cell.
        representedAssetIdentifier = asset.asset.localIdentifier
        // Request the image.
        imageView.view.frame = bounds
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
    
    
}
