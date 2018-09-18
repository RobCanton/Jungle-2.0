//
//  EffectsBarView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-26.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import JaneSliderControl

protocol EffectsBarDelegate:class {
    func setEffect(_ effect:String?, _ intensity:Float?)
}

enum BarPosition {
    case closed, open_partial, open
}
class EffectsBar:UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    var blurView:UIVisualEffectView!
    var collectionView:UICollectionView!
    var context:CIContext!
    let effects:[(String,Bool)] = [
        ("CIPixellate", true),
        ("CIPhotoEffectInstant", false),
        ("CIPhotoEffectNoir", false),
        ("CIPhotoEffectTransfer", false),
        ("CIPhotoEffectProcess", false),
        ("CIPhotoEffectChrome", false),
        ("CIPhotoEffectFade", false),
        ("CIBloom", true),
        ("CIGloom", true),
        ("CIVignetteEffect", true),
        ("CIColorPosterize", false),
        ("CIComicEffect", false),
        ("CIColorInvert", false)
    ]
    
    weak var delegate:EffectsBarDelegate?
    var slider:SliderControl!
    var sliderBox:UIView!
    
    var barBottomAnchor:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        context = CIContext()
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        translatesAutoresizingMaskIntoConstraints = false
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8.0, 0.0, 8.0)
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 84).isActive = true
        collectionView.register(EffectCollectionViewCell.self, forCellWithReuseIdentifier: "effectCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        
        sliderBox = UIView()
        //sliderBox.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        sliderBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sliderBox)
        sliderBox.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        sliderBox.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        sliderBox.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sliderBox.heightAnchor.constraint(equalToConstant: 84).isActive = true//bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        sliderBox.clipsToBounds = true
        
        let sliderFrame = CGRect(x: 8, y: 8,
                                 width: bounds.width - 16,
                                 height: 84 - 16 - 4)
        slider = SliderControl(frame: sliderFrame)
        slider.sliderColor = UIColor.white
        slider.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        slider.cornerRadius = 12.0
        sliderBox.addSubview(slider)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var currentImage:CIImage?
    
    func setImage(_ image:CIImage) {
        self.currentImage = image
        let selectedIndexes = self.collectionView.indexPathsForSelectedItems ?? []
        self.collectionView.reloadData()
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
            
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                for index in selectedIndexes {
                    self.collectionView.selectItem(at: index, animated: true, scrollPosition: .top)
                    
                }
            })
        })
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "effectCell", for: indexPath) as! EffectCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let effectCell = cell as! EffectCollectionViewCell
        if let image = self.currentImage {
            effectCell.setupEffect(image: image, effects[indexPath.row].0, context: context)
        }
    }
    
    var selectedEffect:String?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effect = effects[indexPath.row]
        selectedEffect = effect.0
        
        delegate?.setEffect(effect.0, 0.5)
        
        if effect.1 {
            slider.reset()
            self.setBarPosition(.open, animated: true)
        } else {
           self.setBarPosition(.open_partial, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.isSelected ?? false {
            selectedEffect = nil
            delegate?.setEffect(nil, nil)
            self.setBarPosition(.open_partial, animated: true)
            collectionView.deselectItem(at: indexPath, animated: true)
            return false
        }
        return true
    }
    
    @objc func sliderChanged() {
        let progress = slider.progress
        delegate?.setEffect(selectedEffect, progress)
    }
    
    @objc func handleCancel() {
        selectedEffect = nil
        delegate?.setEffect(nil, nil)
        selectedEffect = nil
        delegate?.setEffect(nil, nil)
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        self.sliderBox.alpha = 0.0
        UIView.animate(withDuration: 0.1, animations: {
            self.collectionView.alpha = 1.0
        }, completion: { _ in
            
        })
    }
    
    @objc func handleSaveIntensity() {
        self.sliderBox.alpha = 0.0
        UIView.animate(withDuration: 0.1, animations: {
            self.collectionView.alpha = 1.0
        }, completion: { _ in
            
        })
    }
    
    func setBarPosition(_ position:BarPosition, animated:Bool) {
        var constant:CGFloat = 0
        switch position {
        case .closed:
            constant = 84 * 2
            break
        case .open_partial:
            constant = 84
            break
        default:
            break
        }
        
        if animated {
            DispatchQueue.main.async {
                let c1 = CGPoint(x: 0.23, y: 1)
                let c2 = CGPoint(x: 0.32, y: 1)
                let animator = UIViewPropertyAnimator(duration: 0.65, controlPoint1: c1, controlPoint2: c2, animations: {
                    self.barBottomAnchor.constant = constant
                    self.superview?.layoutIfNeeded()
                })
                animator.startAnimation()
            }
        } else {
            self.barBottomAnchor.constant = constant
            self.superview?.layoutIfNeeded()
        }
    }
    
    
    
}

class EffectCollectionViewCell:UICollectionViewCell {
    
    var imageView = UIImageView()
    var iconView = UIImageView()
    var activityImage:UIActivityIndicatorView!
    var bgView:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        
        bgView = UIView()
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 4.0
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant:1).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4.0
        
        iconView = UIImageView(image: UIImage(named:"check"))
        iconView.contentMode = .scaleAspectFill
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4.0
        iconView.isHidden = true
        
        activityImage = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityImage.frame = bounds
        addSubview(activityImage)
        activityImage.translatesAutoresizingMaskIntoConstraints = false
        activityImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        activityImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        activityImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        activityImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        activityImage.hidesWhenStopped = true
        
    }
    
    func setupEffect(image:CIImage, _ effect:String, context:CIContext) {
        self.imageView.image = nil
        self.imageView.alpha = 0.5
        self.activityImage.startAnimating()
        DispatchQueue.global(qos: .background).async {
            //let image = UIImage(named:"cool")
            
            let ciInputImage = image//CIImage(image: image!)
            if let ciOutputImage = ciInputImage.applyEffect(effect, 1.0) {
                let cgOutputImage = context.createCGImage(ciOutputImage, from: ciInputImage.extent)
                let x = UIImage(cgImage: cgOutputImage!)
                
                DispatchQueue.main.async {
                    self.activityImage.stopAnimating()
                    self.imageView.image = x
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.alpha = 1.0
                    })
                }
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.iconView.isHidden = false
                self.imageView.alpha = 0.5
            } else {
                self.iconView.isHidden = true
                self.imageView.alpha = 1.0
            }
        }
    }
    
    
}
