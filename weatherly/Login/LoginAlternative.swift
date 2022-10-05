//
//  LoginAlternative.swift
//  weatherly
//
//  Created by David Neidhart on 10.10.22.
//

import SwiftUI

struct LoginAlternativ: View {
    
    var text: String
    var buttonText: String
    var action: () -> Void
    
    
    var body: some View {
        HStack {
            Text(text)
            Button {
                action()
            } label: {
                Text(buttonText)
            }
        }
    }    
}

