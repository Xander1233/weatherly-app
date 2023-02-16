//
//  Settings.swift
//  weatherly
//
//  Created by David Neidhart on 29.11.22.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct Settings: View {
    
    @State private var showDeleteUserAlert = false
    @State private var showReauthentication = false
    @State private var reauthenticationSuccessful = false
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    } label: {
                        Text("change-language")
                    }
                }
                
                Section {
                    Button {
                        do {
                            if Auth.auth().currentUser == nil {
                                return
                            }
                            
                            if let _ = GIDSignIn.sharedInstance.currentUser {
                                GIDSignIn.sharedInstance.signOut()
                            }
                            
                            try Auth.auth().signOut()
                        } catch {
                            print(error.localizedDescription)
                        }
                    } label: {
                        Text("sign-out")
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        deleteUserFlow()
                    } label: {
                        Text("delete-account")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showDeleteUserAlert) {
                Alert(title: Text("are-you-sure"), message: Text("are-you-sure-delete-long"), primaryButton: .destructive(Text("yes")) {
                    print("deletion...")
                    
                    Auth.auth().currentUser!.delete { (error) in
                        if let error = error {
                            
                            print(error._code)
                            print(error.localizedDescription)
                            
                        }
                    }
                }, secondaryButton: .cancel({}))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func deleteUserFlow() {
        showDeleteUserAlert = true
    }
}
