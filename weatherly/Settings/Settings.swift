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
    
    @State private var lang = "English"
    
    @State private var options = [ "English", "German" ]
    
    @State private var showDeleteUserAlert = false
    @State private var showReauthentication = false
    @State private var reauthenticationSuccessful = false
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    Picker(selection: $lang, content: {
                        ForEach(options, id: \.self) {
                            Text("\($0)")
                        }
                    }, label: {
                        Text("Language")
                    })
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
                        Text("Sign out")
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        deleteUserFlow()
                    } label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showDeleteUserAlert) {
                Alert(title: Text("Are you sure?"), message: Text("Are you sure you want to delete your account? This is irreversible"), primaryButton: .destructive(Text("Yes")) {
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
