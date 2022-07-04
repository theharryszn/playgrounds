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
//#-code-completion(identifier, show, !, !=, (, (), (image:), (sound:), (x:y:), ), *, +, +=, -, -=, ->, ., /, :, <, =, >, Color, Double, Graphic, Image, Instrument, Int, Kind, SonicMusic, Point, spriteA, spriteB, Point(x:y:), Scene, SonicSound, _:, _:at:, _:blend:, after:, alpha, append(_:), backgroundColor, backgroundImage, bassGuitar, bassSynth, black, blue, brown, by:duration:, cave, clear, crystalSynth, cyan, darkGray, duration:, electricGuitar, fadeIn(after:), fadeOut(after:), glow(), gray, green, image, image:, in:, isGridVisible, lab, lightGray, magenta, orange, period:count:, pi, piano, place, place(_:at:), playInstrument(_:note:volume:), playMusic(_:volume:), playSound(_:volume:), position, pulsate(period:count:), purple, random(in:), red, rotation, scale, scale(by:duration:), scale(to:duration:), scene, setOnTouchHandler, setTintColor(_:blend:), sevenSynth, shake(duration:), size, sound:, sqrt(), to:duration:, turtle, underwater, warmBells, white, x, x:y:, y, yellow, {, }, ahh, backUp, beat, beat2, beat3, birds, birds1, bloops, clomp, comingTo, droplet2, droplet3, dumDeDum, handDrums, jungle, layer, lightsUp, oneTwoThree, ringing, shaker, sharps, shimmer2, shipwreck, silverware, sonar5, steelDrums, stickDrop, thinking, thinking2, tide, tide2, tinkTink, vocals, warble, ratchet, zip, A1, A2, A3, A4, A5, AS1, AS2, AS3, AS4, AS5, B1, B2, B3, B4, B5,  C1, C2, C3, C4, C5, CS1, CS2, CS3, CS4, CS5, D1, D2, D3, D4, D5, DS1, DS2, DS3, DS4, DS5, E1, E2, E3, E4, E5, F1, F2, F3, F4, F5, FS1, FS2, FS3, FS4, FS5, G1, G2, G3, G4, G5, GS1, GS2, GS3, GS4, GS5, public)
import PlaygroundSupport
import UIKit

//#-end-hidden-code
//#-editable-code
scene.backgroundImage = #imageLiteral(resourceName: "turtleBackground")
playMusic(.turtle)

//#-localizable-zone(main01k1)
// Call your function.
//#-end-localizable-zone



//#-end-editable-code
//#-hidden-code
let manager = AssessmentManager()
manager.runAssessmentPage01(scene: scene)

//#-end-hidden-code
