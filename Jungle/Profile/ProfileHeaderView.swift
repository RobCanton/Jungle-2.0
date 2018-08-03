//
//  ProfileHeaderView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-11.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

class ProfileHeaderView:UIView {
    
    var backgroundImage:UIImageView!
    var imageContainer:UIView!
    var contentContainer:UIView!
    var tabBar:UIStackView!
    var titleBar:UIView!
    var titleBarHeightAnchor:NSLayoutConstraint!
    var titleLabel:UILabel!
    var levelButton:UIButton!
    var settingsButton:UIButton!
    var levelLabel:UILabel!
    
    var progressRing:UICircularProgressRingView!
    var experienceLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = self.directionalLayoutMargins
        self.clipsToBounds = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        contentContainer = UIView()
        contentContainer.backgroundColor = UIColor.white
        addSubview(contentContainer)
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        contentContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        self.applyShadow(radius: 8.0, opacity: 0.3, offset: CGSize(width:0,height:8.0), color: accentColor, shouldRasterize: false)
        
        backgroundImage = UIImageView(frame: bounds)
        contentContainer.addSubview(backgroundImage)
        backgroundImage.image = UIImage(named: "GreenBox")

        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true
        backgroundImage.clipsToBounds = true
        
        imageContainer = UIView()
        contentContainer.addSubview(imageContainer)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
       
        imageContainer.widthAnchor.constraint(equalToConstant: 128.0).isActive = true
        imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 1.0).isActive = true
        imageContainer.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor).isActive = true
        imageContainer.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor, constant: 16).isActive = true
        
        progressRing = UICircularProgressRingView(frame: imageContainer.bounds)
        // Change any of the properties you'd like
        imageContainer.addSubview(progressRing)
        
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 0).isActive = true
        progressRing.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 0).isActive = true
        progressRing.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 0).isActive = true
        progressRing.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: 0).isActive = true
        
        progressRing.maxValue = 1
        progressRing.shouldShowValueText = false
        progressRing.ringStyle = .ontop
        progressRing.outerRingWidth = 5.0
        progressRing.outerRingColor = UIColor.white.withAlphaComponent(0.35)
        progressRing.innerRingWidth = 5.0
        progressRing.innerRingColor = UIColor.white
        progressRing.innerCapStyle = .butt
        progressRing.innerRingSpacing = 0.0
        progressRing.startAngle = -90
        
        levelLabel = UILabel(frame: .zero)
        levelLabel.text = "12"
        levelLabel.textColor = UIColor.white
        levelLabel.font = Fonts.semiBold(ofSize: 40)
        levelLabel.textAlignment = .center

        let levelTagLabel = UILabel(frame: .zero)
        levelTagLabel.text = "LEVEL"
        levelTagLabel.textColor = UIColor.white
        levelTagLabel.font = Fonts.regular(ofSize: 13)
        levelTagLabel.textAlignment = .center
        
        let levelStack = UIStackView()
        levelStack.axis = .vertical
        levelStack.spacing = -7.0
        imageContainer.addSubview(levelStack)
        levelStack.translatesAutoresizingMaskIntoConstraints = false
        
        levelStack.addArrangedSubview(levelTagLabel)
        levelStack.addArrangedSubview(levelLabel)
        
        levelStack.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor).isActive = true
        levelStack.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor).isActive = true

        experienceLabel = UILabel(frame: .zero)
        //contentContainer.addSubview(experienceLabel)
        experienceLabel.translatesAutoresizingMaskIntoConstraints = false
        experienceLabel.text = "215/400 XP"
        experienceLabel.textColor = UIColor.white
        experienceLabel.font = Fonts.regular(ofSize: 11)
        experienceLabel.textAlignment = .center
        experienceLabel.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        levelStack.addArrangedSubview(experienceLabel)
//        experienceLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor).isActive = true
//        experienceLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 8.0).isActive = true
        
