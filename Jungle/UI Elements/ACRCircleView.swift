
//
//  CircleView.swift
//  License: MIT
//
//  Created by Andrew Crookston <andrew@caoos.com> on 4/25/15.
//
//
import UIKit

class ACRCircleView: UIView, CAAnimationDelegate {
    
    // MARK: Configurable values
    var strokeWidth : CGFloat = 2.0 {
        didSet {
            basePathLayer.lineWidth = strokeWidth
            circlePathLayer.lineWidth = strokeWidth
        }
    }
    
    override var tintColor : UIColor! {
        didSet {
            circlePathLayer.strokeColor = tintColor.cgColor
        }
    }
    
    var baseColor : UIColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1) {
        didSet {
            basePathLayer.strokeColor = baseColor.cgColor
        }
    }
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1.0) {
                circlePathLayer.strokeEnd = 0.0
            } else if (newValue < 0.0) {
                circlePathLayer.strokeEnd = 1.0
            } else {
                circlePathLayer.strokeEnd = 1 - newValue
            }
        }
    }
    
    // MARK: Init
    private let basePathLayer = CAShapeLayer()
    private let circlePathLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        configure()
    }
    
    func startAnimating() {
        var animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 2 * M_PI
        animation.toValue = 0.0
        // this might be too fast
        animation.duration = 1
        // HUGE_VALF is defined in math.h so import it
        animation.repeatCount = Float.infinity
        circlePathLayer.add(animation, forKey: "rotation")
    }

    func animateFrom(_ progress:CGFloat, to toProgress:CGFloat) {
        //circlePathLayer.removeAnimation(forKey: "MyAnimation")
        //circlePathLayer.strokeEnd = 1 - progress
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue =  1 - progress
        animation.toValue =  1 - toProgress
        
        animation.duration = 10
        animation.isRemovedOnCompletion = true
        
        circlePathLayer.add(animation, forKey: "MyAnimation")
        
        
    }
    
    
    func stopAnimating() {
        circlePathLayer.removeAnimation(forKey: "rotation")
    }
    
    // MARK: Internal
    private func configure() {
        
        basePathLayer.frame = bounds
        basePathLayer.lineWidth = strokeWidth
        basePathLayer.fillColor = UIColor.clear.cgColor
        basePathLayer.strokeColor = baseColor.cgColor
        basePathLayer.actions = ["strokeEnd": NSNull()]
        layer.addSublayer(basePathLayer)
        
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = strokeWidth
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = tintColor.cgColor
        // make optional for animated? See: http://stackoverflow.com/questions/21688363/change-cashapelayer-without-animation
        circlePathLayer.actions = ["strokeEnd": NSNull()]
        // rotate the layer negative 90deg to make it start at the top. 12 o'clock, default is 3 o'clock.
        circlePathLayer.transform = CATransform3DMakeRotation(-CGFloat(90.0 / 180.0 * M_PI), 0.0, 0.0, 1.0)
        
        layer.addSublayer(circlePathLayer)
        
        progress = 0
    }
    
    private func circleFrame() -> CGRect {
        // keep the circle inside the bounds
        let shorter = (bounds.width > bounds.height ? bounds.height : bounds.width) - strokeWidth
        var circleFrame = CGRect(x: 0, y: 0, width: shorter, height: shorter)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    private func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        basePathLayer.frame = bounds
        basePathLayer.path = circlePath().cgPath
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
}
