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
//#-code-completion(identifier, show, !, !=, (, (), (hue:saturation:brightness:alpha:), (image:), (sound:), (x:y:), ), *, +, +=, -, -=, ->, ., /, :, <, =, >, Color, Double, Graphic, Image, Instrument, Int, Kind, Loop, loopFireHandler, SonicMusic, Point, spriteA, spriteB, Point(x:y:), Scene, Shape, Size, SonicSound, Touch, _:, _:at:, _:blend:, _:note:volume:, _:volume:, addInstrument(image:color:at:), after:, alpha, append(_:), availableNotes, backgroundColor, backgroundImage, bassGuitar, bassSynth, black, blue, brown, by:duration:, cave, circle(radius:), circle(radius:color:gradientColor:), clear, crystalSynth, cyan, darkGray, duration:, electricGuitar, fadeIn(after:), fadeOut(after:), from(_:), glow(), glow(radius:period:count:), gray, green, height, hue:saturation:brightness:alpha:, image, image:, in:, init(id:graphicType:name:), init(image:name:), init(shape:color:gradientColor:name:), init(width:height:), isGridVisible, lab, length, lightGray, magenta, orange, period:count:, pi, piano, place(_:at:), playInstrument(_:note:volume:), playMusic(_:volume:), playSound(_:volume:), playing, polygon(radius:sides:), position, pulsate(period:count:), purple, radius:color:gradientColor:, radius:period:count:, radius:points:sharpness:, radius:sides:, random(in:), shape:color:, text:color:, rectangle(width:height:cornerRadius:), red, rotation, scale, scale(by:duration:), scale(to:duration:), scene, setOnTouchMovedHandler(_:), setOnTouchHandler, setTintColor(_:blend:), sevenSynth, shake(duration:), size, sound, sound:, sqrt(), star(radius:points:sharpness:), to:duration:, toggle(), turtle, underwater, volume, warmBells, white, width, width:height:cornerRadius:, x, x:y:, y, yellow, {, }, alienSirens, bells, canYouHearMe, comeHere, cowBell, creepy, creepy2, err, etherial, etherial2, flute2, foundIt, gong, gotIt, hearMeNow, highLow, highPitch, horns4, low, mission, nanana, offAndAway, piano2, playWithMe, powerUp, shakeItUp, signals, sirens, sonar4, sonarHit, spaceGuitar, steelDrums2, symbols, taps, thud, thud2, twinkles, vibrations2, weeOoo, weirdDinnerBell, weirdHits, whaleSounds, windDown, windUp2, yoga3, A1, A2, A3, A4, A5, AS1, AS2, AS3, AS4, AS5, B1, B2, B3, B4, B5,  C1, C2, C3, C4, C5, CS1, CS2, CS3, CS4, CS5, D1, D2, D3, D4, D5, DS1, DS2, DS3, DS4, DS5, E1, E2, E3, E4, E5, F1, F2, F3, F4, F5, FS1, FS2, FS3, FS4, FS5, G1, G2, G3, G4, G5, GS1, GS2, GS3, GS4, GS5, public)
import PlaygroundSupport
import UIKit

//#-end-hidden-code
//#-editable-code
scene.backgroundImage = #imageLiteral(resourceName: "underwaterBackground")
playMusic(.underwater)

//#-localizable-zone(main02k1)
// Call your functions.
//#-end-localizable-zone


//#-end-editable-code
//#-hidden-code
let manager = AssessmentManager()
manager.runAssessmentPage02(scene: scene)
//#-end-hidden-code
