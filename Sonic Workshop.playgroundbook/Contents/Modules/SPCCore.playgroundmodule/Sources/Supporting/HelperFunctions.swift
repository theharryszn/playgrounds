//
//  HelperFunctions.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import GameplayKit

/// Numerical representation for pi (~3.14).
/// Numerical representation for π (~3.14).
///
/// - localizationKey: pi
public var pi = Double.pi

public extension String {
    
    /// Splits the string into its component characters and returns them as an array.
    ///
    /// - localizationKey: String.componentsByCharacter()
    func componentsByCharacter() -> [String] {
        /*
         Note: This cannot simply be implemented as self.characters.map { String($0) } since some emojis are sequences of characters (for example, a face with a skin tone modifer); meaning, composed character sequences.
         */
        var sequences = [String]()
        let range = self.startIndex ..< self.endIndex
        self.enumerateSubstrings(in: range, options: .byComposedCharacterSequences) {sequence,_,_,_ in
            if let sequence = sequence {
                sequences.append(sequence)
            }
        }
        return sequences
    }
    
    /// Returns a random composed character sequence as a String.
    ///
    /// - localizationKey: String.randomCharacter
    var randomCharacter: String {
        return String(Array(self).randomElement() ?? Character(""))
    }
    
    /// Returns the number of characters in the string.
    ///
    /// - localizationKey: String.numberOfCharacters
    var numberOfCharacters: Int {
        return self.count
    }
    
    /// Returns the string with any whitespace characters removed.
    ///
    /// - localizationKey: String.withoutWhitespace
    var withoutWhitespace: String {
        let separatedComponents = self.components(separatedBy: .whitespaces)
        return separatedComponents.joined()
    }
    
    /// Returns the string with the characters reversed.
    ///
    /// - localizationKey: String.reversed()
    func reversed() -> String {
        
        let reversedCharacters = self.componentsByCharacter().reversed()
        return reversedCharacters.joined()
    }
    
    /// Returns the string with the characters randomly shuffled.
    ///
    /// - localizationKey: String.shuffled()
    func shuffled() -> String {
        
        let shuffledCharacters = self.componentsByCharacter().shuffled()
        return shuffledCharacters.joined()
    }
}

public struct Constants {
    public static let userValueRange: ClosedRange<Int> = 0...100
    
    public static var maxUserValue: Int {
        return userValueRange.upperBound
    }
}

public extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return clamped(from: range.lowerBound, to: range.upperBound)
    }
    
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return max(lowerBound, min(upperBound, self))
    }
}

// In this app, we are clamping the values the user can enter to a defined range to be more approachable. This extension is used to apply it consistently across the app.
public extension ClampedInteger {
    init(clampedUserValueWithDefaultOf integer: Int) {
        self.init(integer, in: Constants.userValueRange)
    }
}

public extension Array {
    
    /// A randomly chosen index into the array.
    ///
    /// - localizationKey: Array.randomIndex
    var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(self.count)))
    }
    
    /// A randomly chosen item from the array.
    ///
    /// - localizationKey: Array.randomItem
    var randomItem: Element {
        return self[self.randomIndex]
    }
    
    /// Shuffles the items of the array in place.
    ///
    /// - localizationKey: Array.shuffle()
    mutating func shuffle() {
        self = shuffled()
    }
    
    /// Returns a copy of the array with its items shuffled.
    ///
    /// - localizationKey: Array.shuffled()
    func shuffled() -> [Element] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self) as! [Element]
    }
}

extension Point {
    
    /// Returns the distance from another point.
    ///
    /// - Parameter from: The point from which to measure distance.
    ///
    /// - localizationKey: Point.distance(from:)
    public func distance(from: Point) -> Double {
        
        let distanceVector = Point(x: from.x - self.x, y: from.y - self.y)
        return Double(sqrt(Double(distanceVector.x * distanceVector.x) + Double(distanceVector.y * distanceVector.y)))
    }
    
    /// Returns a vector to the specified point.
    ///
    /// - Parameter to: The vector’s endpoint.
    ///
    /// - localizationKey: Point.vector(to:)
    public func vector(to: Point) -> Vector {
        return Vector(dx: to.x - self.x, dy: to.y - self.y)
    }
    
    /// Returns the point calculated by adding a vector to a point.
    /// - Parameter lhs: The point.
    /// - Parameter rhs: The vector.
    ///
    /// - localizationKey: Point.+(Point,Vector)
    public static func + (lhs: Point, rhs: Vector) -> Point {
        return Point(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }
    
    /// Adds the vector to the point and assigns the result to the point.
    /// - Parameter lhs: The point.
    /// - Parameter rhs: The vector.
    ///
    /// - localizationKey: Point.+=(Point,Vector)
    public static func += (lhs: inout Point, rhs: Vector) {
        lhs = lhs + rhs
    }
}

extension Vector {
    
    /// Returns the point calculated by adding a vector to a point.
    /// - Parameter lhs: The vector.
    /// - Parameter rhs: The point.
    ///
    /// - localizationKey: Point.+(Vector,Point)
    public static func + (lhs: Vector, rhs: Point) -> Point {
        return rhs + lhs
    }
}

public extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = UIScreen.main.scale
        
