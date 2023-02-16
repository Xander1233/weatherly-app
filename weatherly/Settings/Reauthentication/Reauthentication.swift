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
                Text("have-to-reauthenticate")
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal, .bottom ], 20)
                SecureField("password", text: $password)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(5.0)
                    .padding([ .horizontal ], 20)
                
            }
            
        }
        
    }
}
