//
//  BarButton.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport

open class BarButton: UIButton {
    
    private var blurView = UIVisualEffectView(effect: nil)
    
    private let spacing = CGFloat(20.0)
    private let buttonSize = CGSize(width: 44, height: 44)
    
    public var presenter: (UIViewController & BarButtonPresentationProtocol & PlaygroundLiveViewSafeAreaContainer)?
    
    public var showsBackground = true {
        didSet {
            blurView.isHidden = !showsBackground
        }
    }
    
    public var backgroundScale: CGFloat {
        get {
            let transform = blurView.transform
            return sqrt(transform.a * transform.a + transform.c * transform.c)
        }
        set {
            blurView.transform = CGAffineTransform(scaleX: newValue, y: newValue)
        }
    }
    
    public func setSelected(_ selected: Bool, delay: Double, duration: Double) {
        guard let imageView = self.imageView, let currentImage = imageView.image, let normalImage = image(for: .normal), let selectedImage = image(for: .selected) else { return }
        
        let newImage = selected ? selectedImage : normalImage
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isSelected = selected
        }
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.fromValue = currentImage.cgImage
        animation.toValue = newImage.cgImage
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        imageView.layer.add(animation, forKey: "imageLayerAnimation")
        CATransaction.commit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        
        blurView.effect = UIBlurEffect(style: .extraLight)
        if #available(iOS 13.0, *) {
            blurView.effect = UIBlurEffect(style: .systemMaterial)
        }
        
        updateInsets()
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.frame = bounds
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)
        
        let highPriorityWidth = widthAnchor.constraint(equalToConstant: buttonSize.width)
        let highPriorityHeight = heightAnchor.constraint(equalToConstant: buttonSize.height)
        
        highPriorityWidth.priority = .defaultHigh
        highPriorityHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            highPriorityWidth,
            highPriorityHeight,
            blurView.widthAnchor.constraint(equalTo: widthAnchor),
            blurView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    private func updateInsets() {
        contentEdgeInsets = UIEdgeInsets.zero
        imageEdgeInsets = UIEdgeInsets.zero
        titleEdgeInsets = UIEdgeInsets.zero
        if let _ = imageView?.image, let title = titleLabel?.text, !title.isEmpty {
            contentEdgeInsets = UIEdgeInsets(top: 11, left: spacing, bottom: 11, right: spacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing / 2)
        }
    }
    
    override open func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateInsets()
    }
    
    override open func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        updateInsets()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        blurView.layer.cornerRadius = bounds.size.width / 2.0
        sendSubviewToBack(blurView)
    }
}
