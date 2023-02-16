//
//  QuickSignInWithApple.swift
//  weatherly
//
//  Created by David Neidhart on 07.02.23.
//

import SwiftUI
import UIKit
import AuthenticationServices

struct QuickSignInWithApple: UIViewRepresentable {
    
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    func makeUIView(context: Context) -> Self.UIViewType {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateUIView(_ uiView: Self.UIViewType, context: Context) {
        
    }
}
