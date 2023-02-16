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
                Text("what-is-your-name")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                
                TextField("your-name", text: $displayName)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal, .bottom ], 20)
                    .textContentType(.name)
                
                NavigationLink{
                    BirthdaySetup(displayName: displayName, showUserSetup: $showUserSetup)
                } label: {
                    HStack {
                        Text("next")
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
            Text("when-is-your-birthday")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
                .padding(.top, 20)
            
            DatePicker(selection: $birthdate, displayedComponents: .date) {
                Text("your-birthday")
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
                    Text("save")
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
            Alert(title: Text("underaged"), message: Text("at-least-13"), dismissButton: .cancel(Text("Ok")) {
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
