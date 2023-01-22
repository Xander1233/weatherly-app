//
//  AstroView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI

struct AstroView: View {
    
    @State var data: SunriseOrSunset
    
    var body: some View {
        
        VStack {
            Image(systemName: "\(data.isSunrise ? "sunrise" : "sunset")")
                .frame(height: 10)
                .padding(.top, 3)
            
            
            Text("\(data.hour)")
                .padding(.top, 3)
        }
        .padding(.horizontal, 5)
        
    }
}
