//
//  TailLoadingCellNode.swift
//  Sample
//
//  Created by Adlai Holler on 2/1/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the /ASDK-Licenses directory of this source tree. An additional
//  grant of patent rights can be found in the PATENTS file in the same directory.
//
//  Modifications to this file made after 4/13/2017 are: Copyright (c) 2017-present,
//  Pinterest, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

import AsyncDisplayKit
import UIKit

final class LoadingCellNode: ASCellNode {
    let spinner = SpinnerNode()
    let text = ASTextNode()
    
    override init() {
        super.init()
        
        addSubnode(text)
        text.attributedText = NSAttributedString(
            string: "Loading…",
            attributes: [
                NSAttributedStringKey.font: Fonts.regular(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ])
        addSubnode(spinner)
    }
    
    override func didLoad() {
        super.didLoad()
        spinner.startAnimating()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 16,
            justifyContent: .center,
            alignItems: .center,
            children: [ spinner, text ])
    }
}

final class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }
    
    override init() {
        super.init()
        setViewBlock {
            UIActivityIndicatorView(activityIndicatorStyle: .white)
        }
        
        // Set spinner node to default size of the activitiy indicator view
        self.style.preferredSize = CGSize(width: 20.0, height: 20.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.hidesWhenStopped = true
        //activityIndicatorView.startAnimating()
    }
    
    func startAnimating() {
        activityIndicatorView.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}

