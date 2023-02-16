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
    @State var city: City
    
    @State var showSheet = false
    
    var getDate: String {
        let dateSplitted = data.date.split(separator: "-")
        
        return "\(dateSplitted[2]).\(dateSplitted[1])."
    }
    
    var body: some View {
        Button {
            showSheet = true
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
                VStack {
                    ChartView(hours: data.hours, max: data.maxtemp_c, min: data.mintemp_c, day: getDate, city: city.name)
                    Spacer()
                }
                .toolbar {
                    Button {
                        showSheet = false
                    } label: {
                        Text("done")
                    }
                }
                .navigationTitle("Details")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
