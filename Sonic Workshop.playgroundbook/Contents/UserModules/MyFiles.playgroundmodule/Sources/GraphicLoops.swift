//  /*#-localizable-zone(GraphicLoopsCopyright1)*/Copyright/*#-end-localizable-zone*/ © 2016-2019 Apple Inc. /*#-localizable-zone(GraphicLoopsCopyright2)*/All rights reserved./*#-end-localizable-zone*/

import UIKit

//#-localizable-zone(GraphicLoops01)
// The `addGraphicLoops` function arranges several graphics as a cluster. When you touch each graphic in the cluster, it toggles the sound associated with that graphic on and off.
//#-end-localizable-zone
public func addGraphicLoops(image: Image, sounds: [SonicSound], at point: Point) {
    for count in 0..<sounds.count {
        let graphic = Graphic(image: image)
        
//#-localizable-zone(GraphicLoops02)
        // For every sound specified in the sounds array when calling the function, create a graphic and a loop which plays the sound and causes that graphic to glow on each cycle.
//#-end-localizable-zone
        let loop = Loop(sound: sounds[count])
        loop.loopFireHandler = {
            graphic.glow(radius: 20, period: loop.length, count: 1)
        }
        
        graphic.setOnTouchMovedHandler { touch in
//#-localizable-zone(GraphicLoops03)
            // Turn each graphic on and off when it receives a touch event.
//#-end-localizable-zone
            if touch.firstTouch {
                loop.toggle()
            }
        }
        
        let deltaX = Double.random(in: -1.0...1.0) * Double(count + 1) * Double(graphic.size.width) / 7.5
        let scale = Double(sounds.count - count / 2) / Double(count + 2) / 3.5
        
//#-localizable-zone(GraphicLoops04)
        // Arrange, scale, rotate, and place each graphic according to its size and the number of sounds.
//#-end-localizable-zone
        scene.place(graphic, at: Point(x: point.x + deltaX, y: point.y - (1 - scale) * Double(graphic.size.height) / 2.0))
        
        graphic.scale = scale
        graphic.rotation = Double.random(in: -15.0...15.0)
        
        graphic.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: String(format: NSLocalizedString("GraphicLoop group item %d", comment: "AX Label: GraphicLoop"), count + 1), actions: [.touch])
    }
}
