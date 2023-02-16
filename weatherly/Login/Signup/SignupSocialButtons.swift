//
//  SignupSocialButtons.swift
//  weatherly
//
//  Created by David Neidhart on 12.11.22.
//

import SwiftUI

struct SignupSocialButtons: View {
    
    @State var googleSignup: () -> Void
    
    var body: some View {
        SocialLoginButton(image: "google_logo", text: "sign-in-with-google")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                googleSignup()
            }
    }
}
