//
//  FinderSync.swift
//  FinderExtension
//
//  Created by Luo Sheng on 2023/11/16.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    override init() {
        
        super.init()
        
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }
    
    // MARK: - Primary Finder Sync protocol methods
    
    override func beginObservingDirectory(at url: URL) {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
        NSLog("beginObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    
    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
        NSLog("endObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    override func requestBadgeIdentifier(for url: URL) {
        NSLog("requestBadgeIdentifierForURL: %@", url.path as NSString)
        
        // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
        let whichBadge = abs(url.path.hash) % 3
        let badgeIdentifier = ["", "One", "Two"][whichBadge]
        FIFinderSyncController.default().setBadgeIdentifier(badgeIdentifier, for: url)
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "FinderSy"
    }
    
    override var toolbarItemToolTip: String {
        return "FinderSy: Click the toolbar item for a menu."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: NSImage.cautionName)!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        switch menuKind {
        case .contextualMenuForContainer,
                .contextualMenuForItems:
            return createMenu()
        default:
            return NSMenu(title: "")
        }
    }
    
    private func createMenu() -> NSMenu {
        let submenu = NSMenu(title: "")
        submenu.addItem(withTitle: "重启输入法", action: #selector(restartSCIM(_:)), keyEquivalent: "")
        
        let menu = NSMenu(title: "")
        let menuItem = menu.addItem(withTitle: "重启试试", action: nil, keyEquivalent: "")
        menuItem.submenu = submenu
        return menu
    }
    
    @IBAction func restartSCIM(_ sender: AnyObject?) {
        guard let path = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        let scriptURL = path.appending(component: "kill-scim.scpt")
        guard FileManager.default.fileExists(atPath: scriptURL.path(percentEncoded: false)) else {
            return
        }
        guard let script = try? NSUserAppleScriptTask(url: scriptURL) else {
            return
        }
        script.execute { error in
            if let error {
                print("\(error)")
            }
        }
    }

}

