//#-hidden-code
//
//  main.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//
//#-code-completion(everything, hide)
//#-code-completion(description, hide, "(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)", "(x: CGFloat, y: CGFloat)", "(x: Float, y: Float)", "(width: CGFloat, height: CGFloat)", "(width: Float, height: Float)", "(point: CGPoint)", "(from: Decoder) throws", "(music: Music, volume: Int)", "playMusic(music: Music, volume: Int)", "(sound: Sound, volume: Int)", "playSound(sound: Sound, volume: Int)", "from(playgroundValue: PlaygroundValue)", "(sound: Sound)", "(sound: Sound, loopFireHandler: (() -> Void)?)")
//#-code-completion(currentmodule, show)
//#-code-completion(literal, show, array, boolean, color, dictionary, image, string, integer, nil)
//#-code-completion(keyword, show, for, func, if, let, var, while)
//#-code-completion(snippet, show, repeat, switch, protocol, enum, struct, class, return)
//#-code-completion(module, show, MyFiles)
//#-code-completion(identifier, show, !, !=, (, (), (image:), (sound:), (x:y:), ), *, +, +=, -, -=, ->, ., /, :, <, =, >, Double, Graphic, Image, Int, SonicMusic, Point, spriteA, spriteB, Point(x:y:), Scene, _:, _:at:, _:blend:, _:volume:, append(_:), backgroundColor, backgroundImage, black, blue, brown, cave, clear, cyan, darkGray, duration:, glow(), gray, green, image, image:, in:, isGridVisible, lab, lightGray, magenta, orange, pi, place, place(_:at:), playMusic(_:volume:), playSound(_:volume:), purple, random(in:), red, scale, scene, setOnTouchHandler, setTintColor(_:blend:), shake(duration:), sound:, sqrt(), turtle, underwater, white, x, x:y:, y, yellow, {, }, alien, alienGoodbye, alienHello, announcement, attack, awakening, caveBeats, chime, chord, chord2, clap, dinnerBell, drums, drums2, eerie, eerie2, flute, harp, hits, hits2, horns, horns2, lightChord, looking, looking3, notes, notes2, piano, ping, ping2, ping3, pluck, shimmer, sonar2, sonar3, sonicSounds, sonicSounds2, sonicSounds3, symbols2, symbols3, tapTap, thudSonar, tink, underwaterThud, vibration, waaaa, weirdYoga, windUp, yoga, yoga2, A1, A2, A3, A4, A5, AS1, AS2, AS3, AS4, AS5, B1, B2, B3, B4, B5,  C1, C2, C3, C4, C5, CS1, CS2, CS3, CS4, CS5, D1, D2, D3, D4, D5, DS1, DS2, DS3, DS4, DS5, E1, E2, E3, E4, E5, F1, F2, F3, F4, F5, FS1, FS2, FS3, FS4, FS5, G1, G2, G3, G4, G5, GS1, GS2, GS3, GS4, GS5, public)
import PlaygroundSupport
import UIKit

//#-end-hidden-code
//#-editable-code
scene.backgroundImage = #imageLiteral(resourceName: "caveBackground")
playMusic(.cave)

//#-localizable-zone(main00k1)
// Create a new graphic.
//#-end-localizable-zone

//#-localizable-zone(main00k2)
// Place your graphic in the scene.
//#-end-localizable-zone

//#-localizable-zone(main00k3)
// Add a touch handler.
//#-end-localizable-zone


//#-end-editable-code
//#-hidden-code
let manager = AssessmentManager()
manager.runAssessmentPage00(scene: scene)
//#-end-hidden-code