        let scaledImageRect = CGRect(origin: .zero, size: size)
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageRect.size)
        let scaledImage = renderer.image { _ in
            self.draw(in: scaledImageRect)
        }
        return scaledImage
    }
    
    var isEmpty: Bool {
        return (size.width == 0) || (size.height == 0)
    }
    
    func scaledToFit(within availableSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = availableSize.width / self.size.width
        let aspectHeight = availableSize.height / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageRect.size, format: rendererFormat)
        let scaledImage = renderer.image { _ in
            self.draw(in: scaledImageRect)
        }
        return scaledImage
    }
    
    func scaledAndCroppedToMatchAspectRatio(of aspectSize: CGSize) -> UIImage {
        let aspectWidth = self.size.width  / aspectSize.width
        let aspectHeight = self.size.height / aspectSize.height
        let scalingFactor = min(aspectWidth, aspectHeight)
        let newSize = CGSize(width:  aspectSize.width  * scalingFactor,
                             height: aspectSize.height * scalingFactor)
        let drawRect = CGRect(origin: CGPoint(x: (newSize.width  - size.width)  / 2,
                                              y: (newSize.height - size.height) / 2),
                              size: size)
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: rendererFormat)
        let scaledImage = renderer.image { _ in
            self.draw(in: drawRect)
        }
        return scaledImage
    }
    
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create UIImage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageByApplyingClippingBezierPath(_ path: UIBezierPath, cropToPath: Bool = true) -> UIImage? {
        guard
            // Mask image using path.
            let maskedImage = imageByApplyingMaskingBezierPath(path)
            else { return nil }
        
        if cropToPath {
            // Crop image to frame of path.
            guard let croppedCGImage = maskedImage.cgImage?.cropping(to: path.bounds) else { return nil }
            return UIImage(cgImage: croppedCGImage)
        } else {
            return maskedImage
        }
    }
    
    func imageByApplyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()
        
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    func disabledImage(alpha: CGFloat) -> UIImage? {
        let context = CIContext(options: nil)
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let output = filter.outputImage else { return nil }
        
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        return UIAccessibility.isReduceTransparencyEnabled ? processedImage : processedImage.imageWithAlpha(alpha: alpha)
    }
    
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns an image for text.
    ///
    /// - Parameter text: The placeholder text used to represent an image.
    ///
    /// - localizationKey: UIImage.image(text:)
    static func image(text: String, fontSize: CGFloat = 40) -> UIImage {
        let defaultSize = CGSize(width: 23, height: 27) // Default size for emoji with the chosen font and font size.
        let textColor: UIColor =  #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let font = UIFont(name: "System0.00", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
        
        let sourceCharacter = text as NSString
        let attributes: [NSAttributedString.Key: Any] = [.font : font, .foregroundColor: textColor]
        var textSize = sourceCharacter.size(withAttributes: attributes)
        if textSize.width < 1 || textSize.height < 1 {
            textSize = defaultSize
        }
        UIGraphicsBeginImageContextWithOptions(textSize, false, UIScreen.main.scale)
        sourceCharacter.draw(in: CGRect(x:0, y:0, width: textSize.width,  height: textSize.height), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    func colorize(color: UIColor, blend: CGFloat) -> UIImage? {
        let context = CIContext(options: nil)
        let ciColor = CIColor(red: CGFloat(color.redComponent), green: CGFloat(color.greenComponent), blue: CGFloat(color.blueComponent))
        guard let colorizeFilter = CIFilter(name: "CIColorMonochrome", parameters: [kCIInputImageKey : CIImage(image: self) as Any,
                                                                                    kCIInputColorKey : ciColor,
                                                                                    kCIInputIntensityKey : blend]) else { return nil }
        guard let colorizeOutput = colorizeFilter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(colorizeOutput, from: colorizeOutput.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}

extension CGSize {
    
    /// Returns a size that fits within the given size, while preserving this size’s aspect ratio.
    ///
    /// - Parameter within: The size (width and height) within which the size must fit.
    ///
    /// - localizationKey: CGSize.fit(within:)
    public func fit(within: CGSize) -> CGSize  {
        
        let ratio = width > height ?  (height / width) : (width / height)
        
        if width >= height {
            return CGSize(width: within.width, height: within.width * ratio)
        }
        else {
            return CGSize(width: within.height * ratio, height: within.height)
        }
    }
}

public extension SKScene {
    var center: CGPoint { return CGPoint(x: size.width / 2, y: size.height / 2) }
}

/// Generates a random Int (whole number) in the given range.
///
/// - Parameter from: The lowest value that the random number can have.
/// - Parameter to: The highest value that the random number can have.
///
/// - localizationKey: randomInt(from:to:)
public func randomInt(from: Int, to: Int) -> Int {
    let maxValue: Int = max(from, to)
    let minValue: Int = min(from, to)
    if minValue == maxValue {
        return minValue
    } else {
        return (Int(arc4random())%(1 + maxValue - minValue)) + minValue
    }
}

/// Generates a random Double (decimal number) in the given range.
///
/// - Parameter from: The lowest value that the random number can have.
/// - Parameter to: The highest value that the random number can have.
///
/// - localizationKey: randomDouble(from:to:)
public func randomDouble(from: Double, to: Double) -> Double {
    let maxValue = max(from, to)
    let minValue = min(from, to)
    if minValue == maxValue {
        return minValue
    } else {
        // Between 0.0 and 1.0
        let randomScaler = Double(arc4random()) / Double(UInt32.max)
        return (randomScaler * (maxValue-minValue)) + minValue
    }
}

extension Double {
    public func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    public func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumIntegerDigits = 1
        return formatter.string(for: self)!
    }
}
