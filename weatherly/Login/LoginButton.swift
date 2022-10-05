//
//  LoginButton.swift
//  weatherly
//
//  Created by David Neidhart on 10.10.22.
//

import SwiftUI

struct LoginButton: View {
    
    var buttonText: String
    @Binding var showProgressview: Bool
    var buttonAction: () -> Void
    
    var body: some View {
        Button {
            showProgressview = true
            buttonAction()
        } label: {
            HStack {
                if showProgressview {
                    ProgressView()
                        .padding(.trailing, 10)
                }
                Text(buttonText)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(5.0)
            .padding(.all, 20)
        }
        .disabled(showProgressview)
    }
}

