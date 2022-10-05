//
//  SocialLoginButton.swift
//  weatherly
//
//  Created by David Neidhart on 15.10.22.
//

import SwiftUI

struct SocialLoginButton: View {
    var image: String
    var text: String
    
    var body: some View{
        HStack{
            Image(image)
                .frame(width: 32, height: 32)
                .padding(.horizontal, 12)
                .padding(.trailing,10)
            
            Text(text)
                .bold()
                .foregroundColor(Color.black)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .cornerRadius(5.0)
    }
}
