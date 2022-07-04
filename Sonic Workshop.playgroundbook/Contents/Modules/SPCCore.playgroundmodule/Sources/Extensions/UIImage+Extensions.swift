//
//  UIImage+Extensions.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit

extension UIImage {
    /// Returns a copy of the image overlaid with another image in the center.
    ///
    /// - Parameter overlayImage: The image to overlay.
    /// - Parameter offset: The amount by which to offset the overlay image from the center. Defaults to zero.
    ///
    /// - localizationKey: UIImage.overlaid(with:offsetBy:)
    public func overlaid(with overlayImage: UIImage, offsetBy offset: CGPoint = CGPoint.zero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(at: CGPoint.zero)
        overlayImage.draw(at: CGPoint(x: (size.width / 2 - overlayImage.size.width / 2) + offset.x,
                                      y: (size.height / 2 - overlayImage.size.height / 2) + offset.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