//        levelTagLabel.bottomAnchor.constraint(equalTo: levelLabel.topAnchor, constant: 2.0).isActive = true
        
        titleBar = UIView()
        contentContainer.addSubview(titleBar)
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        titleBar.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor).isActive = true
        titleBar.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20).isActive = true
        titleBar.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor).isActive = true
        titleBarHeightAnchor = titleBar.heightAnchor.constraint(equalToConstant: 44.0)
        titleBarHeightAnchor.isActive = true
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.text = "PROFILE"
        titleLabel.textColor = UIColor.white
        titleLabel.font = Fonts.medium(ofSize: 13.0)
        titleLabel.textAlignment = .center
        titleBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: titleBar.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor).isActive = true
        
        settingsButton = UIButton(type: .custom)
        titleBar.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named:"Settings"), for: .normal)
        settingsButton.tintColor = UIColor.white
        settingsButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -12).isActive = true
        
        levelButton = UIButton(type: .custom)
        titleBar.addSubview(levelButton)
        levelButton.translatesAutoresizingMaskIntoConstraints = false
        levelButton.setTitle("LVL 12", for: .normal)
        levelButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
        levelButton.backgroundColor = UIColor.white
        levelButton.setTitleColor(accentColor, for: .normal)
        levelButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor).isActive = true
        levelButton.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 12).isActive = true
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(1, 6, 1, 6)
        levelButton.layer.cornerRadius = 4
        levelButton.clipsToBounds = true
        
//        tabBar = UIStackView()
//        contentContainer.addSubview(tabBar)
//        contentContainer.clipsToBounds = true
//        tabBar.translatesAutoresizingMaskIntoConstraints = false
//        tabBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
//        tabBar.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant:16.0).isActive = true
//        tabBar.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant:-16.0).isActive = true
//        tabBar.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true
//        
//        let postsButton = UIButton(type: .custom)
//        postsButton.setTitle("POSTS", for: .normal)
//        postsButton.setTitleColor(.white, for: .normal)
//        postsButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
//
//        let commentsButton = UIButton(type: .custom)
//        commentsButton.setTitle("COMMENTS", for: .normal)
//        commentsButton.setTitleColor(.white, for: .normal)
//        commentsButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
//
//        let historyButton = UIButton(type: .custom)
//        historyButton.setTitle("HISTORY", for: .normal)
//        historyButton.setTitleColor(.white, for: .normal)
//        historyButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
//
//        tabBar.addArrangedSubview(postsButton)
//        tabBar.addArrangedSubview(commentsButton)
//        tabBar.addArrangedSubview(historyButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(_ progress:CGFloat) {

        let progressPower = progress * progress * progress
        imageContainer.alpha = progressPower
        levelButton.alpha = 1 - progressPower
        //titleTopAnchor.constant = titleTopConstant + (32 - titleTopConstant) * progress
        
        titleBarHeightAnchor.constant = 44 + 20 * progress
    }
    
    func setLevelProgress(_ progress:CGFloat) {
        progressRing.setProgress(value: progress, animationDuration: 1.75) {
            print("Done animating!")
            // Do anything your heart desires...
        }
    }
}

extension UIButton{
    func clearColorForTitle() {
        
        let buttonSize = bounds.size
        
        if let font = titleLabel?.font{
            let attribs = [NSAttributedStringKey.font: font]
            
            if let textSize = titleLabel?.text?.size(withAttributes: attribs){
                UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)
                
                if let ctx = UIGraphicsGetCurrentContext(){
                    ctx.setFillColor(UIColor.white.cgColor)
                    
                    let center = CGPoint(x: buttonSize.width / 2 - textSize.width / 2, y: buttonSize.height / 2 - textSize.height / 2)
                    let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
                    ctx.addPath(path.cgPath)
                    ctx.fillPath()
                    ctx.setBlendMode(.destinationOut)
                    
                    titleLabel?.text?.draw(at: center, withAttributes: [NSAttributedStringKey.font: font])
                    
                    if let viewImage = UIGraphicsGetImageFromCurrentImageContext(){
                        UIGraphicsEndImageContext()
                        
                        let maskLayer = CALayer()
                        maskLayer.contents = ((viewImage.cgImage) as AnyObject)
                        maskLayer.frame = bounds
                        
                        layer.mask = maskLayer
                    }
                }
            }
        }
    }
}
