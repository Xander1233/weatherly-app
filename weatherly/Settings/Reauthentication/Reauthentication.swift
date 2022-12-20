//
//  Reauthentication.swift
//  weatherly
//
//  Created by David Neidhart on 30.11.22.
//

import SwiftUI

struct Reauthentication: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Binding var reauthenticationBinding: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Text("You have to reauthenticate in order to complete this action, due to it being a security-sensitive action.")
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal, .bottom ], 20)
                SecureField("Password", text: $password)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal ], 20)
                
            }
            
        }
        
    }
}
