//  /*#-localizable-zone(CaveGlitterCopyright1)*/Copyright/*#-end-localizable-zone*/ © 2016-2019 Apple Inc. /*#-localizable-zone(CaveGlitterCopyright2)*/All rights reserved./*#-end-localizable-zone*/

import UIKit

//#-localizable-zone(CaveGlitter01)
// The `addCaveGlitter` function randomly places graphics in a small area. The cave glitter plays different notes and glows as you touch and drag across it.
//#-end-localizable-zone
public func addCaveGlitter(count: UInt, color: Color, gradientColor: Color, at point: Point) {
//#-localizable-zone(CaveGlitter02)
    // For every glitter particle, place a shape at a random location.
//#-end-localizable-zone
    var accessibilityGroup: String?
    
    for _ in 0..<count {
        let scale = Double(count) * 2.0
        let deltaX = Double.random(in: -1.0...1.0) * scale
        let deltaY = Double.random(in: -1.0...1.0) * scale
        let shapePoint = Point(x: point.x + deltaX, y: point.y + deltaY)
        let randomRadius = Int.random(in: 3...6)
        let shape = Graphic(shape: Shape.polygon(radius: randomRadius, sides: 5), color: color, gradientColor: gradientColor)
        shape.rotation = Double.random(in: 0...360)
        
        if accessibilityGroup == nil {
            accessibilityGroup = shape.id
        }
        
        scene.place(shape, at: shapePoint)
        
//#-localizable-zone(CaveGlitter03)
        // Play a note and glow when the shape receives a touch event.
//#-end-localizable-zone
        shape.setOnTouchMovedHandler { touch in
            if touch.firstTouchInGraphic {
                let noteCount = Double(Instrument.Kind.crystalSynth.availableNotes.count)
                let note = ((shape.position.x - point.x) / scale + 1.0) / 2.0 * noteCount
                
                playInstrument(.crystalSynth, note: note, volume: 100)
                shape.glow()
            }
        }
        shape.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: NSLocalizedString("CaveGlitter", comment: "AX Label: CaveGlitter"), actions: [.touch, .drag], groupID: accessibilityGroup)
    }
}
