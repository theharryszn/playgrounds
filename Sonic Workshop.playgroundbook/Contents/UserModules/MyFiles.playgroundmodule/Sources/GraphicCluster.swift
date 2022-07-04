//  /*#-localizable-zone(GraphicClusterCopyright1)*/Copyright/*#-end-localizable-zone*/ © 2016-2019 Apple Inc. /*#-localizable-zone(GraphicClusterCopyright2)*/All rights reserved./*#-end-localizable-zone*/

import UIKit

//#-localizable-zone(GraphicCluster01)
// The `addGraphicCluster` function displays the graphics in a fan shape and plays each sound as you touch and drag across it. It plays all the sounds together when you double-touch on the cluster.
//#-end-localizable-zone
public func addGraphicCluster(image: Image, sounds: [SonicSound], at point: Point) {
    var graphics = [Graphic]()
    
//#-localizable-zone(GraphicCluster02)
    // For every sound specified in the sounds array when calling the function, create and place a graphic from the provided image.
//#-end-localizable-zone
    for count in 0..<sounds.count {
        let graphic = Graphic(image: image)
        
        graphic.setOnTouchMovedHandler { touch in
            if touch.doubleTouch {
//#-localizable-zone(GraphicCluster03)
                // Double-touch the cluster to play all the sounds and make all of the graphics glow at once.
//#-end-localizable-zone
                for sound in sounds {
                    playSound(sound, volume: 100)
                }
                
                for graphic in graphics {
                    graphic.glow()
                }
            } else if touch.firstTouchInGraphic {
//#-localizable-zone(GraphicCluster04)
                // Touch each graphic one at a time to play its sound and make it glow individually.
//#-end-localizable-zone
                playSound(sounds[count], volume: 100)
                graphic.glow()
            }
        }
        
        var offset = 0.0
        let rainbowColor = Color(hue: Double(count) / Double(sounds.count) * 0.95, saturation: 0.45, brightness: 0.85, alpha: 1.0)
        let scale = Double.random(in: 0.25...0.5)
        
        if sounds.count > 1 {
            offset = Double(count) / Double(sounds.count - 1) - 0.5
        }
        
        scene.place(graphic, at: Point(x: point.x + offset * Double(graphic.size.width) / 2.0, y: point.y + Double(graphic.size.height) * scale / 2.0))
        
//#-localizable-zone(GraphicCluster05)
        // Color, scale, and rotate each graphic.
//#-end-localizable-zone
        graphic.setTintColor(rainbowColor, blend: 1.0)
        graphic.scale = scale
        graphic.rotation = -offset * 60.0
        
        graphic.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: String(format: NSLocalizedString("GraphicCluster item %d", comment: "AX Label: GraphicCluster"), count + 1), actions: [.touch, .doubleTouch])
        
        graphics.append(graphic)
    }
}
