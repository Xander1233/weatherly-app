//
//  SocialLoginSigninButtons.swift
//  weatherly
//
//  Created by David Neidhart on 29.11.22.
//

import SwiftUI

struct SocialLoginSigninButtons: View {
    
    @State var useGoogleSignIn: () -> Void
    
    @State var useAppleSignIn: () -> Void
    
    var body: some View {
        SocialLoginButton(image: "google_logo", text: "Sign in with google")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                useGoogleSignIn()
            }
        
        SocialLoginButton(image: "", text: "Sign in with apple")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                useAppleSignIn()
            }
    }
}

