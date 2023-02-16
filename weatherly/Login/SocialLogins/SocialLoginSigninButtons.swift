//
//  SocialLoginSigninButtons.swift
//  weatherly
//
//  Created by David Neidhart on 29.11.22.
//

import SwiftUI
import Foundation
import AuthenticationServices

struct SocialLoginSigninButtons: View {
    
    @State var useGoogleSignIn: () -> Void
    
    @State var useAppleSignIn: () -> Void
    
    @State var performExistingAccountFlow: () -> Void
    
    var body: some View {
        SocialLoginButton(image: "google_logo", text: "sign-in-with-google")
            .background(.ultraThickMaterial)
            .padding(.horizontal)
            .onTapGesture {
                useGoogleSignIn()
            }
        
        QuickSignInWithApple()
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.horizontal)
            .onTapGesture {
                useAppleSignIn()
            }
            .onAppear {
                performExistingAccountFlow()
            }
    }
}
