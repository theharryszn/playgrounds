//
//  LiveViewController.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//


import UIKit
import UIKit.UIGestureRecognizerSubclass
import PlaygroundSupport
import Foundation
import SPCCore
import SPCIPC

// Conform to this protocol to be informed of changes to the live view.
public protocol LiveViewLifeCycleProtocol {
    func liveViewMessageConnectionOpened()
    func liveViewMessageConnectionClosed()
    func liveViewDidUpdateLayout()
    func didReceiveMemoryWarning()
}

public extension LiveViewLifeCycleProtocol {
    func liveViewMessageConnectionOpened() {}
    func liveViewMessageConnectionClosed() {}
    func liveViewDidUpdateLayout() {}
    func didReceiveMemoryWarning() {}
}

public protocol BarButtonPresentationProtocol {
    var barButtonSafeAreaGuide: UILayoutGuide { get }
    var barButtonsHidden: Bool { get set }
    var barButtonLayoutDidChange: ()->() { get set }
}

public protocol InputSimulatorContext {
    func addInputSimulatorView(_ view: UIView)
}

public enum LiveViewContentPresentation {
    case constrained, aspectFitMinimum, aspectFitMaximum
}

open class LiveViewController : UIViewController, PlaygroundLiveViewSafeAreaContainer, UIGestureRecognizerDelegate {
    
    public static var current: LiveViewController?
    
    private let buttonsInset: CGFloat = 20.0
    
    let contentContainerView = LiveViewController.contentPresentation == .aspectFitMaximum ? UIView(frame: .zero) : ContentsContainerView(frame: .zero)
    let masterStackView = UIStackView(arrangedSubviews: [])
    let inputSimStackView = InputSimulatorStackView(arrangedSubviews:[])
    let barButtonStackView = UIStackView(arrangedSubviews: [])
    let inputSimButton = BarButton()
    let backgroundView = UIView(frame: .zero)
    
    public let backgroundImageView = UIImageView(image: nil)
    
    public static var contentPresentation: LiveViewContentPresentation = .constrained
    
    var topButtonBarAvoidanceConstraint: NSLayoutConstraint?
    var trailingButtonBarAvoidanceConstraint: NSLayoutConstraint?
    
    private let higherPriority: UILayoutPriority = .defaultHigh
    private let lowerPriority: UILayoutPriority = .defaultHigh - 1

    var constraintsAdded = false
    var receivedInputSimMessageTimer: Timer?
    let sensorInputUIShowing = "sensorInputUIShowing"
    
    public var barButtonSafeAreaGuide = UILayoutGuide()
    public var barButtonLayoutDidChange: ()->() = {}
    
    private var topBarButtonSafeAreaAnchor: NSLayoutConstraint? = nil
    private var rightBarButtonSafeAreaAnchnor: NSLayoutConstraint? = nil
    
    var inputSimEnabled: Bool = false {
        didSet {
            updateInputSimulatorButton()
            
            if inputSimEnabled {
                if let showingPlaygroundValue = PlaygroundKeyValueStore.current[sensorInputUIShowing] {
                    if case let .boolean(showing) = showingPlaygroundValue {
                        inputSimShowing = showing
                    }
                }
            }
        }
    }
    
    var inputSimShowing: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                if self.inputSimEnabled && self.inputSimShowing {
                    self.inputSimStackView.isHidden = false
                    self.inputSimStackView.alpha = 1.0
                } else {
                    self.inputSimStackView.alpha = 0.0
                    self.inputSimStackView.isHidden = true
                }
                
                self.masterStackView.layoutIfNeeded()
                
