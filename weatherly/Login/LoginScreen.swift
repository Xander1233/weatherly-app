//
//  LoginScreen.swift
//  weatherly
//
//  Created by David Neidhart on 08.10.22.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

let twitterColor = Color.rgb(29, 161, 242)

struct LoginScreen: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var repeatedPassword: String = ""
    
    @Binding var isLoggedIn: Bool
    @Binding var showUserSetup: Bool
    
    @State var viewControl: Views = .Signin
    
    @State var showError = false
    @State var errorMessage = ""
    
    @State var showMessage = false
    @State var message = ""
    
    @State private var showProgressview = false
    
    @State private var controller: SignInWithApple?
    @State private var delegate: SignInWithAppleDelegate?
    
    var body: some View {
        NavigationView {
            
            switch viewControl {
            case .Signin:
                VStack {
                    LoginPageTitle(subtitle: "sign-in")
                        .padding(.top, 40)
                    
                    if showMessage {
                        HStack {
                            Text(message)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                    }
                    
                    SocialLoginSigninButtons(useGoogleSignIn: useGoogleSignIn, useAppleSignIn: {
                        useAppleSignIn()
                    }) {
                        
                    }
                    
                    LabelledDivider(with: "or")
                    
                    if showError {
                        HStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    LoginFields(email: $email, password: $password)
                    
                    LoginButton(buttonText: "sign-in", showProgressview: $showProgressview, buttonAction: signin)
                    
                    LoginAlternativ(text: "new-to-weatherly", buttonText: "create-an-account") {
                        showError = false
                        showProgressview = false
                        showMessage = false
                        viewControl = .Signup
                    }
                    .padding(.bottom, 10)
                    
                    LoginAlternativ(text: "", buttonText: "Forgot password?") {
                        showError = false
                        showMessage = false
                        showProgressview = false
                        viewControl = .ForgotPassword
                    }
                }
                .onAppear {
                    checkGoogleSignIn()
                }
                
            case .Signup:
                VStack {
                    Signup(googleSignup: useGoogleSignIn, showMessage: $showMessage, message: $message, email: $email, password: $password, repeatedPassword: $repeatedPassword, showError: $showError, errorMessage: $errorMessage, showProgressview: $showProgressview, signup: signup, viewControl:  {
                        showError = false
                        showProgressview = false
                        showMessage = false
                        viewControl = .Signin
                    })
                }
                
            case .ForgotPassword:
                VStack {
                    LoginPageTitle(subtitle: "Forgot password")
                        .padding(.top, 40)
                    
                    if showMessage {
                        HStack {
                            Text(message)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                    }
                    
                    TextField("E-Mail", text: $email)
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(5.0)
                        .padding([ .horizontal, .bottom ], 20)
                    if showError {
                        HStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    LoginButton(buttonText: "Send reset link", showProgressview: $showProgressview, buttonAction: forgotPassword)
                    
                    LoginAlternativ(text: "", buttonText: "Return to login") {
                        showError = false
                        showMessage = false
                        showProgressview = false
                        viewControl = .Signin
                    }
                    .padding(.bottom, 10)
                    
                    LoginAlternativ(text: "", buttonText: "Create a new user") {
                        showError = false
                        showProgressview = false
                        showMessage = false
                        viewControl = .Signup
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            delegate = SignInWithAppleDelegate {
                appleSignInFinished()
            }
            controller = SignInWithApple(delegate: delegate!)
        }
    }
    
    func signin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                errorMessage = error.localizedDescription;
                showError = true
                print(error.localizedDescription)
                showProgressview = false
            } else {
                print("success")
                showProgressview = false
                isLoggedIn = true
                
                let isEmailVerified = Auth.auth().currentUser?.isEmailVerified;
                
                if isEmailVerified != nil && !isEmailVerified! {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func useAppleSignIn() {
        controller?.useAppleSignIn()
    }
    
    func appleSignInFlow() {
        controller?.performExistingAccountSetupFlow()
    }
    
    func signin() {
        signin(email: email, password: password)
    }
    
    func signup() {
        if password != repeatedPassword {
            errorMessage = "Passwords don't match"
            showError = true
            showProgressview = false
            return
        }
        
        let email = self.email
        let password = self.password
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            switch result {
            case .none:
                errorMessage = "Couldn't create user. Please try again"
                showError = true
                showProgressview = false
                return
            case .some(_):
                print("Created user")
                showUserSetup = true
                isLoggedIn = true
                // signin(email: email, password: password)
            }
        }
    }
 
    func forgotPassword() {
        print(email)
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
                errorMessage = "Couldn't send the reset link"
                showError = true
                showProgressview = false
            } else {
                print("password reset sent")
                viewControl = .Signin
                message = "We sent you a reset link via E-Mail if an account is associated with this E-Mail. Afterwards, sign in with your new password."
                showMessage = true
                showProgressview = false
            }
        }
    }
    
    func checkGoogleSignIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { (user, error) in
                authenticateGIDSignIn(for: user, with: error)
            }
        }
    }
    
    func useGoogleSignIn() {
        guard let clientId = FirebaseApp.app()?.options.clientID else { return }
        
        let configuration = GIDConfiguration(clientID: clientId)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { (user, error) in
            authenticateGIDSignIn(for: user, with: error)
        }
    }
    
    func authenticateGIDSignIn(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (_, error) in
            if error != nil {
                errorMessage = error?.localizedDescription ?? "Something went wrong. Try again.";
                showError = true
                print(error?.localizedDescription ?? "Error")
                showProgressview = false
            } else {
                showProgressview = false
                isLoggedIn = true
            }
        }
    }
    
    func appleSignInFinished() {
        isLoggedIn = true
    }
}

enum Views {
    case Signin;
    case Signup;
    case ForgotPassword;
}
