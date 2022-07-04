//#-hidden-code
//
//  Cutscene.swift
//
//  Copyright © 2019 Apple Inc. All rights reserved.
//
//#-end-hidden-code

import PlaygroundSupport
import UIKit
import AVFoundation

public class CaveOutroViewController: UIViewController {
    private let cutsceneSize = CGSize(width: 1024, height: 768)
    
    var animationsHaveRun = false
    var soundsHaveBeenDucked = false
    var containerView = UIView()
    var backgroundImageView = UIImageView(image: UIImage(named: "crystalBackground"))
    var largeTitleLabel = UILabel()
    var bodyLabel1 = UILabel()
    var bodyLabel2 = UILabel()
    var crystal1ImageView = UIImageView(image: UIImage(named: "pinkCrystal"))
    var crystal2ImageView = UIImageView(image: UIImage(named: "blueCrystal"))
    var crystal3ImageView = UIImageView(image: UIImage(named: "yellowCrystal"))
    var flash1ImageView = UIImageView(image: UIImage(named: "pinkGlow"))
    var flash2ImageView = UIImageView(image: UIImage(named: "blueGlow"))
    var flash3ImageView = UIImageView(image: UIImage(named: "yellowGlow"))
    var book1Button = UIButton(type: .custom)
    var book2Button = UIButton(type: .custom)
    var book3Button = UIButton(type: .custom)
    var activeAudioPlayers = Set<AVAudioPlayer>()
    var didEnterBackgroundObserver: NSObjectProtocol?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        didEnterBackgroundObserver = NotificationCenter.default.addObserver(forName: .NSExtensionHostDidEnterBackground, object: nil, queue: .main) { [weak self] _ in
            self?.duckSounds()
        }
        
        Timer.scheduledTimer(withTimeInterval: 7.5, repeats: false) { [weak self] _ in
            self?.duckSounds()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let didEnterBackgroundObserver = didEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
        view.addSubview(containerView)
        containerView.addSubview(largeTitleLabel)
        containerView.addSubview(bodyLabel1)
        containerView.addSubview(bodyLabel2)
        containerView.addSubview(book1Button)
        containerView.addSubview(book2Button)
        containerView.addSubview(book3Button)
        containerView.addSubview(crystal3ImageView) // specific crystal additions for proper z-ordering
        containerView.addSubview(crystal1ImageView)
        containerView.addSubview(crystal2ImageView)
        containerView.addSubview(flash1ImageView)
        containerView.addSubview(flash2ImageView)
        containerView.addSubview(flash3ImageView)
        
        largeTitleLabel.text = NSLocalizedString("Congratulations!", comment: "title")
        bodyLabel1.text = NSLocalizedString("You just coded an awesome musical experience.", comment: "body 1")
        bodyLabel2.text = NSLocalizedString("Now, take your learning to the next level with one of these:", comment: "body 2")
        
        book1Button.setImage(UIImage(named: "sonicCreate"), for: .normal)
        book1Button.setTitle(NSLocalizedString("Sonic Create", comment: "book 1"), for: .normal)
        #if targetEnvironment(macCatalyst)
        book2Button.setImage(UIImage(named: "blusAdventure"), for: .normal)
        book3Button.setImage(UIImage(named: "rps"), for: .normal)
        book2Button.setTitle(NSLocalizedString("Blu's Adventure", comment: "book 2"), for: .normal)
        book3Button.setTitle(NSLocalizedString("Rock, Paper, Scissors", comment: "book 3"), for: .normal)
        #else
        book2Button.setImage(UIImage(named: "sensorArcade"), for: .normal)
        book3Button.setImage(UIImage(named: "lights, camera, code"), for: .normal)
        book2Button.setTitle(NSLocalizedString("Sensor Arcade", comment: "book 2"), for: .normal)
        book3Button.setTitle(NSLocalizedString("Lights, Camera, Code", comment: "book 3"), for: .normal)
        #endif
        

        
        containerView.frame = CGRect(x: 0, y: 0, width: cutsceneSize.width, height: cutsceneSize.height)
        largeTitleLabel.frame = CGRect(x: 10, y: 193, width: 1004, height: 104)
        bodyLabel1.frame = CGRect(x: 10, y: 281, width: 1004, height: 104)
        bodyLabel2.frame = CGRect(x: 10, y: 358, width: 1004, height: 41)
        crystal1ImageView.frame = CGRect(x: 207, y: 466, width: 116, height: 150)
        crystal2ImageView.frame = CGRect(x: 425, y: 466, width: 174, height: 150)
        crystal3ImageView.frame = CGRect(x: 711, y: 426, width: 97, height: 189)
        flash1ImageView.frame = CGRect(x: 0, y: 279, width: 530, height: 525)
        flash2ImageView.frame = CGRect(x: 247, y: 279, width: 530, height: 525)
        flash3ImageView.frame = CGRect(x: 494, y: 279, width: 530, height: 525)
        book1Button.frame = CGRect(x: 148, y: 466, width: 234, height: 350)
        book2Button.frame = CGRect(x: 395, y: 466, width: 234, height: 350)
        book3Button.frame = CGRect(x: 642, y: 466, width: 234, height: 350)

        
        adjustCutsceneLabel(largeTitleLabel, font: UIFont.boldSystemFont(ofSize: 80.0))
        adjustCutsceneLabel(bodyLabel1, font: UIFont.systemFont(ofSize: 30.0))
        adjustCutsceneLabel(bodyLabel2, font: UIFont.systemFont(ofSize: 30.0))
        
        adjustCutsceneButton(book1Button)
        adjustCutsceneButton(book2Button)
        adjustCutsceneButton(book3Button)
        
        book1Button.addTarget(self, action: #selector(self.openBook(sender:)), for: .touchUpInside)
        book2Button.addTarget(self, action: #selector(self.openBook(sender:)), for: .touchUpInside)
        book3Button.addTarget(self, action: #selector(self.openBook(sender:)), for: .touchUpInside)
        
        largeTitleLabel.isAccessibilityElement = true
        bodyLabel1.isAccessibilityElement = true
        bodyLabel2.isAccessibilityElement = true
        book1Button.isAccessibilityElement = true
        book2Button.isAccessibilityElement = true
        book3Button.isAccessibilityElement = true
        
        loadInitialValues()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let properTransform = min(1.5, min(view.bounds.width / cutsceneSize.width, view.bounds.height / cutsceneSize.height))
        containerView.transform = CGAffineTransform.identity.scaledBy(x: properTransform, y: properTransform)
        containerView.center = view.center
        backgroundImageView.frame = view.bounds
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: String(format: NSLocalizedString("See what's Next. Choose your next playground to explore.", comment: "AX description of outro")))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                UIAccessibility.post(notification: .layoutChanged, argument: self.largeTitleLabel)
            }
        }
        
        if !animationsHaveRun {
            beginAnimations()
            
            animationsHaveRun = true
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        duckSounds()
    }
    
    private func duckSounds() {
        self.activeAudioPlayers.forEach { $0.setVolume(0.0, fadeDuration: 1.0) }
        
        soundsHaveBeenDucked = true
    }
    
    private func adjustCutsceneLabel(_ label: UILabel, font: UIFont, lineCount: Int = 1) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        label.font = font
        label.numberOfLines = lineCount
        
        if lineCount != 1 {
            label.lineBreakMode = .byWordWrapping
        }
    }
    
