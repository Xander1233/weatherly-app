//
//  LoginFields.swift
//  weatherly
//
//  Created by David Neidhart on 15.10.22.
//

import SwiftUI

struct LoginFields: View {
    
    var email: Binding<String>
    var password: Binding<String>
    
    var body: some View {
        VStack {
            TextField("E-Mail", text: email)
                .padding()
                .background(.thickMaterial)
                .cornerRadius(5.0)
                .padding([ .horizontal, .bottom ], 20)
            SecureField("Password", text: password)
                .padding()
                .background(.thickMaterial)
                .cornerRadius(5.0)
                .padding([ .horizontal ], 20)
        }
    }
    
}
