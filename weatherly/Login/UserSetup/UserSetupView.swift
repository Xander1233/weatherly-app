//
//  UserSetupView.swift
//  weatherly
//
//  Created by David Neidhart on 16.10.22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions
import GoogleSignIn

struct UserSetupView: View {
    
    @Binding var showUserSetup: Bool
    @State var displayName: String = ""
    @State var birthday: Date = Date()
    
    var body: some View {
        
        NavigationView {
            VStack {
                Text("What is your name?")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                
                TextField("Your name", text: $displayName)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal, .bottom ], 20)
                
                NavigationLink{
                    BirthdaySetup(displayName: displayName, showUserSetup: $showUserSetup)
                } label: {
                    HStack {
                        Text("Next")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(5.0)
                    .padding(.all, 20)
                }
            }
            .navigationTitle("Account Setup")
        }
        
    }
}

struct BirthdaySetup: View {
    
    @State var birthdate: Date = Date()
    
    @State var displayName: String
    
    @Binding var showUserSetup: Bool
    @State var showtooYoungAlert = false
    
    var body: some View {
        VStack {
            Text("When is your birthday?")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
                .padding(.top, 20)
            
            DatePicker(selection: $birthdate, displayedComponents: .date) {
                Text("Your birthday")
            }
            .padding()
            .background(.thickMaterial)
            .cornerRadius(5.0)
            .padding([ .horizontal, .bottom ], 20)
            
            Button {
                let profileChangeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                
                profileChangeReq?.displayName = displayName
                profileChangeReq?.commitChanges { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                        Functions.functions(region: "europe-west3")
                            .httpsCallable("setUser")
                            .call([ "birthdate": birthdate.timeIntervalSince1970 ]) { (res, error) in
                                
                                if let error = error, error.localizedDescription == "Too young." {
                                    showtooYoungAlert = true
                                } else {
                                    showUserSetup = false
                                }
                                
                            }
                        
                    }
                }
            } label: {
                HStack {
                    Text("Save")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(5.0)
                .padding(.all, 20)
            }
        }
        .alert(isPresented: $showtooYoungAlert) {
            Alert(title: Text("You are too young!"), message: Text("You must be at least 13 years old to use the app"), dismissButton: .cancel(Text("Ok")) {
                showUserSetup = false
                
                Auth.auth().currentUser!.delete { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                }
            })
        }
    }
}
