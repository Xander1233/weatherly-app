//
//  AppleSignInUtils.swift
//  weatherly
//
//  Created by David Neidhart on 07.01.23.
//

import Foundation
import SwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices

// Unhashed nonce.
fileprivate var currentNonce: String?

class SignInWithApple: NSObject {
    
    private var delegate: SignInWithAppleDelegate
    
    init(delegate: SignInWithAppleDelegate) {
        self.delegate = delegate
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func useAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = provider.createRequest()
        request.requestedScopes = [ .fullName, .email ]
        request.nonce = sha256(nonce)
        
        performSignIn(using: [request])
    }
    
    func performSignIn(using requests: [ASAuthorizationRequest]) {
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = delegate
        authorizationController.performRequests()
    }
    
    func performExistingAccountSetupFlow() {
        
        #if !targetEnvironment(simulator)
        
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        performSignIn(using: requests)
        #endif
    }
}

class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate {
    
    @State var callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error occured while signing in with apple: \(error.localizedDescription)")
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Encountered an authorization error")
            return
        }
        
        guard let nonce = currentNonce else {
            fatalError(
                "Invalid state: a login callback was received, but no login request was sent."
            )
        }
        
        guard let appleIdToken = appleIdCredential.identityToken else {
            print("unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
            print("unable to serialize token string from data: \(appleIdToken.debugDescription)")
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.callback()
        }
        
        print("User correctly authorized")
        print("\(appleIdCredential.fullName?.givenName ?? "") \(appleIdCredential.fullName?.familyName ?? "") \(appleIdCredential.email ?? "")")
    }
}