    private func adjustCutsceneButton( _ button: UIButton) {
        if let imageView = button.imageView, let label = button.titleLabel {
            let spacing = CGFloat(24.0)
            
            adjustCutsceneLabel(label, font: UIFont.systemFont(ofSize: 25.0), lineCount: 0)
            
            button.contentVerticalAlignment = .top
            
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -label.frame.size.height - spacing, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: imageView.frame.size.height + spacing, left: -button.frame.size.width, bottom: 0, right: 0)
        }
    }
    
    private func loadInitialValues() {
        hideBooks()
        hideBookLabels()
        hideFlashes()
        hideText()
        scaleText()
        
        book1Button.isHidden = true
        book2Button.isHidden = true
        book3Button.isHidden = true
    }
    
    private func beginAnimations() {
        book1Button.isHidden = false
        book2Button.isHidden = false
        book3Button.isHidden = false
        
        playSound("cave")
        animateLargeTitle()
        animateBodyLabels()
        fadeInCoverLabels()
        fadeInAndGrowBooks()
        zoomCrystals()
        triggerFlashes()
        playSounds()
    }
    
    private func hideBooks() {
        if let imageView1 = book1Button.imageView, let imageView2 = book2Button.imageView, let imageView3 = book3Button.imageView {
            [imageView1, imageView2, imageView3].forEach {
                $0.alpha = 0
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
            }
        }
    }
    
    private func hideBookLabels() {
        if let label1 = book1Button.titleLabel, let label2 = book2Button.titleLabel, let label3 = book3Button.titleLabel {
            [label1, label2, label3].forEach {
                $0?.alpha = 0
            }
        }
    }
    
    private func hideFlashes() {
        [flash1ImageView, flash2ImageView, flash3ImageView].forEach {
            $0?.alpha = 0
        }
    }
    
    private func hideText() {
        [largeTitleLabel, bodyLabel1, bodyLabel2].forEach {
            $0?.alpha = 0
        }
    }
    
    private func scaleText() {
        largeTitleLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.4, y: 0.4)
    }
    
    private func animateLargeTitle() {
        let delay = 0.0
        
        UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseInOut, animations: {
            self.largeTitleLabel.alpha = 1
            self.largeTitleLabel.transform = .identity
        }, completion: nil)
    }
    
    private func animateBodyLabels() {
        let delay = 1.0
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseIn, animations: {
            self.bodyLabel1.alpha = 1
            self.bodyLabel2.alpha = 1
        }, completion: nil)
    }
    
    private func fadeInCoverLabels() {
        let initialDelay = 2.0
        var delay = 0.0
        let delayFactor = 0.75
        
        if let label1 = book1Button.titleLabel, let label2 = book2Button.titleLabel, let label3 = book3Button.titleLabel {
            let coverLabels = [label1, label2, label3]
            
            for label in coverLabels {
                UIView.animate(withDuration: 0.4, delay: initialDelay + delay, options: .curveEaseIn, animations: {
                    label.alpha = 1.0
                }, completion: nil)
                
                delay += delayFactor
            }
        }
     }
    
    private func fadeInAndGrowBooks() {
        let initialDelay = 2.0
        var delay = 0.0
        let delayFactor = 0.75
        
        if let imageView1 = book1Button.imageView, let imageView2 = book2Button.imageView, let imageView3 = book3Button.imageView {
            let books = [imageView1, imageView2, imageView3]
            
            for book in books {
                UIView.animate(withDuration: 0.4, delay: initialDelay + delay, options: .curveEaseIn, animations: {
                    book.alpha = 1.0
                    book.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                }, completion: nil)
                delay += delayFactor
            }
        }
    }
    
    private func zoomCrystals() {
        let initialDelay = 2.0
        var delay = 0.0
        let delayFactor = 0.75
        
        let crystals = [crystal1ImageView, crystal2ImageView, crystal3ImageView]
        let scales = [0.39, 0.51, 0.64]
        let offsets = [CGSize(width: 220, height: -390), CGSize(width: 23, height: -376), CGSize(width: -240, height: -400)]
        
        for i in 0...2 {
            UIView.animate(withDuration: 0.4, delay: initialDelay + delay, options: .curveEaseIn, animations: {
                let crystal = crystals[i]
                let scale = CGFloat(scales[i])
                let offset = offsets[i]
                let scaleTransform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
                let translateTransform = CGAffineTransform.identity.translatedBy(x: offset.width, y: offset.height)
                
                crystal.transform = scaleTransform.concatenating(translateTransform)
            }, completion: nil)
            delay += delayFactor
        }
    }
    
    private func triggerFlashes() {
        let initialDelay = 1.6
        var delay = 0.0
        let delayFactor = 0.75

        let flashes = [flash1ImageView, flash2ImageView, flash3ImageView]

        for flash in flashes {
            UIView.animate(withDuration: 0.2, delay: initialDelay + delay, options: .curveEaseIn, animations: {
                flash.alpha = 1.0
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay + delay + 0.2) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    flash.alpha = 0.0
                }, completion: nil)
            }
            
            delay += delayFactor
        }
    }
    
    private func playSounds() {
        let initialDelay = 2.0
        let delayFactor = 0.75
        let sounds = ["alienHello", "ping", "chord"]
        var count = 0
        
        let soundTimer = Timer(fire: Date() + initialDelay, interval: delayFactor, repeats: true) { timer in
            self.playSound(sounds[count])
            
            count += 1
            
            if count == 3 {
                timer.invalidate()
            }
        }
        
        RunLoop.main.add(soundTimer, forMode: .default)
    }
    
    private func playSound(_ sound: String) {
        let soundURL = Bundle.main.url(forResource: sound, withExtension: "m4a")
        
        if !soundsHaveBeenDucked, let soundURL = soundURL {
            let audioPlayer = try! AVAudioPlayer(contentsOf: soundURL)
            
            audioPlayer.volume = 0.8
            audioPlayer.play()
            
            activeAudioPlayers.insert(audioPlayer)
        }
    }
    
    @objc func openBook(sender: UIButton) {
        let contentIdentifier: String
        
        switch sender {
        case book1Button:
            contentIdentifier = "com.apple.playgrounds.soniccreate"
        case book2Button:
            #if targetEnvironment(macCatalyst)
            contentIdentifier =
            "com.apple.playgrounds.learntocode3.edition3"
            #else
            contentIdentifier = "com.apple.playgrounds.sensorarcade"
            #endif
        case book3Button:
            #if targetEnvironment(macCatalyst)
            contentIdentifier =
            "com.apple.playgrounds.rockpaperscissors.edition4"
            #else
            contentIdentifier = "com.apple.playgrounds.lightscameracode"
            #endif
        default:
            return
        }
        
        PlaygroundPage.current.openPlayground(withContentIdentifier: contentIdentifier)
    }
}

PlaygroundPage.current.liveView = CaveOutroViewController()
