//
//  NewPostViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import Firebase
import AsyncDisplayKit
import Photos
import MobileCoreServices

class NewPost {
    var text:String
    var attachments:[SelectedImage]
    
    init(text:String, attachments:[SelectedImage]) {
        self.text = text
        self.attachments = attachments
    }
}

class NewPostViewController:UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    
    var composerView = ComposerView()
    var isImagesRowHidden = false
    
    var newPost:NewPost?
    @IBAction func handlePostButton() {
        newPost = NewPost(text: composerView.textView.text, attachments: composerView.imagesView.selectedImages)
        self.performSegue(withIdentifier: "toTagsSelector", sender: self)
////        PostsService.getSuggestedTags(forText: composerView.textView.text) {
////            print("GOT EM!")
////        }
//        UploadService.uploadPost(text: composerView.textView.text,
//                                 images: composerView.imagesView.selectedImages,
//                                 includeLocation:true)
//        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newPost = newPost else { return }
        if segue.identifier == "toTagsSelector" {
            let dest = segue.destination as! TagsSelectorViewController
            dest.newPost = newPost
            
        }
    }
    
    @IBAction func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var attachmentsBottomAnchor:NSLayoutConstraint?
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        composerView.textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        composerView.frame = view.bounds
        
        view.addSubview(composerView)
        
//        cancelButton.tintColor = secondaryColor 
//        
//        doneButton.backgroundColor = secondaryColor
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
        doneButton.clipsToBounds = true
        doneButton.backgroundColor = accentColor
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        composerView.translatesAutoresizingMaskIntoConstraints = false
        composerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        composerView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        composerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        composerView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        composerView.setup()
        
        attachmentsView = AttachmentsView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 90.0 + 40.0 + 8.0))
        view.addSubview(attachmentsView)
        attachmentsView.translatesAutoresizingMaskIntoConstraints = false
        attachmentsView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        attachmentsView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        attachmentsBottomAnchor = attachmentsView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -8.0)
        attachmentsBottomAnchor?.isActive = true
        attachmentsView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        attachmentsView.delegate = self
        
    }
    var attachmentsView:AttachmentsView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        composerView.textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named:"Back"), style: .plain, target: nil, action: nil)
        
        // Remove the nav shadow underline
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification:Notification) {
        if isImagesRowHidden { return }
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.attachmentsBottomAnchor?.constant = -keyboardSize.height - 8.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        if isImagesRowHidden { return }
        print("keyboardWillHide")
        UIView.animate(withDuration: 0.1, animations: {
            self.attachmentsBottomAnchor?.constant = -8.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
}

extension NewPostViewController: AttachmentsDelegate {
    func attachments(didSelect images: [SelectedImage]) {
        composerView.imagesView.selectedImages = images
        isImagesRowHidden = true
        UIView.animate(withDuration: 0.35, animations: {
            self.attachmentsView.alpha = 0.0

            self.attachmentsBottomAnchor?.constant = -8.0
            self.view.layoutIfNeeded()
        }, completion: { _ in

        })
    }
}

enum SelectedImageSourceType:String {
    case library = "library"
    case camera = "camera"
}

enum SelectedAssetType:String {
    case jpg = "jpg"
    case gif = "gif"
}

class SelectedImage {
    var id:String
    var asset:PHAsset
    var dimensions:CGSize
    var assetType:SelectedAssetType
    var sourceType:SelectedImageSourceType
    var image:UIImage?
    
    
    init(id:String, asset:PHAsset, dimensions:CGSize, sourceType:SelectedImageSourceType) {
        self.id = id
        self.asset = asset
        self.dimensions = dimensions
        self.sourceType = sourceType
        
        assetType = .jpg
        
        if let identifier = asset.value(forKey: "uniformTypeIdentifier") as? String
        {
            if identifier == kUTTypeGIF as String
            {

                assetType = .gif
            }
        }
        
        
    }
}

