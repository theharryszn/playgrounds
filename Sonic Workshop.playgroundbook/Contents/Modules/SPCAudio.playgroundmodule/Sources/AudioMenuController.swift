//
//  AudioMenuController.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit

public protocol AudioMenuDelegate: class {
    func enableBackgroundAudio(_ isEnabled: Bool)
    func enableSoundEffectsAudio(_ isEnabled: Bool)
}

public class AudioMenuController: UITableViewController {
    
    static let cellIdentifier = "SwitchTableViewCell"
    static let contentSizeKeyPath = "contentSize"
    
    enum CellIndex: Int {
        case backgroundAudio
        case soundEffectsAudio
    }
    
    static let minimumWidth: CGFloat = 200.0
    
    // MARK: Properties
    
    public weak var delegate: AudioMenuDelegate?
    public var backgroundAudioEnabled = PersistentStore.isBackgroundAudioEnabled
    public var soundEffectsAudioEnabled = PersistentStore.isSoundEffectsEnabled
    
    // MARK: View Controller Life-Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Fixes table view alignment in popover.
        // rdar://problem/53461836
        tableView.alwaysBounceVertical = false
        tableView.alwaysBounceHorizontal = false
        
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AudioMenuController.cellIdentifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // Observe changes to the table view’s content size.
        tableView.addObserver(self, forKeyPath: AudioMenuController.contentSizeKeyPath, options: .new, context: nil)
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: AudioMenuController.contentSizeKeyPath)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == AudioMenuController.contentSizeKeyPath else { return }
        // Recompute preferredContentSize each time the table view’s content size changes.
        preferredContentSize = getPreferredContentSize()
    }
    
    private func getPreferredContentSize() -> CGSize {
        let rowCount = tableView.numberOfRows(inSection: 0)
        guard rowCount > 0 else { return super.preferredContentSize }
        let padding = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).size.height // One row height
        var preferredSize = CGSize(width: AudioMenuController.minimumWidth, height: 0.0)
        // Width is determined by the widest cell. Computed manually for a more compact width.
        for row in 0..<rowCount {
            let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0))
            guard let label = cell.textLabel, let accessoryView = cell.accessoryView else { continue }
            label.sizeToFit()
            let cellWidth = label.frame.width + accessoryView.frame.width + padding
            preferredSize.width = max(cellWidth, preferredSize.width)
        }
        // Height is available from the table view’s content size.
        preferredSize.height = tableView.contentSize.height
        return preferredSize
    }
    
    // MARK: UITableViewDataSource
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = CellIndex(rawValue: indexPath.row) else {
            fatalError("Invalid index \(indexPath.row) in \(self)")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioMenuController.cellIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        
        let switchControl = UISwitch()
        cell.accessoryView = switchControl
        
        switch index {
        case .backgroundAudio:
            cell.textLabel?.text = NSLocalizedString("Background music", tableName: "SPCAudio", comment: "Menu label")
            switchControl.isOn = backgroundAudioEnabled
            
            switchControl.addTarget(self, action: #selector(toggleBackgroundAudio(_:)), for: .valueChanged)
            
        case .soundEffectsAudio:
            cell.textLabel?.text = NSLocalizedString("Sound effects", tableName: "SPCAudio", comment: "Menu label")
            switchControl.isOn = soundEffectsAudioEnabled
            
            switchControl.addTarget(self, action: #selector(toggleSoundEffectsAudio), for: .valueChanged)
        }
        
        return cell
    }
    
    // MARK: Switch Actions
    
    @objc func toggleBackgroundAudio(_ control: UISwitch) {
        delegate?.enableBackgroundAudio(control.isOn)
    }
    
    @objc func toggleSoundEffectsAudio(_ control: UISwitch) {
        delegate?.enableSoundEffectsAudio(control.isOn)
    }
}
