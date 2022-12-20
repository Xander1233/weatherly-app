//
//  DayView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI

struct DayView: View {
    
    @State var data: WeatherDataForecastDay
    
    var getDate: String {
        let dateSplitted = data.date.split(separator: "-")
        
        return "\(dateSplitted[2]).\(dateSplitted[1])"
    }
    
    var body: some View {
        HStack {
            
            Text(getDate)
                .padding(.horizontal, 5)
                .frame(width: 60)
            
            Image(systemName: codeToIconIdentifier(code: data.condition.code))
                .padding(.horizontal, 5)
            
            Spacer()
            
            Text(String(format: "%.0f°", data.mintemp_c))
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
            
            Text(String(format: "%.0f°", data.maxtemp_c))
                .padding(.horizontal, 5)
        }
    }
}
