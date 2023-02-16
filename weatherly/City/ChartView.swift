//
//  ChartView.swift
//  weatherly
//
//  Created by David Neidhart on 22.01.23.
//

import SwiftUI
import Charts
import CoreLocation

struct ChartView: View {
    
    @State var hours: [WeatherDataForecastDayHour]
    
    @State var max: Double
    @State var min: Double
    
    @State var day: String
    
    @State var city: String
    
    @State private var currentChart: ChartOptions = .temperature
    
    @State private var position: ChartPosition?
    
    @ObservedObject private var locManager = LocationManager(kCLLocationAccuracyHundredMeters)
    
    var getTempMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: $0.temp_c)
        }
    }
    
    var getPrecipMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: $0.precip_mm)
        }
    }
    
    var getVisMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: $0.vis_km)
        }
    }
    
    var getWindMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: $0.wind_kph, direction: Double($0.wind_degree))
        }
    }
    
    var getChanceOfRainMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: Double($0.chanceOfRain))
        }
    }
    
    var getChanceOfSnowMap: [DataEntry] {
        return hours.map {
            return DataEntry(label: $0.time, data: Double($0.chanceOfSnow))
        }
    }
    
    var body: some View {
        
        VStack {
            
            GroupBox {
                
                VStack {
                    HStack {
                        if let position = position {
                            VStack {
                                HStack {
                                    if let direction = position.data.direction {
                                        Image(systemName: "location.north.fill")
                                            .rotationEffect(Angle(degrees: locManager.degrees + direction))
                                            .font(.system(size: 15))
                                    }
                                    Text("\(String(format: "%.0f\(position.metric)", position.y))")
                                        .font(.title3)
                                }
                                Text("\(parseDate(from: position.x).formatted(.dateTime.hour(.defaultDigits(amPM: .wide))))")
                                    .font(.system(size: 15))
                            }
                        } else {
                            VStack {
                                switch currentChart {
                                case .temperature:
                                    Text(String(format: "%.0f°C", max))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f°C", min))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                case .visibility:
                                    Text(String(format: "%.0f km", max(of: hours.map { $0.vis_km })))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f km", min(of: hours.map{ $0.vis_km })))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                case .precip:
                                    Text(String(format: "%.0f mm", max(of: hours.map { $0.precip_mm })))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f mm", min(of: hours.map{ $0.precip_mm })))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                case .wind:
                                    Text(String(format: "%.0f km/h", max(of: hours.map { $0.wind_kph })))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f km/h", min(of: hours.map{ $0.wind_kph })))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                case .chanceSnow:
                                    Text(String(format: "%.0f %", max(of: hours.map { Double($0.chanceOfSnow) })))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f %", min(of: hours.map{ Double($0.chanceOfSnow) })))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                case .chanceRain:
                                    Text(String(format: "%.0f %", max(of: hours.map { Double($0.chanceOfRain) })))
                                        .padding(.horizontal, 5)
                                        .font(.title3)
                                    Text(String(format: "%.0f %", min(of: hours.map{ Double($0.chanceOfRain) })))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                }
                            }
                        }
                        Spacer()
                        Menu {
                            Button {
                                currentChart = .temperature
                            } label: {
                                Text("temperature")
                                Image(systemName: "thermometer")
                            }
                            Button {
                                currentChart = .precip
                            } label: {
                                Text("Precipitation")
                                Image(systemName: "drop.fill")
                            }
                            Button {
                                currentChart = .visibility
                            } label: {
                                Text("visibility")
                                Image(systemName: "eyeglasses")
                            }
                            Button {
                                currentChart = .wind
                            } label: {
                                Text("Wind in Km/h")
                                Image(systemName: "wind")
                            }
                            Button {
                                currentChart = .chanceRain
                            } label: {
                                Text("chance-of-rain")
                                Image(systemName: "umbrella.percent.fill")
                            }
                            Button {
                                currentChart = .chanceSnow
                            } label: {
                                Text("chance-of-snow")
                                Image(systemName: "snow")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "\(currentChart.toImage())")
                                    .padding(.trailing, 3)
                                Text(currentChart.toString())
                                Image(systemName: "chevron.down")
                                    .padding(.leading, 3)
                            }
                            .padding(.all, 5)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                            
                        }
                        .onChange(of: currentChart) { newValue in
                            position = nil
                        }
                    }
                    
                    switch currentChart {
                    case .wind:
                        UniversalChart(data: getWindMap, metric: " km/h", position: $position, locManager: locManager)
                    case .visibility:
                        UniversalChart(data: getVisMap, metric: " km", position: $position, locManager: locManager)
                    case .precip:
                        UniversalChart(data: getPrecipMap, metric: " mm", position: $position, locManager: locManager)
                    case .temperature:
                        UniversalChart(data: getTempMap, metric: "°C", position: $position, locManager: locManager)
                    case .chanceRain:
                        UniversalChart(data: getChanceOfRainMap, metric: " %", position: $position, locManager: locManager)
                    case .chanceSnow:
                        UniversalChart(data: getChanceOfSnowMap, metric: " %", position: $position, locManager: locManager)
                    }
                }
            } label: {
                HStack {
                    Text("\(day) in \(city)")
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "\(currentChart.toImage())")
                        .padding(.horizontal)
                }
            }
            .groupBoxStyle(BackgroundGroupBoxStyle())
            .padding()
            
            Spacer()
        }
    }
    
    enum ChartOptions {
        case temperature
        case precip
        case visibility
        case wind
        case chanceRain
        case chanceSnow
        
        func toString() -> LocalizedStringKey {
            switch self {
            case .wind:
                return LocalizedStringKey("wind")
            case .visibility:
                return "visiblity"
            case .precip:
                return "precipitation"
            case .temperature:
                return "temperature"
            case .chanceRain:
                return "chance-of-rain"
            case .chanceSnow:
                return "chance-of-snow"
            }
        }
        func toImage() -> String {
            switch self {
            case .wind:
                return "wind"
            case .visibility:
                return "eyeglasses"
            case .precip:
                return "drop.fill"
            case .temperature:
                return "thermometer"
            case .chanceRain:
                return "umbrella.percent.fill"
            case .chanceSnow:
                return "snow"
            }
        }
    }
    
    func average(of data: [Double]) -> Double {
        var sum = 0.0
        for entry in data {
            sum += entry
        }
        return sum / Double(data.count)
    }
    
    func max(of data: [Double]) -> Double {
        return data.sorted().reversed()[0]
    }
    func min(of data: [Double]) -> Double {
        return data.sorted()[0]
    }
}

struct BackgroundGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.top, 15)
            .padding(20)
            .background(.regularMaterial)
            .cornerRadius(20)
            .overlay(
                configuration.label.padding(10),
                alignment: .topLeading
            )
    }
}