                self.updateInputSimulatorButton()
            }
            
            PlaygroundKeyValueStore.current[sensorInputUIShowing] = .boolean(inputSimShowing)
        }
    }
    
    public func addBarButton(_ button: BarButton) {
        if !barButtonStackView.arrangedSubviews.contains(button) {
            barButtonStackView.addArrangedSubview(button)
            
            button.presenter = self
            
            barButtonStackView.layoutIfNeeded()
            
        }
    }
    
    func _constrainCenterAndSize(parent: UIView, child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            child.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            child.widthAnchor.constraint(equalTo: parent.widthAnchor),
            child.heightAnchor.constraint(equalTo: parent.heightAnchor)
            ])
    }
    
    public var contentView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let contentView = contentView {
                contentContainerView.addSubview(contentView)
                
                _constrainCenterAndSize(parent: contentContainerView, child: contentView)
            }
        }
    }
    
    public var backgroundImage: UIImage? {
        set {
            backgroundImageView.image = newValue
            backgroundImageView.contentMode = LiveViewController.contentPresentation != .constrained ? .scaleAspectFill : .center
        }
        get {
            return backgroundImageView.image
        }
    }
    
    public var classesToRegister = [LiveViewRegistering.Type]()
    
    public var lifeCycleDelegates = [LiveViewLifeCycleProtocol]()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        Signpost.liveViewControllerInitialize.begin()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        LiveViewController.current = self
        
        Signpost.liveViewControllerInitialize.end()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("LiveViewController.init(coder:) has not been implemented")
    }
    
    // MARK: View Controller Lifecycle
    
    open override func viewDidLoad() {
        Signpost.liveViewControllerViewDidLoad.begin()
        
        for registrant in classesToRegister {
            registrant.liveViewRegistration()
        }
        
        Process.setIsLive()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        masterStackView.translatesAutoresizingMaskIntoConstraints = false
        barButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addLayoutGuide(barButtonSafeAreaGuide)
        
        topBarButtonSafeAreaAnchor = barButtonSafeAreaGuide.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor)
        rightBarButtonSafeAreaAnchnor = barButtonSafeAreaGuide.rightAnchor.constraint(equalTo: liveViewSafeAreaGuide.rightAnchor)
        
        barButtonSafeAreaGuide.leftAnchor.constraint(equalTo: liveViewSafeAreaGuide.leftAnchor).isActive = true
        barButtonSafeAreaGuide.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor).isActive = true
        
        topBarButtonSafeAreaAnchor?.isActive = true
        rightBarButtonSafeAreaAnchnor?.isActive = true
        
        view.addSubview(backgroundView)
        view.addSubview(masterStackView)
        
        let contentInset : CGFloat = 10 // The amount we’ll inset the sides length to pull it away from the edge
        
        topButtonBarAvoidanceConstraint = masterStackView.topAnchor.constraint(greaterThanOrEqualTo: barButtonSafeAreaGuide.topAnchor, constant: contentInset)
        trailingButtonBarAvoidanceConstraint = masterStackView.trailingAnchor.constraint(lessThanOrEqualTo: barButtonSafeAreaGuide.trailingAnchor, constant: -contentInset)
        
        let masterStackViewConstraints = [
            masterStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            masterStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            masterStackView.topAnchor.constraint(greaterThanOrEqualTo: liveViewSafeAreaGuide.topAnchor, constant: contentInset),
            masterStackView.leftAnchor.constraint(greaterThanOrEqualTo: liveViewSafeAreaGuide.leftAnchor, constant: contentInset),
            masterStackView.bottomAnchor.constraint(lessThanOrEqualTo: liveViewSafeAreaGuide.bottomAnchor),
            masterStackView.rightAnchor.constraint(lessThanOrEqualTo: liveViewSafeAreaGuide.rightAnchor, constant: -contentInset),
        ]
        
        // allow masterStackView centering constraints to be broken
        masterStackViewConstraints[0].priority = .defaultLow
        masterStackViewConstraints[1].priority = .defaultLow
        
        NSLayoutConstraint.activate(masterStackViewConstraints)
        
        if (LiveViewController.contentPresentation != .aspectFitMaximum) {
            masterStackView.addArrangedSubview(contentContainerView)
        }
        
        masterStackView.addArrangedSubview(inputSimStackView)
        
        inputSimStackView.isHidden = true
        inputSimStackView.alpha = 0.0
        
        if (LiveViewController.contentPresentation != .aspectFitMaximum) {
            let borderColorView = AddressableContentBorderView(frame: .zero)
            contentContainerView.addSubview(borderColorView)
            _constrainCenterAndSize(parent: contentContainerView, child: borderColorView)
        }
        
        // Create a blue background image if none exists
        if backgroundImageView.image == nil {
            let image : UIImage? = {
                UIGraphicsBeginImageContextWithOptions(CGSize(width:2500, height:2500), false, 2.0)
                #colorLiteral(red: 0.1911527216, green: 0.3274578452, blue: 0.4287572503, alpha: 1).set()
                UIRectFill(CGRect(x: 0, y: 0, width: 2500, height: 2500))
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image
            }()
            
            backgroundImageView.image = image
        }
        
        backgroundImageView.contentMode = LiveViewController.contentPresentation != .constrained ? .scaleAspectFill : .center
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(backgroundImageView)
        
        view.addSubview(barButtonStackView)
        
        _constrainCenterAndSize(parent: view, child: backgroundView)
        _constrainCenterAndSize(parent: backgroundView, child: backgroundImageView)
        
        if LiveViewController.contentPresentation == .aspectFitMaximum {
            backgroundView.addSubview(contentContainerView)
            
            let lowPriorityWidthConstraint = contentContainerView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor)
            let lowPriorityHeightConstraint = contentContainerView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor)
            
            lowPriorityWidthConstraint.priority = .defaultLow
            lowPriorityHeightConstraint.priority = .defaultLow
            
            NSLayoutConstraint.activate([
                contentContainerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                contentContainerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                contentContainerView.widthAnchor.constraint(greaterThanOrEqualTo: backgroundView.widthAnchor),
                contentContainerView.heightAnchor.constraint(greaterThanOrEqualTo: backgroundView.heightAnchor),
                lowPriorityWidthConstraint,
                lowPriorityHeightConstraint
            ])
        }
        
        updateInputSimulatorButton()
        updateStackViews()
        
        NSLayoutConstraint.activate([
            // LiveViewController explicitly expects its contents to be a square which either
            // grows or shrinks to meet the live view's inner edges with aspectFitMinimum,
            // showing all content with letterbox bars, or to the outer edges with aspectFitMaximum,
            // where some content will be visibly "clipped" by the live view.
            contentContainerView.widthAnchor.constraint(equalTo: contentContainerView.heightAnchor),
            barButtonStackView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: buttonsInset),
            barButtonStackView.trailingAnchor.constraint(equalTo: liveViewSafeAreaGuide.trailingAnchor, constant: -buttonsInset)
        ])
        
        Signpost.liveViewControllerViewDidLoad.end()
    }

    open override func viewWillAppear(_ animated: Bool) {
        Signpost.liveViewControllerViewWillAppear.event()
        
        guard constraintsAdded == false else { return }
        if let parentView = self.view.superview {
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                view.widthAnchor.constraint(equalTo: parentView.widthAnchor),
                view.heightAnchor.constraint(equalTo: parentView.heightAnchor)])
        }
        constraintsAdded = true
    }
    
    // MARK: Layout
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
        }, completion: { completed in
            self.updateStackViews()
            self.lifeCycleDelegates.forEach({ $0.liveViewDidUpdateLayout() })
        })
    }
    
    open override func viewDidLayoutSubviews() {
        updateStackViews()
        updateBarButtonSafeAreaGuide()
        lifeCycleDelegates.forEach({ $0.liveViewDidUpdateLayout() })
    }
    
    open override func didReceiveMemoryWarning() {
        for delegate in lifeCycleDelegates {
            delegate.didReceiveMemoryWarning()
        }
    }
    
    private func updateInputSimulatorButton() {
        inputSimButton.setTitle(nil, for: .normal)
        let iconImage = UIImage(named: "InputSimulatorToggle", in: Bundle(for: LiveViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        inputSimButton.accessibilityLabel = inputSimShowing ?
            NSLocalizedString("Input Simulator On", tableName: "SPCLiveView", comment: "AX hint for Input Simulator On button") :
            NSLocalizedString("Input Simulator Off", tableName: "SPCLiveView", comment: "AX hint for Input Simulator Off button")
        inputSimButton.setImage(iconImage, for: .normal)
        inputSimButton.isHidden = !inputSimEnabled
    }
    
    private func updateStackViews() {
        let horizontalLayout = liveViewSafeAreaGuide.layoutFrame.size.width > liveViewSafeAreaGuide.layoutFrame.size.height
        
        masterStackView.axis = horizontalLayout ? .horizontal : .vertical
        masterStackView.distribution = .fill
        masterStackView.alignment = .center
        masterStackView.spacing = 5.0
        
        inputSimStackView.axis = horizontalLayout ? .vertical : .horizontal
        inputSimStackView.distribution = .fill
        inputSimStackView.alignment = .center
        inputSimStackView.spacing = 10.0
        
        barButtonStackView.axis = horizontalLayout ? .vertical : .horizontal
        barButtonStackView.distribution = .equalSpacing
        barButtonStackView.alignment = .center
        barButtonStackView.spacing = 10.0
        
        let barButtonIsHorizontal = barButtonStackView.frame.size.width > barButtonStackView.frame.size.height
        
        // swap button bar order on aspect ratio change so top right most button remains static
        if barButtonIsHorizontal == horizontalLayout {
            let arrangedViews = barButtonStackView.arrangedSubviews
            
            for view in arrangedViews {
                barButtonStackView.removeArrangedSubview(view)
                barButtonStackView.insertArrangedSubview(view, at: 0)
            }
        }
        
        NSLayoutConstraint.deactivate([horizontalLayout ? topButtonBarAvoidanceConstraint! : trailingButtonBarAvoidanceConstraint!])
        NSLayoutConstraint.activate([horizontalLayout ? trailingButtonBarAvoidanceConstraint! : topButtonBarAvoidanceConstraint!])
    }
    
    static var barButtonSafeAreaGuideUpdateNotifying = false
    
    private func updateBarButtonSafeAreaGuide() {
        let barButtonsAreHorizontal = barButtonStackView.axis == .horizontal
        let kBarButtonAvoidanceOffset = CGFloat(barButtonsHidden ? 0.0 : 60.0)
        let hOffset = barButtonsAreHorizontal ? 0.0 : kBarButtonAvoidanceOffset
        let vOffset = barButtonsAreHorizontal ? kBarButtonAvoidanceOffset : 0.0
        
        topBarButtonSafeAreaAnchor?.constant = vOffset
        rightBarButtonSafeAreaAnchnor?.constant = -hOffset
        
        if !LiveViewController.barButtonSafeAreaGuideUpdateNotifying {
            LiveViewController.barButtonSafeAreaGuideUpdateNotifying = true
                        
            barButtonLayoutDidChange()
            
            LiveViewController.barButtonSafeAreaGuideUpdateNotifying = false
        }
    }
    
    private func triggerInputSimulatorTimeout() {
        receivedInputSimMessageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if self.inputSimEnabled && self.inputSimStackView.arrangedSubviews.count == 0 {
                self.inputSimEnabled = false
                self.inputSimShowing = false
            }
            
            self.receivedInputSimMessageTimer = nil
        }
    }
    
    @objc
    func didTapInputSimulatorBarButton(_ sender: Any) {
        inputSimShowing = !inputSimShowing
    }
}

