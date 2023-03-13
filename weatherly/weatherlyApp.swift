//
//  weatherlyApp.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

@main
struct weatherlyApp: App {
    
    init() {
        FirebaseApp.configure()
        
        do {
            try Auth.auth().useUserAccessGroup("MUR6LS7BQU.tech.xndr.weatherly.authKeychain")
        } catch {
            print(error.localizedDescription)
        }
        
        IAPManager.shared.startObserving()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            IAPManager.shared.stopObserving()
        }
        
    }
    
    @State var city: City? = nil
    
    @State var showPremiumProgressView = false
    @State var showPremiumAd = false

  var body: some Scene {
    WindowGroup {
        Group {
            ContentView()
                .sheet(item: $city) { (item) in
                    NavigationView {
                        CityView(data: item)
                            .navigationTitle(item.name)
                            .toolbar {
                                ToolbarItemGroup(placement: .navigationBarLeading) {
                                    Button {
                                        city = nil
                                    } label: {
                                        Text("Close")
                                    }
                                }
                            }
                    }
                }
                .sheet(isPresented: $showPremiumAd) {
                    Text("Weatherly+")
                    
                    Text("Elevate your experience with Weatherly with the plus version.")
                    Text("Just 4.99$ per month")
                    
                    LoginButton(buttonText: "Subscribe now", showProgressview: $showPremiumProgressView) {
                        print("Buying")
                    }
                }
        }
        .onOpenURL { (url) in
            
            let cityName = url.valueOf("name")
            let cityRegion = url.valueOf("region")
            let cityCountry = url.valueOf("country")
            
            if cityName != nil && cityRegion != nil && cityCountry != nil {
                city = City(name: cityName!, country: cityCountry!, region: cityRegion!)
            }
        }
    }
  }
}

extension URL {
    func valueOf(_ keyName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first { $0.name == keyName }?.value
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
