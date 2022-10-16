//
//  UserProfile.swift
//  weatherly
//
//  Created by David Neidhart on 08.10.22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions
import UniformTypeIdentifiers
import GoogleSignIn

struct UserProfile: View {
    
    @State private var user: User?
    
    @State private var showEmailUnverifiedAlert = false
    
    @State private var showEdit = false
    @State private var showPassword = false
    
    @State private var oldPassword = ""
    @State private var newPasword = ""
    @State private var newPasswordVerification = ""
    
    @State private var displayName: String = ""
    @State private var email: String = ""
    
    @State private var showProgressViewPassword = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                
                Form {
                    if user == nil {
                        ProgressView()
                    } else {
                        Section {
                            HStack {
                                Text("Name")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("Name", text: $displayName)
                                    .disabled(!showEdit)
                            }
                            
                            HStack {
                                Text("E-Mail")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("E-Mail", text: $email)
                                    .disabled(!showEdit)
                                if Auth.auth().currentUser?.isEmailVerified == false {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                }
                            }
                            .onTapGesture {
                                showEmailUnverifiedAlert = Auth.auth().currentUser?.isEmailVerified == false
                            }
                            .alert("This E-Mail is not verified", isPresented: $showEmailUnverifiedAlert) {
                                Button(role: .cancel) {
                                    
                                } label: {
                                    Text("Ok")
                                }
                                
                                Button {
                                    Auth.auth().currentUser?.sendEmailVerification()
                                    showEmailUnverifiedAlert = false
                                } label: {
                                    Text("Send link")
                                }
                            }
                            
                            Menu {
                                Button {
                                    UIPasteboard.general.setValue(user!.uid,
                                                                  forPasteboardType: UTType.plainText.identifier)
                                } label: {
                                    Text("Copy")
                                }
                            } label: {
                                HStack {
                                    Text("User-ID")
                                        .font(.callout)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(user!.uid.prefix(15) + "...")
                                }
                            }
                            .menuStyle(.borderlessButton)
                        }
                        
                        if showEdit {
                            Section {
                                Button {
                                    showPassword = true
                                } label: {
                                    Text("Change password")
                                }
                                .sheet(isPresented: $showPassword) {
                                    
                                    VStack {
                                        
                                        Form {
                                            Section {
                                                HStack {
                                                    SecureField("Old password", text: $oldPassword)
                                                }
                                            }
                                            
                                            Section {
                                                HStack {
                                                    SecureField("New password", text: $newPasword)
                                                }
                                                HStack {
                                                    SecureField("Repeat new password", text: $newPasswordVerification)
                                                }
                                            }
                                            
                                            Section {
                                                Button {
                                                    
                                                    showProgressViewPassword = true
                                                    
                                                    if Auth.auth().currentUser == nil {
                                                        showProgressViewPassword = false
                                                        showPassword = false
                                                        showEdit = false
                                                        return
                                                    }
                                                    
                                                    Auth.auth().currentUser!.reauthenticate(with: EmailAuthProvider.credential(withEmail: email, password: oldPassword)) { (result, error) in
                                                        
                                                        if let error = error {
                                                            print(error.localizedDescription)
                                                            
                                                            return
                                                        }
                                                        
                                                        Auth.auth().currentUser!.updatePassword(to: newPasword) { (error) in
                                                            if let error = error {
                                                                print(error.localizedDescription)
                                                                return
                                                            }
                                                            showProgressViewPassword = false
                                                            showPassword = false
                                                        }
                                                    }
                            
                                                    
                                                } label: {
                                                    if showProgressViewPassword {
                                                        ProgressView()
                                                    }
                                                    Text("Save")
                                                }
                                                .disabled(oldPassword.isEmpty || newPasword.isEmpty || newPasswordVerification.isEmpty || newPasword != newPasswordVerification)
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                            .animation(Animation.easeInOut(duration: 0.2), value: showEdit)
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
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            
                            if Auth.auth().currentUser == nil {
                                showEdit = false
                                return
                            }
                            
                            if showEdit {
                                
                                let request = Auth.auth().currentUser!.createProfileChangeRequest()
                                
                                request.displayName = displayName
                                
                                request.commitChanges()
                                
                                if email != user?.email {
                                    Auth.auth().currentUser!.updateEmail(to: email)
                                }
                                
                                Session.shared.user = User(uid: user!.uid, email: email, username: displayName, realName: displayName)
                                user = Session.shared.user
                            }
                            
                            showEdit = !showEdit
                        } label: {
                            Text(showEdit ? "Save" : "Edit")
                                .animation(.easeInOut(duration: 0.2))
                        }
                    }
                }

            }
            .navigationTitle("Profile")
        }
        .onAppear {
            if let currentUser = Auth.auth().currentUser {
                Session.shared.user = User(uid: currentUser.uid, email: currentUser.email ?? "N/A", username: currentUser.displayName ?? "N/A", realName: currentUser.displayName ?? "N/A")
                user = Session.shared.user
                
                self.email = user!.email
                self.displayName = user!.realName
            }
        }
    }
}

struct User {
    var uid: String
    var email: String
    var username: String
    var realName: String
}