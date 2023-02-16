//
//  SignupFields.swift
//  weatherly
//
//  Created by David Neidhart on 12.11.22.
//

import SwiftUI

struct SignupFields: View {
    
    @Binding var email: String
    @Binding var password: String
    @Binding var repeatedPassword: String
    
    var body: some View {
        TextField("E-Mail", text: $email)
            .padding()
            .background(.thickMaterial)
            .cornerRadius(5.0)
            .padding([ .horizontal, .bottom ], 20)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
        SecureField(LocalizedStringKey("password"), text: $password)
            .padding()
            .background(.thickMaterial)
            .cornerRadius(5.0)
            .padding([ .horizontal ], 20)
            .textContentType(.newPassword)
        SecureField(LocalizedStringKey("repeat-password"), text: $repeatedPassword)
            .padding()
            .background(.thickMaterial)
            .cornerRadius(5.0)
            .padding([ .horizontal ], 20)
            .textContentType(.newPassword)
    }
}
