//
//  ContentView.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

struct ContentView: View {
    
    @State var isLoggedIn = false
    
    @State var showUserSetup = false

    var body: some View {
        
        if !isLoggedIn {
            LoginScreen(isLoggedIn: $isLoggedIn, showUserSetup: $showUserSetup)
                .onAppear {
                    Auth.auth().addStateDidChangeListener() { auth, user in
                        self.isLoggedIn = user != nil
                        self.showUserSetup = user?.displayName?.isEmpty ?? false
                    }
                }
        } else {
            TabView {
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "house")
                            Text("Home")
                        }
                    }
                    .sheet(isPresented: $showUserSetup) {
                        UserSetupView(showUserSetup: $showUserSetup)
                            .interactiveDismissDisabled(true)
                    }
                
                SearchView()
                    .tabItem {
                        VStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                    }
                
                PurchaseScreen()
                    .tabItem {
                        VStack {
                            Image(systemName: "questionmark")
                            Text("Weatherly+")
                        }
                    }
                
                UserProfile()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    }
            }
        }
    }
}
