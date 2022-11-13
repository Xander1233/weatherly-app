//
//  SignupSocialButtons.swift
//  weatherly
//
//  Created by David Neidhart on 12.11.22.
//

import SwiftUI

struct SignupSocialButtons: View {
    
    @State var googleSignup: () -> Void
    @State var twitterSignup: () -> Void
    
    var body: some View {
        SocialLoginButton(image: "google_logo", text: "Sign in with google")
        .background(.ultraThickMaterial)
        .padding(.horizontal)
        .onTapGesture {
            googleSignup()
        }
        
        SocialLoginButton(image: "twitter_logo", text: "Sign in with twitter")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                twitterSignup()
            }
    }
}
