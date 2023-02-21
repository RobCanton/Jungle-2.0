//
//  NearbyHeaderCellNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-17.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import TGPControls

protocol DistanceSliderDelegate:class {
    func proximityChanged(_ proximity:UInt)
}

class NearbyHeaderCellNode:ASCellNode {
    var sliderNode = ASDisplayNode()
    var slider:TGPDiscreteSlider!
    
    var proximityIndex:UInt = 0
    
    weak var delegate:DistanceSliderDelegate?
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        self.selectionStyle = .none
    }
    
    override func didLoad() {
        super.didLoad()
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle("CLOSE", for: .normal)
        closeButton.titleLabel?.font = Fonts.bold(ofSize: 13.0)
        closeButton.setTitleColor(tertiaryColor, for: .normal)
        sliderNode.view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: sliderNode.view.leadingAnchor, constant: 10).isActive = true
        closeButton.topAnchor.constraint(equalTo: sliderNode.view.topAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: sliderNode.view.bottomAnchor).isActive = true
        
        let farButton = UIButton(type: .custom)
        farButton.setTitle("FAR", for: .normal)
        farButton.titleLabel?.font = Fonts.bold(ofSize: 13.0)
        farButton.setTitleColor(tertiaryColor, for: .normal)
        sliderNode.view.addSubview(farButton)
        farButton.translatesAutoresizingMaskIntoConstraints = false
        farButton.trailingAnchor.constraint(equalTo: sliderNode.view.trailingAnchor, constant: -10).isActive = true
        farButton.topAnchor.constraint(equalTo: sliderNode.view.topAnchor).isActive = true
        farButton.bottomAnchor.constraint(equalTo: sliderNode.view.bottomAnchor).isActive = true
        farButton.contentHorizontalAlignment = .right
        
        slider = TGPDiscreteSlider()
        sliderNode.isUserInteractionEnabled = true
        sliderNode.view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 5).isActive = true
        slider.trailingAnchor.constraint(equalTo: farButton.leadingAnchor, constant: -5).isActive = true
        slider.topAnchor.constraint(equalTo: sliderNode.view.topAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: sliderNode.view.bottomAnchor).isActive = true
        slider.tickCount = 4
        slider.backgroundColor = UIColor.clear
        slider.minimumValue = 0
        slider.thumbSize = CGSize(width: 18, height: 18)
        slider.thumbTintColor = tertiaryColor
        slider.tickStyle = 2
        slider.tickSize = CGSize(width: 6, height: 6)
        slider.tintColor = tertiaryColor
        slider.thumbStyle = 2
        slider.maximumTrackTintColor = tertiaryColor.withAlphaComponent(0.5)
        slider.minimumTrackTintColor = tertiaryColor
        slider.thumbShadowOffset = CGSize(width: 0, height: 4)
        slider.thumbShadowRadius = 4
        
        slider.addTarget(self, action: #selector(distanceChanged), for: .touchUpInside)
        slider.addTarget(self, action: #selector(distanceChanged), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(distanceChanged), for: .touchDragExit)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        sliderNode.style.height = ASDimension(unit: .points, value: 32.0)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 4, 4, 4), child: sliderNode)
    }
    
    @objc func distanceChanged(_ sender: TGPDiscreteSlider, event:UIEvent) {
        let index = UInt(sender.value)
        if index != proximityIndex {
            proximityIndex = index
            delegate?.proximityChanged(proximityIndex)
            slider.alpha = 0.5
            slider.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.slider.alpha = 1.0
                self.slider.isUserInteractionEnabled = true
            })
            
        }
    }
}
