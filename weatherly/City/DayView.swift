//
//  DayView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI

struct DayView: View {
    
    @State var data: WeatherDataForecastDay
    
    var body: some View {
        HStack {
            
            Text(data.date)
                .padding(.horizontal, 5)
            
            Image(systemName: codeToIconIdentifier(code: data.condition.code))
                .padding(.horizontal, 5)
            
            Text(String(format: "%.0f°", data.mintemp_c))
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
            
            Text(String(format: "%.0f°", data.maxtemp_c))
                .padding(.horizontal, 5)
            
            
        }
    }
}
