//
//  AppDelegate.swift
//  Fichiers_caches
//
//  Created by Bruno Boissonnet on 09/04/2019.
//  Copyright © 2019 BInfoService. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print(litFichiersCaches())
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
        //let cheminAbsoluPreferencesFinder = "/Users/" + NSUserName() + "/Library/Containers/fr.binfoservice.Fichiers-caches.Fichiers-caches-Finder-ext/Data/Library/Preferences/com.apple.finder.plist"
        // /Users/bruno/Library/Containers/fr.binfoservice.Fichiers-caches.Fichiers-caches-Finder-ext/Data/Library/Preferences
        
        let task            = Process()
        task.launchPath     = "/usr/bin/defaults" //"/usr/bin/defaults read com.apple.finder AppleShowAllFiles"
        task.arguments      = ["read", "com.apple.finder", "AppleShowAllFiles"]
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

    
    
    
    
}

