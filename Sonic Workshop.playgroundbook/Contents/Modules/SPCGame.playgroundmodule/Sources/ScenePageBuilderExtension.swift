//
//  ScenePageBuilderExtension.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC
import SPCAccessibility
import SPCAudio
import SPCScene

public extension Scene {

    struct Display {
        public static let title = "display.title"
        public static let play = "display.play"
    }

    func createBackgroundUI(background1: Color, background1Gradient: Color, background2: Color, background2Gradient: Color, dots: Color, displayGraphic: Image, displayGraphicName: String, dotHeight: Double = -100) {
        let titleBackground1 = Graphic(shape: .rectangle(width: 800, height: 863,  cornerRadius: 0), color: background1, gradientColor: background1Gradient, name: Display.title)
        titleBackground1.alpha = 0.95
        let titleBackground2 = Graphic(shape: .rectangle(width: 800, height: 863,  cornerRadius: 0), color: background2, gradientColor: background2Gradient, name: Display.title)
        titleBackground2.alpha = 0.6
        titleBackground2.rotation = 2
        
        self.place(titleBackground2, at: Point(x: 0, y: 0))
        self.place(titleBackground1, at: Point(x: 0, y: 0))
        
        let displayGraphic = Sprite(image: displayGraphic, name: Display.title)
        displayGraphic.scale = 1
        displayGraphic.isDynamic = false
        self.place(displayGraphic, at: Point(x: 0, y: 300))
        displayGraphic.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: displayGraphicName)
        
        var dotPlacement: Point = Point(x: -250.0, y: dotHeight)
        for _ in 1...11 {
            let dot = Graphic(shape: Shape.circle(radius: 4), color: dots, name: Display.title)
            dot.alpha = 0.6
            self.place(dot, at: dotPlacement)
            dotPlacement.x += 50
        }
    }
    
    @discardableResult func createStartButton() -> Button {
        let startButton = Button(type: .red, text: NSLocalizedString("PLAY", tableName: "SPCGame", comment: "Play game button"), name: Display.play)
        startButton.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true)
        startButton.textColor = .white
        startButton.font = .SystemFontBold
        startButton.fontSize = 28
        startButton.disablesOnDisconnect = true
        
        return startButton
    }
    
    @discardableResult func createPracticeButton(handler: @escaping () -> Void) -> Button {
        let practiceButton: Button = Button(type: .red, text: NSLocalizedString("PRACTICE", tableName: "SPCGame", comment: "Practice game button"), name: Display.title)
        practiceButton.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true)
        practiceButton.textColor = .white
        practiceButton.font = .SystemFontBold
        practiceButton.fontSize = 32
        practiceButton.setOnPressHandler(handler)
        practiceButton.disablesOnDisconnect = true
        self.place(practiceButton, at: Point(x: 150, y: -300))
        return practiceButton
    }
    
    @discardableResult func createPlayButton(text: String, handler: @escaping () -> Void) -> Button {
        let playButton: Button = Button(type: .red, text: NSLocalizedString("\(text)", tableName: "SPCGame", comment: "Ready to play game button"), name: Display.title)
        playButton.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true)
        playButton.textColor = .white
        playButton.font = .SystemFontBold
        playButton.fontSize = 32
        playButton.setOnPressHandler(handler)
        playButton.disablesOnDisconnect = true
        self.place(playButton, at: Point(x: -150, y: -300))
        return playButton
    }
    
    func createTitleText(title: String, description: String) {
        let title: Label = Label(text: title, color: .white, font: Font.SystemBoldItalic, size: 75, name: Display.title)
        title.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true)
        let description: Label = Label(text: description, color: .white, font: Font.SystemFontRegular, size: 30, name: Display.title)
        description.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true)
        self.place(title, at: Point(x: 0, y: 75))
        self.place(description, at: Point(x: 0, y: -175))
        title.pulsate()
    }
    
    
    func removeTitleDisplay() {
        self.removeGraphics(named: Display.title)

    }

    func removePlayDisplay() {
        self.removeGraphics(named: Display.play)
    }
    
    func createDisplayLabel(backgroundColor: Color, alpha: Double, position: Point, labelTitle: String, startingText: String = "", name: String = "displayLabel", backgroundName: String = "displayLabel", labelTextColor: Color = .white) -> Label {
        let background = Graphic(shape: .rectangle(width: 200, height: 100, cornerRadius: 20), color: backgroundColor, name: backgroundName)
        background.alpha = alpha
        self.place(background, at: position)
        let label = Label(text: labelTitle, color: labelTextColor, font: Font.SystemFontHeavy, size: 20, name: backgroundName)
        self.place(label, at: Point(x: position.x, y: position.y + 30))
        let counter = Label(text: "0", color: labelTextColor, font: Font.SystemFontBold, size: 40, name: name)
        counter.accessibilityHints = AccessibilityHints(makeAccessibilityElement: true, accessibilityLabel: labelTitle, needsUpdatedValue: true)
        self.place(counter, at: Point(x: position.x, y: position.y - 10))
        return counter
    }
    
    func countDown(from value: Int = 3, completion: @escaping () -> Void) {
        let pop2 = "pop2"
        var countDownTimer = value
        var countDownTimerString = String(countDownTimer)
        let count = Label(text: countDownTimerString, color: .white, font: Font.SystemFontHeavy, size: 60, name: "count")
        place(count, at: Point(x: 0, y: 0))
        count.pulsate()
        playSound(pop2)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            countDownTimer -= 1
            if countDownTimer == 0 {
                self.remove(count)
                completion()
                timer.invalidate()
            } else {
                countDownTimerString = String(countDownTimer)
                count.text = countDownTimerString
                playSound(pop2)
            }
        })
    }
}
