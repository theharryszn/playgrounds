//  /*#-localizable-zone(ToneGeneratorCopyright1)*/Copyright/*#-end-localizable-zone*/ © 2016-2019 Apple Inc. /*#-localizable-zone(ToneGeneratorCopyright2)*/All rights reserved./*#-end-localizable-zone*/

import UIKit

let toneOutput = ToneOutput()

//#-localizable-zone(ToneGenerator01)
// The `addTones` function uses the position of your touch along the y axis to change the tones being played.
//#-end-localizable-zone
public func addTones(image: Image, at point: Point) {
    let graphic = Graphic(image: image)
    
//#-localizable-zone(ToneGenerator02)
    // The touch moved handler takes a touch as an argument. You can use this value to manipulate the tones being played.
//#-end-localizable-zone
    graphic.setOnTouchMovedHandler { touch in
        if touch.touchedGraphic == graphic && !touch.lastTouchInGraphic {
            let range = 10.0
            let pitch = (graphic.position.y - graphic.size.height / 2.0 - touch.position.y) * range
            let tone = Tone(pitch: pitch, volume: 1.0)
            
//#-localizable-zone(ToneGenerator03)
            // Play a tone based on the touch position in relation to the graphic.
//#-end-localizable-zone
            toneOutput.play(tone: tone)
        } else {
//#-localizable-zone(ToneGenerator04)
            // Stop the tones when the graphic is not receiving touch events.
//#-end-localizable-zone
            toneOutput.stopTones()
        }
    }
    
//#-localizable-zone(ToneGenerator05)
    // Place and scale the graphic.
//#-end-localizable-zone
    scene.place(graphic, at: point)
    
    graphic.scale = 0.5
    
    graphic.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: NSLocalizedString("ToneGenerator", comment: "AX Label: ToneGenerator"), actions: [.drag])
}
