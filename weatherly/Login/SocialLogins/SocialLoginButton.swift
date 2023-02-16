//
//  SocialLoginButton.swift
//  weatherly
//
//  Created by David Neidhart on 15.10.22.
//

import SwiftUI

struct SocialLoginButton: View {
    var image: String = ""
    var text: String = ""
    var showAppleLogo: Bool = false
    
    init(image: String, text: String) {
        self.image = image
        self.text = text
    }
    
    init(text: String) {
        self.text = text
        self.showAppleLogo = true
    }
    
    var body: some View{
        HStack{
            
            if showAppleLogo {
                Image(systemName: "apple.logo")
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 12)
                    .padding(.trailing, 10)
            } else {
                Image(image)
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 12)
                    .padding(.trailing, 10)
            }
            
            Text(LocalizedStringKey(text))
                .bold()
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .cornerRadius(5.0)
    }
}
