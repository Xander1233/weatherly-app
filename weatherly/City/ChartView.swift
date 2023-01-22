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
    
    var getYMin: Double {
        let map = getEverySecondHour.map { hour in
            return hour.temp_c
        }.sorted()
        
        let minVal = map[0]
        
        return floor(minVal)
    }
    
    var getYMax: Double {
        let map = getEverySecondHour.map { hour in
            return hour.temp_c
        }.sorted()
        let maxVal = map.reversed()[0]
        return ceil(maxVal + 4)
    }
    
    var getYDomain: ClosedRange<Double> {
        return getYMin...getYMax
    }
    
    var body: some View {
        
        let color = Color(hue: 0.69, saturation: 0.19, brightness: 0.79)
        let gradient = LinearGradient(gradient: Gradient(colors: [
            color.opacity(0.5),
            color.opacity(0.2),
            color.opacity(0.05)
        ]), startPoint: .top, endPoint: .bottom)
        
        VStack {
            Chart {
                ForEach(getEverySecondHour) { (hour) in
                    LineMark(x: .value("Hour", parseTime(from: hour.time)), y: .value("Temperature", roundTo2ndDecimalPlace(number: hour.temp_c)))
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Day", "current"))
                        .symbolSize(30)
                        .foregroundStyle(color)
                        .foregroundStyle(by: .value("Day", "current"))
                        .accessibilityLabel("\(parseTime(from: hour.time))")
                        .accessibilityValue("\(hour.temp_c)°C")
                    
                    AreaMark(x: .value("Hour", parseTime(from: hour.time)), yStart: .value("min temp", getYMin), yEnd: .value("max temp", roundTo2ndDecimalPlace(number: hour.temp_c)))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(gradient)
                        .foregroundStyle(by: .value("Day", "current"))
                        .accessibilityLabel("\(parseTime(from: hour.time))")
                        .accessibilityValue("\(hour.temp_c)°C")
                }
            }
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                    AxisTick(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                    AxisValueLabel(centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    AxisGridLine(centered: true)
                    AxisTick(centered: true)
                    AxisValueLabel(verticalSpacing: 3)
                }
            }
            .chartYScale(domain: getYDomain)
            .chartPlotStyle { (plotArea) in
                plotArea.backgroundStyle(.thinMaterial)
            }
            .frame(height: 300)
            
            Spacer()
        }
    }
    
    func parseTime(from: String) -> String {
        let split = from.split(separator: " ")
        return "\(split[1].split(separator: ":")[0])"
    }
    
    func roundTo2ndDecimalPlace(number: Double) -> Double {
        return round(number * 10) / 10
    }
}
