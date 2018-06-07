//
//  File.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-12.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class JTitleView:UIView {
    
    var contentBox:UIView!
    var sortingButton:UIButton!
    var rightButton:UIButton!
    var tabStack:UIStackView!
    var barView:UIView!
    
    var barLeadingAnchor:NSLayoutConstraint!
    var barWidthAnchor:NSLayoutConstraint!
    
    var homeButton:UIButton!
    var popularButton:UIButton!
    var nearbyButton:UIButton!
    var homeTabWidth:CGFloat!
    var popularTabWidth:CGFloat!
    var nearbyTabWidth:CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        backgroundColor = accentColor
        //self.clipsToBounds = false
        //self.applyShadow(radius: 5.0, opacity: 0.08, offset: CGSize(width:0,height:5.0), color: UIColor.black, shouldRasterize: false)
        
        contentBox = UIView()
        addSubview(contentBox)
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        contentBox.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentBox.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        contentBox.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentBox.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        sortingButton = UIButton(type: .custom)
        sortingButton.setImage(UIImage(named:"Switches"), for: .normal)
        sortingButton.tintColor = UIColor.white
        contentBox.addSubview(sortingButton)
        sortingButton.translatesAutoresizingMaskIntoConstraints = false
        sortingButton.centerYAnchor.constraint(equalTo: contentBox.centerYAnchor).isActive = true
        sortingButton.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor, constant: 12).isActive = true
        
        rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named:"Settings"), for: .normal)
        rightButton.tintColor = UIColor.white
        contentBox.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.centerYAnchor.constraint(equalTo: contentBox.centerYAnchor).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: contentBox.trailingAnchor, constant: -12).isActive = true
        //ortingButton.addTarget(self, action: #selector(nearby), for: .touchUpInside)
        
        let tabBox = UIView()
        contentBox.addSubview(tabBox)
        tabBox.translatesAutoresizingMaskIntoConstraints = false
        tabBox.centerXAnchor.constraint(equalTo: contentBox.centerXAnchor).isActive = true
        tabBox.topAnchor.constraint(equalTo: contentBox.topAnchor).isActive = true
        tabBox.bottomAnchor.constraint(equalTo: contentBox.bottomAnchor).isActive = true
        
        tabStack = UIStackView(frame: .zero)
        tabBox.addSubview(tabStack)
        tabStack.translatesAutoresizingMaskIntoConstraints = false
        tabStack.leadingAnchor.constraint(equalTo: tabBox.leadingAnchor).isActive = true
        tabStack.topAnchor.constraint(equalTo: tabBox.topAnchor).isActive = true
        tabStack.bottomAnchor.constraint(equalTo: tabBox.bottomAnchor).isActive = true
        tabStack.trailingAnchor.constraint(equalTo: tabBox.trailingAnchor).isActive = true
        tabStack.spacing = 15
        
        let buttonFont = Fonts.semiBold(ofSize: 13.0)
        homeButton = UIButton(type: .custom)
        homeButton.setTitle("HOME", for: .normal)
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.titleLabel?.font = buttonFont
        tabStack.addArrangedSubview(homeButton)
        
        homeTabWidth = UILabel.size(text: "HOME", height: 50.0, font: buttonFont).width
        
        popularButton = UIButton(type: .custom)
        popularButton.setTitle("POPULAR", for: .normal)
        popularButton.setTitleColor(UIColor.white, for: .normal)
        popularButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
        popularButton.alpha = 0.6
        tabStack.addArrangedSubview(popularButton)
        popularTabWidth = UILabel.size(text: "POPULAR", height: 50.0, font: buttonFont).width
        
        nearbyButton = UIButton(type: .custom)
        nearbyButton.setTitle("NEARBY", for: .normal)
        nearbyButton.setTitleColor(UIColor.white, for: .normal)
        nearbyButton.titleLabel?.font = Fonts.semiBold(ofSize: 13.0)
        nearbyButton.alpha = 0.6
        tabStack.addArrangedSubview(nearbyButton)
        
        nearbyTabWidth = UILabel.size(text: "NEARBY", height: 50.0, font: buttonFont).width
        
        barView = UIView()
        barView.backgroundColor = UIColor.white
        tabBox.addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        barWidthAnchor = barView.widthAnchor.constraint(equalToConstant: homeTabWidth)
        barWidthAnchor.isActive = true
        barView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        barLeadingAnchor = barView.leadingAnchor.constraint(equalTo: tabBox.leadingAnchor, constant: 0)
        barLeadingAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: tabBox.bottomAnchor, constant: 0).isActive = true
        
//        gradient = CAGradientLayer()
//        let botColor = hexColor(from: "a4e078")
//        let topColor = hexColor(from: "81d892")
//        gradient!.colors = [topColor.cgColor, botColor.cgColor]
//        gradient!.locations = [0.0 , 1.0]
//        gradient!.startPoint = CGPoint(x: 0.0, y: 1.0)
//        gradient!.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradient!.frame = self.bounds
//        
//        self.layer.insertSublayer(gradient!, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    var gradient:CAGradientLayer?
    
    func addGradient() {
        gradient?.frame = self.bounds
    }
    
    func setProgress(_ progress:CGFloat, index:Int) {
        print("PROGRESS: \(progress)")
        if index == 0 {
            barLeadingAnchor.constant = (homeTabWidth + 15) * progress
            barWidthAnchor.constant = homeTabWidth + (popularTabWidth - homeTabWidth) * progress
            homeButton.alpha = 0.6 + 0.4 * (1 - progress)
            popularButton.alpha = 0.6 + 0.4 * (progress)
        } else {
            barLeadingAnchor.constant = (popularTabWidth + 15) * progress + homeTabWidth + 15
            barWidthAnchor.constant = popularTabWidth + (nearbyTabWidth - popularTabWidth) * progress
            popularButton.alpha = 0.6 + 0.4 * (1 - progress)
            nearbyButton.alpha = 0.6 + 0.4 * (progress)
        }
        
    }
}
