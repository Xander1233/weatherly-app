//
//  HourView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI

struct HourView: View {
    
    @State var data: WeatherDataForecastDayHour
    
    var hourTitle: String {
        let hour = data.time.components(separatedBy: " ")[1]
        
        // Get the current time
        let now = Date()
        // Create a date formatter
        let formatter = DateFormatter()
        // Set the date format
        formatter.dateFormat = "HH:00"
        // Print the current time
        let nowTime = formatter.string(from: now)
        
        if hour == nowTime {
            return "Now"
        }
        
        return hour
    }
    
    var body: some View {
        
        VStack {
            Text("\(hourTitle)")
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
