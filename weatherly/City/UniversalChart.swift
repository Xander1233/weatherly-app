//
//  UniversalChart.swift
//  weatherly
//
//  Created by David Neidhart on 24.01.23.
//

import SwiftUI
import Charts

struct UniversalChart: View {
    
    @State var data: [DataEntry]
    @State var metric: String
    
    var getRealYMin: Double {
        let map = data.map {
            return $0.data
        }.sorted()
        
        let minVal = map[0]
        
        return floor(minVal)
    }
    
    var getRealYMax: Double {
        let map = data.map {
            return $0.data
        }.sorted()
        let maxVal = map.reversed()[0]
        return ceil(maxVal)
    }
    
    var getYMin: Double {
        let yMin = getRealYMin
        let difference = getYMax - yMin
        if difference > 5 {
            return yMin - 2
        }
        if difference > 2 {
            return yMin - 1.5
        }
        if difference > 1 {
            return yMin - 1
        }
        return yMin - 0.5
    }
    
    var getYMax: Double {
        let yMax = getRealYMax
        let difference = yMax - getRealYMin
        if difference > 9 {
            return yMax + 4
        }
        if difference > 4 {
            return yMax + 2
        }
        if difference > 0 {
            return yMax + 1
        }
        return yMax + 0.5
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
        
        Chart {
            ForEach(data) { (entry) in
                LineMark(x: .value("Hour", parseDate(from: entry.label)), y: .value("data", roundTo2ndDecimalPlace(number: entry.data)))
                    .interpolationMethod(.cardinal)
                    .symbol(by: .value("Day", "current"))
                    .symbolSize(30)
                    .foregroundStyle(color)
                    .foregroundStyle(by: .value("Day", "current"))
                    .accessibilityLabel("\(parseDate(from: entry.label))")
                    .accessibilityValue("\(entry.data)")
                
                AreaMark(x: .value("Hour", parseDate(from: entry.label)), yStart: .value("min entry", getYMin), yEnd: .value("max entry", roundTo2ndDecimalPlace(number: entry.data)))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(gradient)
                    .foregroundStyle(by: .value("Day", "current"))
                    .accessibilityLabel("\(parseDate(from: entry.label))")
                    .accessibilityValue("\(entry.data)")
            }
            
            if parseDate(from: data[0].label).compare(Date.now) == .orderedAscending {
                RuleMark(x: .value("current", Date.now))
                    .lineStyle(StrokeStyle(dash: [1, 2]))
            }
            
        }
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic(minimumStride: 6)) { value in
                AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                AxisTick(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic) { value in
                AxisGridLine(centered: true)
                AxisTick(centered: true)
                AxisValueLabel {
                    let val = value.as(Double.self)!
                    Text(String(format: "%.2f\(metric)", val))
                }
            }
        }
        .chartYScale(domain: getYDomain)
        .frame(height: 300)
    }
    
    func parseDate(from dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateString)!
    }

    
    func roundTo2ndDecimalPlace(number: Double) -> Double {
        return round(number * 10) / 10
    }
}

struct DataEntry: Identifiable {
    let id = UUID()
    let label: String
    let data: Double
}
