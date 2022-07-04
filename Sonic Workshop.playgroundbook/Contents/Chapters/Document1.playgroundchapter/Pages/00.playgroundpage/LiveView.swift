//
//  LiveView.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import SonicLiveView

let liveViewController = SonicLiveViewController()

liveViewController.backgroundImage = #imageLiteral(resourceName: "caveBackground.png")

PlaygroundPage.current.liveView = liveViewController
