//
//  UserSetupView.swift
//  weatherly
//
//  Created by David Neidhart on 16.10.22.
//

import SwiftUI
import FirebaseAuth

struct UserSetupView: View {
    
    @Binding var showUserSetup: Bool
    @State var displayName: String = ""
    
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
                
                Button {
                    
                    let profileChangeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                    
                    profileChangeReq?.displayName = displayName
                    profileChangeReq?.commitChanges { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    showUserSetup = false
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
            .navigationTitle("Account Setup")
        }
        
    }
}
