//
//  FinderSync.swift
//  Fichiers_caches_Finder_ext
//
//  Created by Bruno Boissonnet on 09/04/2019.
//  Copyright © 2019 BInfoService. All rights reserved.
//

import Cocoa
import FinderSync
import CoreFoundation // Process

class FinderSync: FIFinderSync {

    var myFolderURL = URL(fileURLWithPath: "/Users/Shared/MySyncExtension Documents")
    
    override init() {
        super.init()
        
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [self.myFolderURL]
        
        // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImageNameColorPanel)!, label: "Status One" , forBadgeIdentifier: "One")
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImageNameCaution)!, label: "Status Two", forBadgeIdentifier: "Two")
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
        return "Fichiers cachés"
    }
    
    override var toolbarItemToolTip: String {
        return "Fichiers cachés: Affichez ou cachez les fichiers cachés."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: NSImageNameRevealFreestandingTemplate)! //NSImageNameCaution
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Afficher/Cacher les fichiers cachés", action: #selector(sampleAction(_:)), keyEquivalent: "")
        return menu
    }
    
    @IBAction func sampleAction(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()
        
        let item = sender as! NSMenuItem
        NSLog("sampleAction: menu item: %@, target = %@, items = ", item.title as NSString, target!.path as NSString)
        for obj in items! {
            NSLog("    %@", obj.path as NSString)
        }
        let username = NSUserName()
        print("Nom de l'utilisateur \(username)")
        
        run(fileName: "Affiche_Cache_les_fichiers_caches")
        
        //print(litFichiersCaches())
    }
    
    // ATTENTION !
    // En tant qu'utilisateur, dans le terminal, on tape : /usr/bin/defaults read com.apple.finder AppleShowAllFiles
    // Mais nous ne sommes pas dans le contexte utilisateur; donc il faut :
    // 1. Récupérer le nom de l'utilisateur en cours
    // 2. Indiquer le chemin absolu du fichier à lire (ou écrire)
    // defaults read /Users/bruno/Library/Preferences/com.apple.finder.plist AppleShowAllFiles
    // defaults write /Users/bruno/Library/Preferences/com.apple.finder.plist AppleShowAllFiles TRUE
    
    func litFichiersCaches() -> String {
        
        // let cheminAbsoluPreferencesFinder = "/Users/" + NSUserName() + "/Library/Preferences/com.apple.finder.plist"
        let cheminAbsoluPreferencesFinder = "/Users/" + NSUserName() + "/Library/Containers/fr.binfoservice.Fichiers-caches.Fichiers-caches-Finder-ext/Data/Library/Preferences/com.apple.finder.plist"
        // /Users/bruno/Library/Containers/fr.binfoservice.Fichiers-caches.Fichiers-caches-Finder-ext/Data/Library/Preferences
        
        let task            = Process()
        task.launchPath     = "/usr/bin/defaults" //"/usr/bin/defaults read com.apple.finder AppleShowAllFiles"
        task.arguments      = ["read", cheminAbsoluPreferencesFinder, "AppleShowAllFiles"]
        // On veut récupérer la sortie standard et la sortie erreur
        let outputPipe      = Pipe()
        let errorPipe       = Pipe()
        task.standardOutput = outputPipe
        task.standardError  = errorPipe
        // Démarrage de la tâche
        task.launch()
        // Récupération de la sortie standard et de la sortie erreur
        let outputData      = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData       = errorPipe.fileHandleForReading.readDataToEndOfFile()
        // On transforme l'objet data en String
        if let output = String(data: outputData, encoding: String.Encoding.utf8) {
            if (output != "") {
                // Suppression du caractère "\n" situé à la fin de output
                return output.substring(to: output.index(before: output.endIndex)) // Swift 4.0 : output.remove(at: output.index(before: output.endIndex))
            }
            
        }
        if let erreur = String(data: errorData, encoding: String.Encoding.utf8) {
            if (erreur != "") {
                // Suppression du caractère "\n" situé à la fin de output
                return erreur // erreur.substring(to: output.index(before: output.endIndex)) // Swift 4.0 : output.remove(at: output.index(before: output.endIndex))
            }
            
        }
        return ""
    }
    
    // MARK: - Script
    func run(fileName: String) {
        guard let targetedUrl = FIFinderSyncController.default().targetedURL() else {
            return
        }
        
        let worker = ExtensionWorker(path: targetedUrl.path, fileName: fileName)
        worker.run()
    }

    
    /*
    func afficheCacheLesFichiersCaches() {
        
        
            
            if output == "FALSE" {
                // print("Output = FALSE")
                task.terminate()
                let task1 = Process()
                task1.launchPath     = "/usr/bin/defaults"
                task1.arguments      = ["write", "com.apple.finder", "AppleShowAllFiles", "TRUE"]
                let outputPipe      = Pipe()
                let errorPipe       = Pipe()
                task1.standardOutput = outputPipe
                task1.standardError  = errorPipe
                try task1.launch()
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData  = errorPipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: String.Encoding.utf8) {
                    print(output)
                }
                
            }
            else {
                print("Output = TRUE")
                task.terminate()
                let task1 = Process()
                task1.launchPath     = "/usr/bin/defaults"
                task1.arguments      = ["write", "com.apple.finder", "AppleShowAllFiles", "FALSE"]
                let outputPipe      = Pipe()
                let errorPipe       = Pipe()
                task1.standardOutput = outputPipe
                task1.standardError  = errorPipe
                try task1.launch()
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData  = errorPipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: String.Encoding.utf8) {
                    print(output)
                }
            }
        }
        
        let task2 = Process()
        task2.launchPath     = "/usr/bin/killall"
        task2.arguments      = ["-KILL", "Finder"]
        //        let outputPipe      = Pipe()
        //        let errorPipe       = Pipe()
        //        task2.standardOutput = outputPipe
        //        task2.standardError  = errorPipe
        try task2.launch()
        //        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        //        let errorData  = errorPipe.fileHandleForReading.readDataToEndOfFile()
        //        if let output = String(data: outputData, encoding: String.Encoding.utf8) {
        //            print(output)
        //        }
        
        
        // let error = String(decoding: errorData, as: UTF8.self)
        // let error = String(describing: errorData)
        // let error = NSString(bytes: errorData, length: errorData.count, encoding: NSUTF8StringEncoding)
        
        if let error = String(data: errorData, encoding: String.Encoding.utf8) {
            print(error)
            
        }

    }*/
    
}

