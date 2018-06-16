//
//  NewPostsView.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-19.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol NewPostsButtonDelegate:class {
    func handleRefresh()
}

class NewPostsView:UIView {
    
    var button:UIButton!
    
    weak var delegate:NewPostsButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        button = UIButton(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        let layout = safeAreaLayoutGuide
        
        button.centerXAnchor.constraint(equalTo: layout.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: layout.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.titleLabel?.font = Fonts.regular(ofSize: 14.0)
        button.setTitle("See new posts", for: .normal)
        button.backgroundColor = accentColor
        button.sizeToFit()
        button.layer.cornerRadius = 14.0
        button.clipsToBounds = true
        
        self.applyShadow(radius: 8.0, opacity: 0.35, offset: .zero, color: accentColor, shouldRasterize: false)
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleButton() {
        delegate?.handleRefresh()
    }
}
