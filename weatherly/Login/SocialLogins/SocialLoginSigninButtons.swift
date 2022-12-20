//
//  SocialLoginSigninButtons.swift
//  weatherly
//
//  Created by David Neidhart on 29.11.22.
//

import SwiftUI

struct SocialLoginSigninButtons: View {
    
    @State var useGoogleSignIn: () -> Void
    
    var body: some View {
        SocialLoginButton(image: "google_logo", text: "Sign in with google")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                useGoogleSignIn()
            }
    }
}

