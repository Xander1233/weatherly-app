//
//  ChartView.swift
//  weatherly
//
//  Created by David Neidhart on 22.01.23.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    @State var hours: [WeatherDataForecastDayHour]
    
    var getEverySecondHour: [WeatherDataForecastDayHour] {
        var arr: [WeatherDataForecastDayHour] = []
        
        for i in 0..<hours.count {
            if i % 2 == 0 {
                arr.append(hours[i])
            }
        }
        
        return arr
    }
    
    var body: some View {
        Chart {
            ForEach(getEverySecondHour) { (hour) in
                LineMark(x: .value("Hour", parseTime(from: hour.time)), y: .value("Temperature", hour.temp_c))
            }
        }
    }
    
    func parseTime(from: String) -> String {
        let split = from.split(separator: " ")
        return "\(split[1].split(separator: ":")[0])"
    }
}
