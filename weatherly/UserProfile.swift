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
    
    @State private var showSettings = false
    
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
                            
                            /*HStack {
                             DatePicker(selection: $birthdate, displayedComponents: .date) {
                             Text("Birthday")
                             }
                             }*/
                            
                            HStack {
                                Text("E-Mail")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("E-Mail", text: $email)
                                    .disabled(!showEdit)
                                if Auth.auth().currentUser?.isEmailVerified == false && email != "N/A" {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                }
                            }
                            .onTapGesture {
                                showEmailUnverifiedAlert = Auth.auth().currentUser?.isEmailVerified == false && email != "N/A"
                            }
                            .alert(LocalizedStringKey("not-verified-email"), isPresented: $showEmailUnverifiedAlert) {
                                Button(role: .cancel) {
                                    
                                } label: {
                                    Text("Ok")
                                }
                                
                                Button {
                                    Auth.auth().currentUser?.sendEmailVerification()
                                    showEmailUnverifiedAlert = false
                                } label: {
                                    Text("verify-now")
                                }
                            }
                            
                            Menu {
                                Button {
                                    UIPasteboard.general.setValue(user!.uid,
                                                                  forPasteboardType: UTType.plainText.identifier)
                                } label: {
                                    Text("copy")
                                }
                            } label: {
                                HStack {
                                    Text("user-id")
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
                                    Text("change-password")
                                }
                                .sheet(isPresented: $showPassword) {
                                    
                                    VStack {
                                        
                                        Form {
                                            Section {
                                                HStack {
                                                    SecureField("old-password", text: $oldPassword)
                                                }
                                            }
                                            
                                            Section {
                                                HStack {
                                                    SecureField("new-password", text: $newPasword)
                                                }
                                                HStack {
                                                    SecureField("repeat-new-password", text: $newPasswordVerification)
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
                                                    Text("save")
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
                                showSettings = true
                            } label: {
                                Text("settings")
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
                            Text(showEdit ? "save" : "edit")
                        }
                    }
                    
                    if showEdit {
                        
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                
                                if user == nil {
                                    showEdit = false
                                    return
                                }
                                
                                displayName = user!.realName
                                email = user!.email
                                showEdit = false
                            } label: {
                                Text("cancel")
                            }
                        }
                        
                    }
                }
                .sheet(isPresented: $showSettings) {
                    Settings()
                }
            }
            .navigationTitle("profile")
        }
        .onAppear {
            if let currentUser = Auth.auth().currentUser {
                Session.shared.user = User(uid: currentUser.uid, email: currentUser.email ?? "N/A", username: currentUser.displayName ?? "N/A", realName: currentUser.displayName ?? "N/A")
                user = Session.shared.user
                
                self.email = user!.email
                self.displayName = user!.realName
                
                Functions.functions(region: "europe-west3")
                    .httpsCallable("getUser")
                    .call { (result, error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        if let data = result?.data as? [String: Any] {
                            print(data)
                        }
                        
                    }
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
