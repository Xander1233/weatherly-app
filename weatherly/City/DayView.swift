//
//  DayView.swift
//  weatherly
//
//  Created by David Neidhart on 21.10.22.
//

import SwiftUI
import Charts

struct DayView: View {
    
    @State var data: WeatherDataForecastDay
    
    @State var showSheet = false
    
    var getDate: String {
        let dateSplitted = data.date.split(separator: "-")
        
        return "\(dateSplitted[2]).\(dateSplitted[1])"
    }
    
    var body: some View {
        Button {
            showSheet = true
            print(data.hours[0].time)
        } label: {
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
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                ChartView(hours: data.hours)
                    .padding(.horizontal)
                    .frame(height: 300)
                    .navigationTitle("Temperature")
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
