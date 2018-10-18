//
//  WebViewController.swift
//  Jungle
//
//  Created by Robert Canton on 2018-10-18.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController:UIViewController {
    
    var titleView:JTitleView!
    var webView :WKWebView!
    var url:URL?
    var loadingBar:UIView!
    var loadingBarWidthAnchor:NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let layoutGuide = view.safeAreaLayoutGuide
        let topInset = UIApplication.deviceInsets.top
        let titleViewHeight = 50 + topInset
        
        titleView = JTitleView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleViewHeight), topInset: topInset)
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        titleView.backgroundImage.image = nil
        titleView.backgroundColor = UIColor.clear
        titleView.leftButton.setImage(UIImage(named:"back"), for: .normal)
        titleView.leftButton.tintColor = UIColor.black
        titleView.titleLabel.text = "Loading..."
        titleView.titleLabel.textColor = UIColor.black
        titleView.leftButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        titleView.insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        
        webView = WKWebView(frame: .zero)
        webView.scrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        view.insertSubview(webView, belowSubview: titleView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        view.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        divider.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -0.5).isActive = true
        divider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        loadingBar = UIView()
        loadingBar.backgroundColor = self.view.tintColor
        view.addSubview(loadingBar)
        loadingBar.translatesAutoresizingMaskIntoConstraints = false
        loadingBar.heightAnchor.constraint(equalToConstant: 2.5).isActive = true
        loadingBar.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -2.5).isActive = true
        loadingBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingBarWidthAnchor = loadingBar.widthAnchor.constraint(equalToConstant: 0)
        loadingBarWidthAnchor.isActive = true
        
        if let url = url {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        } else {
            print("NO LINK SET!")
        }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            DispatchQueue.main.async {
                let progress = Float(self.webView.estimatedProgress)
                self.setLoadingProgress(progress)
            }
        }
    }
    
    func setLoadingProgress(_ progress:Float, animated:Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.displayLoadingProgress(progress)
            })
        } else {
            displayLoadingProgress(progress)
        }
    }
    
    func displayLoadingProgress(_ progress:Float) {
        let newWidth = view.bounds.width * CGFloat(progress)
        self.loadingBarWidthAnchor.constant = newWidth
        if progress >= 1.0 {
            self.loadingBar.alpha = 0.0
            if let title = self.webView.title {
                self.titleView.titleLabel.text = title
            } else {
                self.titleView.titleLabel.text = url?.absoluteString
            }
        }
        self.view.layoutIfNeeded()
    }
}
