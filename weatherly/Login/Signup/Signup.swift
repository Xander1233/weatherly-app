//
//  Signup.swift
//  weatherly
//
//  Created by David Neidhart on 12.11.22.
//

import SwiftUI

struct Signup: View {
    
    @State var googleSignup: () -> Void
    
    @Binding var showMessage: Bool
    @Binding var message: String
    
    @Binding var email: String
    @Binding var password: String
    @Binding var repeatedPassword: String
    
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    @Binding var showProgressview: Bool
    
    @State var signup: () -> Void
    
    @State var viewControl: () -> Void
    
    var body: some View {
        
        LoginPageTitle(subtitle: "Sign up")
            .padding(.top, 40)
        
        if showMessage {
            HStack {
                Text(message)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        
        SignupSocialButtons(googleSignup: googleSignup)
        
        LabelledDivider(with: "or")
        
        SignupFields(email: $email, password: $password, repeatedPassword: $repeatedPassword)
        
        if showError {
            HStack {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
            }
        }
        
        LoginButton(buttonText: "Sign up", showProgressview: $showProgressview, buttonAction: signup)
        
        LoginAlternativ(text: "Already have an account?", buttonText: "Sign in", action: viewControl)
        
        Spacer()
        
    }
}
