//
//  AudioBarButton.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit
import SPCLiveView

public class AudioBarButton: BarButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addTarget(self, action: #selector(didTapAudioBarButton(_:)), for: .touchUpInside)
        
        updateAudioButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var toggleBackgroundAudioOnly = false
    
    @objc
    func didTapAudioBarButton(_ button: UIButton) {
        if dismissAudioMenu() {
            // Just dismissing a previously presented `AudioMenuController`.
            return
        }
        
        if toggleBackgroundAudioOnly {
            audioController.isBackgroundAudioEnabled = !audioController.isBackgroundAudioEnabled
            
            updateAudioButton()
        } else {
            let menu = AudioMenuController()
            menu.modalPresentationStyle = .popover
            
            ///menu.popoverPresentationController?.passthroughViews = [view]
            menu.popoverPresentationController?.backgroundColor = .white
            
            menu.popoverPresentationController?.permittedArrowDirections = .up
            menu.popoverPresentationController?.sourceView = button
            
            // Offset the popup arrow under the button.
            menu.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 5, width: 44, height: 44)
            
            menu.popoverPresentationController?.delegate = self
            menu.backgroundAudioEnabled = audioController.isBackgroundAudioEnabled
            menu.soundEffectsAudioEnabled = audioController.isSoundEffectsAudioEnabled
            menu.delegate = self
            
            presenter?.present(menu, animated: true, completion: nil)
        }
    }
    
    /// Dismisses the audio menu if visible. Returns true if there was a menu to dismiss
    @discardableResult
    func dismissAudioMenu() -> Bool {
        if let vc = presenter?.presentedViewController as? AudioMenuController {
            vc.dismiss(animated: true, completion: nil)
            return true
        }
        return false
    }
    
    private func updateAudioButton() {
        setTitle(nil, for: .normal)
        
        let allAudioEnabled = audioController.isAllAudioEnabled
        let iconImage = allAudioEnabled ? UIImage(named: "AudioOn", in: Bundle(for: AudioBarButton.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) : UIImage(named: "AudioOff", in: Bundle(for: AudioBarButton.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        accessibilityLabel = allAudioEnabled ?
            NSLocalizedString("Sound On", tableName: "SPCAudio", comment: "AX hint for Sound On button") :
            NSLocalizedString("Sound Off", tableName: "SPCAudio", comment: "AX hint for Sound Off button")
        
        setImage(iconImage, for: .normal)
    }
}

extension AudioBarButton: UIPopoverPresentationControllerDelegate {
    // MARK: UIPopoverPresentationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension AudioBarButton: AudioMenuDelegate {
    // MARK: AudioMenuDelegate
    public func enableSoundEffectsAudio(_ isEnabled: Bool) {
        audioController.isSoundEffectsAudioEnabled = isEnabled
        updateAudioButton()
    }
    
    public func enableBackgroundAudio(_ isEnabled: Bool) {
        audioController.isBackgroundAudioEnabled = isEnabled
        updateAudioButton()
        
        // Resume (actually restart) background audio if it had been playing.
        if isEnabled, let backgroundMusic = audioController.backgroundAudioMusic {
            audioController.playBackgroundAudioLoop(backgroundMusic)
        }
    }
}
