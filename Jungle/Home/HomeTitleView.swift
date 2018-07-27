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
    
    var backgroundImage:UIImageView!
    var leftButton:UIButton!
    var rightButton:UIButton!
    var contentView:UIView!
    
    var titleLabel:UILabel!
    
    init(frame:CGRect, topInset:CGFloat) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.insetsLayoutMarginsFromSafeArea = false
        self.preservesSuperviewLayoutMargins = false
        
        self.backgroundColor = accentColor
        backgroundImage = UIImageView(image: UIImage(named:"NavBarGradient1"))
        backgroundImage.frame = bounds
        addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        contentView = UIView()
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor, constant: topInset).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        rightButton = UIButton(type: .custom)
        rightButton.tintColor = UIColor.white
        contentView.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        
        leftButton = UIButton(type: .custom)
        leftButton.tintColor = UIColor.white
        contentView.addSubview(leftButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        
        titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.medium(ofSize: 13.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TabScrollView:UIView {
    
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
    
    init(frame:CGRect, titles:[String]) {
        super.init(frame: frame)
        
        tabStack = UIStackView(frame: .zero)
        addSubview(tabStack)
        tabStack.translatesAutoresizingMaskIntoConstraints = false
        tabStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tabStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tabStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabStack.spacing = 15
        
        let buttonFont = Fonts.medium(ofSize: 13.0)
        homeButton = UIButton(type: .custom)
        homeButton.setTitle(titles[0], for: .normal)
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.titleLabel?.font = buttonFont
        tabStack.addArrangedSubview(homeButton)
        
        homeTabWidth = UILabel.size(text: titles[0], height: 50.0, font: buttonFont).width
        
        popularButton = UIButton(type: .custom)
        popularButton.setTitle(titles[1], for: .normal)
        popularButton.setTitleColor(UIColor.white, for: .normal)
        popularButton.titleLabel?.font = Fonts.medium(ofSize: 13.0)
        popularButton.alpha = 0.6
        tabStack.addArrangedSubview(popularButton)
        popularTabWidth = UILabel.size(text: titles[1], height: 50.0, font: buttonFont).width
        
        nearbyButton = UIButton(type: .custom)
        nearbyButton.setTitle(titles[2], for: .normal)
        nearbyButton.setTitleColor(UIColor.white, for: .normal)
        nearbyButton.titleLabel?.font = Fonts.medium(ofSize: 13.0)
        nearbyButton.alpha = 0.6
        tabStack.addArrangedSubview(nearbyButton)
        
        nearbyTabWidth = UILabel.size(text: titles[2], height: 50.0, font: buttonFont).width
        
        barView = UIView()
        barView.backgroundColor = UIColor.white
        addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        barWidthAnchor = barView.widthAnchor.constraint(equalToConstant: homeTabWidth)
        barWidthAnchor.isActive = true
        barView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        barLeadingAnchor = barView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        barLeadingAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

class HomeTitleView:JTitleView {
    
    var tabScrollView:TabScrollView!
    
    override init(frame: CGRect, topInset: CGFloat) {
        super.init(frame: frame, topInset: topInset)
        
        rightButton.setImage(UIImage(named:"Settings"), for: .normal)
        leftButton.setImage(UIImage(named:"Switches"), for: .normal)
        
        tabScrollView = TabScrollView(frame: frame, titles: ["POPULAR", "LATEST", "NEARBY"])
        contentView.addSubview(tabScrollView)
        tabScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabScrollView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        tabScrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tabScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        return;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
