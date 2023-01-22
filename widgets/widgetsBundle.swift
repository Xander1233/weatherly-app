//
//  widgetsBundle.swift
//  widgets
//
//  Created by David Neidhart on 28.12.22.
//

import WidgetKit
import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct widgetsBundle: WidgetBundle {
    
    init() {
        FirebaseApp.configure()
        
        do {
            try Auth.auth().useUserAccessGroup("tech.xndr.weatherly.keychain")
        } catch let error as NSError {
            print("Error chaning user access group: %@", error)
        }
        
        Auth.auth().addStateDidChangeListener() { (auth, user) in
            print(#function, user ?? "No user")
        }
    }
    
    var body: some Widget {
        widgets()
        widgetsLiveActivity()
    }
}
