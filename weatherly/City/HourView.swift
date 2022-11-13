//
//  HourView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI

struct HourView: View {
    
    @State var data: WeatherDataForecastDayHour
    
    var body: some View {
        
        VStack {
            Text("\(data.time.components(separatedBy: " ")[1])")
                .padding(.top, 3)
            Image(systemName: "\(codeToIconIdentifier(code: data.condition.code))")
                .frame(height: 10)
                .padding(.top, 3)
            
            Text(String(format: "%.0f°", data.temp_c))
                .padding(.top, 3)
        }
        .padding(.horizontal, 5)
        
    }
}
