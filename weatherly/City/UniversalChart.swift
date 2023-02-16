//
//  UniversalChart.swift
//  weatherly
//
//  Created by David Neidhart on 24.01.23.
//

import SwiftUI
import Charts
import CoreLocation

struct UniversalChart: View {
    
    @State var data: [DataEntry]
    @State var metric: String
    
    @Binding var position: ChartPosition?
    
    @ObservedObject var locManager: LocationManager
    
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
        
        let color = Color.accentColor
        let gradient = LinearGradient(gradient: Gradient(colors: [
            color.opacity(0.5),
            color.opacity(0.2),
            color.opacity(0.05)
        ]), startPoint: .top, endPoint: .bottom)
        
        Chart {
            ForEach(data) { (entry) in
                
                AreaMark(x: .value("Hour", parseDate(from: entry.label)), yStart: .value("min entry", getYMin), yEnd: .value("max entry", roundTo2ndDecimalPlace(number: entry.data)))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(gradient)
                    .foregroundStyle(by: .value("Day", "current"))
                    .accessibilityLabel("\(parseDate(from: entry.label))")
                    .accessibilityValue("\(entry.data)")
                
                if let direction = entry.direction {
                    LineMark(x: .value("Hour", parseDate(from: entry.label)), y: .value("data", roundTo2ndDecimalPlace(number: entry.data)))
                        .interpolationMethod(.cardinal)
                        .symbolSize(30)
                        .symbol(symbol: {
                            Image(systemName: "location.north.fill")
                                .rotationEffect(Angle(degrees: locManager.degrees + direction))
                                .foregroundColor(color)
                                .frame(maxWidth: 5, maxHeight: 5)
                                .font(.system(size: 10))
                        })
                        .foregroundStyle(color)
                        .foregroundStyle(by: .value("Day", "current"))
                        .accessibilityLabel("\(parseDate(from: entry.label))")
                        .accessibilityValue("\(entry.data)")
                } else {
                    LineMark(x: .value("Hour", parseDate(from: entry.label)), y: .value("data", roundTo2ndDecimalPlace(number: entry.data)))
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Day", "current"))
                        .symbolSize(30)
                        .foregroundStyle(color)
                        .foregroundStyle(by: .value("Day", "current"))
                        .accessibilityLabel("\(parseDate(from: entry.label))")
                        .accessibilityValue("\(entry.data)")
                }
                
                if let position = position {
                    RuleMark(x: .value("Hour", parseDate(from: position.x)))
                        .opacity(0.2)
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [1, 2]))
                    RuleMark(y: .value("data", position.y))
                        .opacity(0.2)
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [1, 2]))
                    PointMark(x: .value("Hour", parseDate(from: position.x)), y: .value("data", position.y))
                        .foregroundStyle(.red)
                        .symbol(BasicChartSymbolShape.circle)
                        .symbolSize(100)
                }
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
                AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .wide)))
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
        .chartOverlay { proxy in
            GeometryReader { geometry in
              Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture().onChanged { value in updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy, isTap: false) })
                .onTapGesture { location in updateCursorPosition(at: location, geometry: geometry, proxy: proxy, isTap: true) }
            }
          }
    }
    
    func updateCursorPosition(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy, isTap: Bool) {
        let origin = geometry[proxy.plotAreaFrame].origin
        let datePos = proxy.value(atX: at.x - origin.x, as: Date.self)
        let firstGreater = data.lastIndex(where: { parseDate(from: $0.label) < datePos! })
        if let index = firstGreater {
            let x = data[index].label
            let y = data[index].data
            let pos = ChartPosition(x: x, y: y, data: data[index], metric: metric)
            
            if let position = position {
                if position.x == pos.x && isTap {
                    self.position = nil
                    return
                }
            }
            
            position = pos
        }
      }

    
    func roundTo2ndDecimalPlace(number: Double) -> Double {
        return round(number * 10) / 10
    }
}

struct DataEntry: Identifiable {
    let id = UUID()
    let label: String
    let data: Double
    let direction: Double?
    
    init(label: String, data: Double, direction: Double) {
        self.label = label
        self.data = data
        self.direction = direction
    }
    
    init(label: String, data: Double) {
        self.label = label
        self.data = data
        self.direction = nil
    }
}

struct ChartPosition {
    let x: String
    let y: Double
    let data: DataEntry
    let metric: String
}

func parseDate(from dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)!
}
