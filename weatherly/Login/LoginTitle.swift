//
//  LoginTitle.swift
//  weatherly
//
//  Created by David Neidhart on 10.10.22.
//

import SwiftUI

struct LoginPageTitle: View {
    
    let subtitle: String
    
    var body: some View {
        VStack {
            Text("Weatherly")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Text(LocalizedStringKey(subtitle))
                .font(.title2)
                .foregroundColor(.gray)
                .fontWeight(.regular)
                .padding(.bottom, 80)
        }
    }
}