public class ContentsContainerView: UIView {
    override public var intrinsicContentSize: CGSize {
        get {
            let contentEdgeLength : CGFloat = LiveViewController.contentPresentation != .constrained ? 10000 : max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.width) / 2.0
            
            return CGSize(width: contentEdgeLength, height: contentEdgeLength)
        }
    }

    override public func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        return .defaultLow
    }
}

extension LiveViewController : PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        Signpost.liveViewUserConnectionOpened.event()
        
        PBLog()
        
        triggerInputSimulatorTimeout()
        
        enableFullScreenLiveViewIfNeeded()
        
        for delegate in lifeCycleDelegates {
            delegate.liveViewMessageConnectionOpened()
        }
    }
    
    public func liveViewMessageConnectionClosed() {
        Signpost.liveViewUserConnectionClosed.event()
        
        PBLog()
        
        disableFullScreenLiveViewIfNeeded()
        
        for delegate in lifeCycleDelegates {
            delegate.liveViewMessageConnectionClosed()
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case let .array(arr) = message else { fatalError("Message must carry a payload") }
        guard case let .string(proxyName) = arr[0] else { fatalError("Message must carry the name of the associated proxy") }
        guard case let .string(payloadName) = arr[1] else { fatalError("Message must carry the name of it's payload") }
        guard case let .data(payload) = arr[2] else { fatalError("Message must carry a payload")}
        
        Message.receive(payload, payloadName: payloadName, withType: proxyName)
    }
    
    func enableFullScreenLiveViewIfNeeded() {
        if traitCollection.horizontalSizeClass == .compact {
//            PlaygroundPage.current.wantsFullScreenLiveView = true
        }
    }
    
    func disableFullScreenLiveViewIfNeeded() {
//        PlaygroundPage.current.wantsFullScreenLiveView = false
    }
    
}

extension LiveViewController: BarButtonPresentationProtocol {
    public var barButtonsHidden: Bool {
        get {
            return barButtonStackView.isHidden
        }
        set {
            barButtonStackView.isHidden = newValue
            
            updateBarButtonSafeAreaGuide()
        }
    }
}

extension LiveViewController: InputSimulatorContext {
     public func addInputSimulatorView(_ view: UIView) {
        inputSimEnabled = true

        if inputSimButton.superview == nil {
            inputSimButton.addTarget(self, action: #selector(didTapInputSimulatorBarButton(_:)), for: .touchUpInside)

            addBarButton(inputSimButton)

            updateInputSimulatorButton()
        }

        inputSimStackView.addArrangedSubview(view)

        inputSimStackView.layoutIfNeeded()
    }
}
