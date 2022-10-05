//
//  weatherlyApp.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseCore

@main
struct weatherlyApp: App {
    
    init() {
        FirebaseApp.configure()
    }
 

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

extension Color {
    static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
        func value(_ raw: UInt8) -> Double {
            return Double(raw)/Double(255)
        }
        return Color(
            red: value(red),
            green: value(green),
            blue: value(blue)
        )
    }
}
