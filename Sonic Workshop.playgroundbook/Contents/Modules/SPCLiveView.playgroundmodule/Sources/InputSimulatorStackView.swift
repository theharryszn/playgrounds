//
//  InputSimulatorStackView.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit

public class InputSimulatorStackView : UIStackView {
    override public var axis: NSLayoutConstraint.Axis {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        get {
            var size = CGSize.zero
            
            arrangedSubviews.forEach {
                if axis == .horizontal {
                    size.width += $0.intrinsicContentSize.width
                    size.height = max(size.height, $0.intrinsicContentSize.height)
                } else {
                    size.width = max(size.width, $0.intrinsicContentSize.width)
                    size.height += $0.intrinsicContentSize.height
                }
            }
            
            return size
        }
    }
}
