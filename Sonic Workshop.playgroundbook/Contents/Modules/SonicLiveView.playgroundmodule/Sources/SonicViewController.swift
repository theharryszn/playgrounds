//
//  SonicLiveViewController.swift
//
//  Copyright © 2016-2018 Apple Inc. All rights reserved.
//

import SPCCore
import SPCLiveView
import SPCScene
import SPCAudio
import SPCAccessibility
import UIKit

public class SonicLiveViewController: LiveViewController {

    public init() {
        LiveViewController.contentPresentation = .aspectFitMaximum
        
        super.init(nibName: nil, bundle: nil)

        classesToRegister = [SceneProxy.self, AudioProxy.self, AccessibilityProxy.self]

        let liveViewScene = LiveViewScene(size: Scene.sceneSize)
        
        lifeCycleDelegates = [audioController, liveViewScene]
        contentView = liveViewScene.skView
        
        let audioButton = AudioBarButton()
        audioButton.toggleBackgroundAudioOnly = false
        addBarButton(audioButton)
    }

    required init?(coder: NSCoder) {
        fatalError("SonicLiveViewController.init?(coder) not implemented.")
    }
}
