//
//  widgetsBundle.swift
//  widgets
//
//  Created by David Neidhart on 14.02.23.
//

import WidgetKit
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

@main
struct widgetsBundle: WidgetBundle {
    
    init() {
        FirebaseApp.configure()
        
        do {
            try Auth.auth().useUserAccessGroup("MUR6LS7BQU.tech.xndr.weatherly.authKeychain")
        } catch {
            print(error)
        }
    }
    
    var body: some Widget {
        WeatherlyWidget()
        CurrentLocationWidget()
    }
}
