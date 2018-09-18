//
//  File.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-12.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

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
        
        self.backgroundColor = hexColor(from: "00B86A")//currentTheme.backgroundColor
        backgroundImage = UIImageView(image: UIImage(named: "GreenBox"))
        
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
        titleLabel.font = Fonts.bold(ofSize: 13.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol TabScrollDelegate:class {
    func tabScrollTo(index:Int)
}

class TabScrollView:UIView {
    
    weak var delegate:TabScrollDelegate?
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
        
        let buttonFont = Fonts.bold(ofSize: 13.0)
        homeButton = UIButton(type: .custom)
        homeButton.setTitle(titles[0], for: .normal)
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.titleLabel?.font = buttonFont
        tabStack.addArrangedSubview(homeButton)
        
        homeTabWidth = UILabel.size(text: titles[0], height: 50.0, font: buttonFont).width
        
        popularButton = UIButton(type: .custom)
        popularButton.setTitle(titles[1], for: .normal)
        popularButton.setTitleColor(UIColor.white, for: .normal)
        popularButton.titleLabel?.font = buttonFont
        popularButton.alpha = 0.6
        tabStack.addArrangedSubview(popularButton)
        popularTabWidth = UILabel.size(text: titles[1], height: 50.0, font: buttonFont).width
        
        nearbyButton = UIButton(type: .custom)
        nearbyButton.setTitle(titles[2], for: .normal)
        nearbyButton.setTitleColor(UIColor.white, for: .normal)
        nearbyButton.titleLabel?.font = buttonFont
        nearbyButton.alpha = 0.6
        tabStack.addArrangedSubview(nearbyButton)
        
        nearbyTabWidth = UILabel.size(text: titles[2], height: 50.0, font: buttonFont).width
        
        barView = UIView()
        barView.backgroundColor = UIColor.clear//white.withAlphaComponent(0.35)
        addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        barWidthAnchor = barView.widthAnchor.constraint(equalToConstant: homeTabWidth)
        barWidthAnchor.isActive = true
        barView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        barView.layer.cornerRadius = 1.0
        barView.clipsToBounds = true
        
        barLeadingAnchor = barView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        barLeadingAnchor.isActive = true
        barView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        barView.clipsToBounds = false
        
        let b = UIView()
        b.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        barView.addSubview(b)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: -8).isActive = true
        b.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: 8).isActive = true
        b.topAnchor.constraint(equalTo: barView.topAnchor).isActive = true
        b.bottomAnchor.constraint(equalTo: barView.bottomAnchor).isActive = true
        
        b.layer.cornerRadius = 14
        b.clipsToBounds = true
        
        popularButton.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
        nearbyButton.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress:CGFloat, index:Int) {
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
    
    @objc func handleTab(_ sender:UIButton) {
        switch sender {
        case homeButton:
            delegate?.tabScrollTo(index: 0)
            break
        case popularButton:
            delegate?.tabScrollTo(index: 1)
            break
        case nearbyButton:
            delegate?.tabScrollTo(index: 2)
            break
        default:
            break
        }
    }
    
}

class HomeTitleView:JTitleView {
    
    var tabScrollView:TabScrollView!
    
    override init(frame: CGRect, topInset: CGFloat) {
        super.init(frame: frame, topInset: topInset)
        
        rightButton.setImage(UIImage(named:"Groups"), for: .normal)
        //leftButton.setImage(UIImage(named:"Switches"), for: .normal)
        
        tabScrollView = TabScrollView(frame: frame, titles: ["FEATURED", "MY GROUPS", "NEARBY"])
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

class DualScrollView:UIView {
    
    weak var delegate:TabScrollDelegate?
    var barView:UIView!
    
    var barLeadingAnchor:NSLayoutConstraint!
    
    var button1:UIButton!
    var button2:UIButton!

    
    init(frame:CGRect, title1:String, title2:String) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.preservesSuperviewLayoutMargins = false
        self.insetsLayoutMarginsFromSafeArea = false
        
        let buttonFont = Fonts.semiBold(ofSize: 13.0)
        button1 = UIButton(type: .custom)
        button1.setTitle(title1, for: .normal)
        button1.setTitleColor(UIColor.white, for: .normal)
        button1.titleLabel?.font = buttonFont
        
        
        
        button2 = UIButton(type: .custom)
        button2.setTitle(title2, for: .normal)
        button2.setTitleColor(UIColor.white, for: .normal)
        button2.titleLabel?.font = buttonFont
        button2.alpha = 0.6

        addSubview(button1)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button1.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button1.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button1.widthAnchor.constraint(equalToConstant: frame.width/2).isActive = true
        addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false
        //button2.leadingAnchor.constraint(equalTo: button1.trailingAnchor).isActive = true
        button2.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button2.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button2.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button2.widthAnchor.constraint(equalToConstant: frame.width/2).isActive = true
        
        barView = UIView()
        barView.backgroundColor = UIColor.white
        addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView.widthAnchor.constraint(equalToConstant: frame.width/2).isActive = true
        
        barView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        barLeadingAnchor = barView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        barLeadingAnchor.isActive = true
        barView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        button1.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
        button2.addTarget(self, action: #selector(handleTab), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress:CGFloat, index:Int) {
        barLeadingAnchor.constant = (frame.width/2) * progress
        button1.alpha = 0.6 + 0.4 * (1 - progress)
        button2.alpha = 0.6 + 0.4 * progress
        self.layoutIfNeeded()
    }
    
    @objc func handleTab(_ sender:UIButton) {
        switch sender {
        case button1:
            delegate?.tabScrollTo(index: 0)
            break
        case button2:
            delegate?.tabScrollTo(index: 1)
            break
        default:
            break
        }
    }
    
}
