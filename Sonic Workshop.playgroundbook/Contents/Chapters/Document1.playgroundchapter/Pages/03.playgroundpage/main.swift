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
//#-code-completion(identifier, show, !, !=, (, (), (hue:saturation:brightness:alpha:), (image:), (sound:), (x:y:), ), *, +, +=, -, -=, ->, ., /, :, <, =, >, A1, A2, A3, A4, A5, AS1, AS2, AS3, AS4, AS5, B1, B2, B3, B4, B5, C1, C2, C3, C4, C5, CS1, CS2, CS3, CS4, CS5, Color, D1, D2, D3, D4, D5, DS1, DS2, DS3, DS4, DS5, Double, E1, E2, E3, E4, E5, F1, F2, F3, F4, F5, FS1, FS2, FS3, FS4, FS5, G1, G2, G3, G4, G5, GS1, GS2, GS3, GS4, GS5, Graphic, Image, Instrument, Int, Kind, Loop, SonicMusic, Point, spriteA, spriteB, Point(x:y:), Scene, Shape, Size, SonicSound, Touch, _:, _:at:, _:blend:, _:note:volume:, _:volume:, addCaveGlitter(count:color:gradientColor:at:), addGraphicCluster(image:sounds:at:), addGraphicLoops(image:sounds:at:), addInstrument(image:color:at:), addTones(image:at:), after:, alpha, append(_:), availableNotes, backgroundColor, backgroundImage, bassGuitar, bassSynth, black, blue, boops, boops2, brokenGlass, brown, by:duration:, cave, circle(radius:), circle(radius:color:gradientColor:), clear, createCrystal(image:sound:), crystalSynth, cyan, darkGray, drill, duration:, electricGuitar, email, explosion, explosion2, fadeIn(after:), fadeOut(after:), from(_:), galacticChime, galacticHorns, galacticSonar, galacticTelephone, gentle, getReady, glassClink, glow(), glow(radius:period:count:), gray, green, height, hue:saturation:brightness:alpha:, image, image:, image:color:at:, image:sound:, image:sounds:at:, image:sounds:color:at:, in:, init(image:name:), init(shape:color:), init(shape:color:gradientColor:name:), init(width:height:), isGridVisible, lab, labBeats, labBeats2, length, lightGray, loopFireHandler, magenta, onTouchHandler, onTouchMovedHandler, orange, ount:color:gradientColor:at:, period:count:, pi, piano, place(_:at:), playInstrument(_:note:volume:), playMusic(_:volume:), playSound(_:volume:), playing, polygon(radius:sides:), position, printer, public, pulsate(period:count:), purple, radius:color:gradientColor:, radius:period:count:, radius:points:sharpness:, radius:sides:, random(in:), rectangle(width:height:cornerRadius:), red, rotation, scale, scale(by:duration:), scale(to:duration:), scene, setOnTouchHandler, setOnTouchMovedHandler(_:), setTintColor(_:blend:), sevenSynth, shake(duration:), shape:color:, size, slime, sound, sound:, spaceCarnival, spaceHorns, spaceInvadors, spaceTrance, sqrt(), star(radius:points:sharpness:), teslaCoil, text:color:, to:duration:, toggle(), tuneIn, turtle, underwater, volume, warmBells, white, width, width:height:cornerRadius:, x, x:y:, y, yellow, {, })

import PlaygroundSupport
import UIKit

//#-end-hidden-code
//#-editable-code
scene.backgroundImage = #imageLiteral(resourceName: "labBackground")
playMusic(.lab)

//#-localizable-zone(main03k1)
// Call your functions.
//#-end-localizable-zone


//#-end-editable-code
//#-hidden-code
let manager = AssessmentManager()
manager.runAssessmentPage03(scene: scene)
//#-end-hidden-code
