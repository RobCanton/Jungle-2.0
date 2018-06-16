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
import AVFoundation
import Pulley

class NewPost {
    var text:String
    var attachments:SelectedImage?
    var gif:GIF?
    var video:URL?
    init(text:String, attachments:SelectedImage?, gif:GIF?, video:URL?) {
        self.text = text
        self.attachments = attachments
        self.gif = gif
        self.video = video
    }
}

class NewPostViewController:UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightAnchor:NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var contentHeightAnchor: NSLayoutConstraint!
    var isImagesRowHidden = false
    
    var newPost:NewPost?
    
    var selectedImage:SelectedImage? {
        didSet {
            if let image = selectedImage {
                selectedGIF = nil
                videoURL = nil
                self.removeImageButton.isHidden = false
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
                self.removeImageButton.isHidden = true
            }
        }
    }
    var selectedGIF:GIF? {
        didSet {
            if let gif = selectedGIF {
                selectedImage = nil
                videoURL = nil
                self.removeImageButton.isHidden = false
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
                self.removeImageButton.isHidden = true
            }
        }
    }
    
    var videoURL:URL? {
        didSet {
            if let url = videoURL {
                selectedImage = nil
                selectedGIF = nil
                removeImageButton.isHidden = false
                
                let item = AVPlayerItem(url: url)
                
                let videoPlayer = AVPlayer()
                videoPlayer.replaceCurrentItem(with: item)
                
                playerLayer = AVPlayerLayer(player: videoPlayer)
                playerLayer!.videoGravity = .resizeAspectFill
                playerLayer!.frame = previewView.bounds
                previewView.layer.insertSublayer(playerLayer!, at: 0)
                
                playerLayer!.player?.play()
                playerLayer!.player?.actionAtItemEnd = .none
                
                loopVideo()
                
            } else {
                endLoopVideo()
                playerLayer?.removeFromSuperlayer()
            }
        }
    }
    
    func addGIF(_ gif:GIF) {
        selectedGIF = gif
        attachmentsView.toggleAttachments(minimzed: true)
    }
    
    var playerLayer:AVPlayerLayer?
    func addVideo(_ url:URL) {
        print("ADD VIDEO")
        selectedGIF = nil
        selectedImage = nil
        videoURL = url
    }
    
    
    
    @IBAction func handlePostButton() {
        newPost = NewPost(text: textView.text, attachments: selectedImage, gif: selectedGIF, video: videoURL)
        self.performSegue(withIdentifier: "toTagsSelector", sender: self)
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
    
    @IBAction func handleRemoveAttachment(_ sender: Any) {
        selectedGIF = nil
        selectedImage = nil
        playerLayer?.removeFromSuperlayer()
        endLoopVideo()
        attachmentsView.toggleAttachments(minimzed: false)
    }
    
    var attachmentsBottomAnchor:NSLayoutConstraint?
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        //composerView.textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
        doneButton.clipsToBounds = true
        doneButton.backgroundColor = accentColor
        
        textView.backgroundColor = nil
        textView.isEditable = true
        textView.contentInset  = .zero
        textView.text = ""
        textView.keyboardType = .twitter
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.font = Fonts.regular(ofSize: 16.0)
        updateContentConstraints()
        
        previewView.layer.cornerRadius = 8.0
        previewView.clipsToBounds = true
        
        let layoutGuide = view.safeAreaLayoutGuide
        attachmentsView = AttachmentsView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 90.0))
        view.addSubview(attachmentsView)
        attachmentsView.translatesAutoresizingMaskIntoConstraints = false
        attachmentsView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        attachmentsView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        attachmentsBottomAnchor = attachmentsView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 0.0)
        attachmentsBottomAnchor?.isActive = true
        attachmentsView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        attachmentsView.delegate = self
        
        contentHeightAnchor.constant = scrollView.bounds.height
        view.layoutIfNeeded()
        
    }
    var attachmentsView:AttachmentsView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named:"Back"), style: .plain, target: nil, action: nil)
        
        // Remove the nav shadow underline
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endLoopVideo()
        playerLayer?.player?.pause()
        playerLayer?.player?.replaceCurrentItem(with: nil)
        playerLayer?.player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    var keyboardHeight:CGFloat?
    @objc func keyboardWillShow(notification:Notification) {
        if isImagesRowHidden { return }
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }

        
        keyboardHeight = keyboardSize.height
        UIView.animate(withDuration: 0.1, animations: {
            self.attachmentsBottomAnchor?.constant = -keyboardSize.height
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        if isImagesRowHidden { return }
        print("keyboardWillHide")
        UIView.animate(withDuration: 0.1, animations: {
            self.attachmentsBottomAnchor?.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        attachmentsView.toggleAttachments(minimzed: true)
        updateContentConstraints()
    }
    
    func updateContentConstraints() {
        textViewHeightAnchor.constant = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity)).height
        let contentHeight = textViewHeightAnchor.constant + 8.0 + 200.0
        
        contentHeightAnchor.constant = contentHeight > view.bounds.height ? contentHeight : view.bounds.height
        view.layoutIfNeeded()
    }
    
    func loopVideo() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.playerLayer?.player?.seek(to: kCMTimeZero)
            self.playerLayer?.player?.play()
        }
    }
    
    func endLoopVideo() {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime, name: nil, object: nil)
    }
}

extension NewPostViewController: AttachmentsDelegate {
    
    func attachmentsOpenCamera() {
        
        let controller = CameraViewController()
        controller.addVideo = addVideo
        let drawerVC = StickerViewController()
        let pulleyController = PulleyViewController(contentViewController: controller, drawerViewController: drawerVC)
        
        pulleyController.drawerBackgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        //let nav = UINavigationController(rootViewController: controller)
        self.present(pulleyController, animated: true, completion: nil)
    }
    func attachmentsOpenGIFs() {
        print("HELLO RENEE!!! ")
        
        let controller = GIFSelectionViewController()
        controller.addGIF = addGIF
        self.present(controller, animated: true, completion: nil)
    }
    
    func attachments(didSelect images: [SelectedImage]) {
        selectedImage = images[0]
        attachmentsView.toggleAttachments(minimzed: true)
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

