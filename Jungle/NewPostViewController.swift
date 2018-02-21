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

class NewPostViewController:UIViewController {
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    
    var composerView = ComposerView()
    var isImagesRowHidden = false
    
    @IBAction func handlePostButton() {
        
        guard let user = Auth.auth().currentUser else { return }
        doneButton.isEnabled = false
        self.dismiss(animated: true, completion: nil)
        UploadService.uploadPost(text:composerView.textView.text, images: composerView.imagesView.selectedImages)
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
        
        attachmentsView = AttachmentsView(frame: CGRect(x: 0, y: view.bounds.height - 90, width: view.bounds.width, height: 90.0))
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
        
        UIView.animate(withDuration: 0.15, animations: {
            self.attachmentsBottomAnchor?.constant = -keyboardSize.height - 8.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        if isImagesRowHidden { return }
        print("keyboardWillHide")
        UIView.animate(withDuration: 0.15, animations: {
            self.attachmentsBottomAnchor?.constant = -8.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
}

extension NewPostViewController: AttachmentsDelegate {
    func attachments(didSelect images: [SelectedImage]) {
        composerView.imagesView.selectedImages = images
//        isImagesRowHidden = true
//        UIView.animate(withDuration: 0.35, animations: {
//            self.attachmentsView.alpha = 0.0
//
//            self.attachmentsBottomAnchor?.constant = -8.0
//            self.view.layoutIfNeeded()
//        }, completion: { _ in
//
//        })
    }
}

class ComposerView:UIView, UITextViewDelegate {
    
    var scrollView = UIScrollView()
    var contentView:UIView!
    var textView:UITextView!
    var imagesView:ComposerImagesView!
    
    var textHeightAnchor:NSLayoutConstraint?
    
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
        contentView.autoresizingMask = .flexibleHeight

        
        let contentLayoutGuide = contentView.safeAreaLayoutGuide
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
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textHeightAnchor?.constant = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
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
        cell.imageView.image = selectedImages[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedImages.count == 1 {
            return CGSize(width: collectionView.bounds.width - 24.0, height: 200.0)
        }
        return CGSize(width: 200.0, height: 200.0)
    }
}

enum SelectedImageSourceType:String {
    case library = "library"
    case camera = "camera"
}

class SelectedImage {
    var id:String
    var image:UIImage
    var type:SelectedImageSourceType
    
    init(id:String, image:UIImage, type:SelectedImageSourceType) {
        self.id = id
        self.image = image
        self.type = type
    }
}

