//
//  CityTile.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

struct CityView: View {
    
    @State var data: City
    
    @State var errorMessage = ""
    
    @State var locData: WeatherDataCity? = nil
    
    var body: some View {
        
        VStack {
            
            if !errorMessage.isEmpty {
                Text("😦 \(errorMessage)")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding(.all, 10)
            } else {
                
                
                
            }
            
        }
        .navigationTitle("\(data.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            
            Functions.functions(region: "europe-west3")
                .httpsCallable("getLocation")
                .call(["location": data.name]) { (result, error) in
                    
                    if let error = error {
                        errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let resData = result?.data as? [String: Any] {
                        
                        print(resData)
                        
                        var forecastRes: [WeatherDataForecastDay] = []
                        
                        if let forecast = resData["forecast"] as? [[String: Any]] {
                            
                            for i in 0..<forecast.count {
                                
                                let entry = forecast[i]
                                
                                var date: String = ""
                                var day_maxtemp: Float = 0.0
                                var day_mintemp: Float = 0.0
                                var day_chanceRain: Int = 0
                                var day_chanceSnow: Int = 0
                                var day_condition_text: String = ""
                                var day_condition_code: Int = 0
                                var hours: [WeatherDataForecastDayHour] = []
                                
                                if let resDate = entry["date"] as? String {
                                    date = resDate
                                }
                                
                                if let resDayData = entry["day"] as? [String: Any] {
                                    
                                    if let resDayMaxTemp = resDayData["maxtemp_c"] as? Float {
                                        day_maxtemp = resDayMaxTemp
                                    }
                                    
                                    if let resDayMinTemp = resDayData["mintemp_c"] as? Float {
                                        day_mintemp = resDayMinTemp
                                    }
                                    
                                    if let resDayChanceRain = resDayData["daily_chance_of_rain"] as? Int {
                                        day_chanceRain = resDayChanceRain
                                    }
                                    
                                    if let resDayChanceSnow = resDayData["daily_chance_of_snow"] as? Int {
                                        day_chanceSnow = resDayChanceSnow
                                    }
                                    
                                    if let resDayCondition = resDayData["condition"] as? [String: Any] {
                                        if let resDayConditionText = resDayCondition["text"] as? String {
                                            day_condition_text = resDayConditionText
                                        }
                                        
                                        if let resDayConditionCode = resDayCondition["code"] as? Int {
                                            day_condition_code = resDayConditionCode
                                        }
                                    }
                                }
                                
                                
                                if let entryHours = entry["hour"] as? [[String: Any]] {
                                    for j in 0..<entryHours.count {
                                        
                                        let hourData = entryHours[j]
                                        
                                        var hourTime: String = ""
                                        var hourTemp: Float = 0.0
                                        var hourConditionText: String = ""
                                        var hourConditionCode: Int = 0
                                        var hourWindKph: Float = 0.0
                                        var hourWindDegree: Int = 0
                                        var hourPrecip: Float = 0.0
                                        var hourChanceOfRain: Int = 0
                                        var hourChanceOfSnow: Int = 0
                                        var hourVis: Float = 0.0
                                        
                                        if let resTime = hourData["time"] as? String {
                                            hourTime = resTime
                                        }
                                        
                                        if let resTemp = hourData["temp_c"] as? Float {
                                            hourTemp = resTemp
                                        }
                                        
                                        if let resHourCond = hourData["condition"] as? [String: Any] {
                                            if let resHourCondText = resHourCond["text"] as? String {
                                                hourConditionText = resHourCondText
                                            }
                                            
                                            if let resHourCondCode = resHourCond["code"] as? Int {
                                                hourConditionCode = resHourCondCode
                                            }
                                        }
                                        
                                        if let windKph = hourData["wind_kph"] as? Float {
                                            hourWindKph = windKph
                                        }
                                        
                                        if let windDeg = hourData["wind_degree"] as? Int {
                                            hourWindDegree = windDeg
                                        }
                                        
                                        if let precip = hourData["precip_mm"] as? Float {
                                            hourPrecip = precip
                                        }
                                        
                                        if let chanceRain = hourData["chance_of_rain"] as? Int {
                                            hourChanceOfRain = chanceRain
                                        }
                                        
                                        if let chanceSnow = hourData["chance_of_snow"] as? Int {
                                            hourChanceOfSnow = chanceSnow
                                        }
                                        
                                        if let vis = hourData["vis_km"] as? Float {
                                            hourVis = vis
                                        }
                                        
                                        hours.append(WeatherDataForecastDayHour(time: hourTime, temp_c: hourTemp, condition: WeatherDataCondition(text: hourConditionText, code: hourConditionCode), wind_kph: hourWindKph, wind_degree: hourWindDegree, precip_mm: hourPrecip, chanceOfRain: hourChanceOfRain, chanceOfSnow: hourChanceOfSnow, vis_km: hourVis))
                                        
                                    }
                                }
                                
                                forecastRes.append(WeatherDataForecastDay(date: date, maxtemp_c: day_maxtemp, mintemp_c: day_mintemp, chanceOfRain: day_chanceRain, chanceOfSnow: day_chanceSnow, condition: WeatherDataCondition(text: day_condition_text, code: day_condition_code), hours: hours))
                                
                            }
                            
                        }
                        
                        locData = WeatherDataCity(forecast: forecastRes)
                        print(locData)
                    }
                    
                }
            
        }
        
    }
}


struct WeatherDataCity {
    let id = UUID()
    let forecast: [WeatherDataForecastDay]
    let current: WeatherDataCurrent? = nil
    let alerts: [WeatherDataAlerts] = []
}

struct WeatherDataCurrent {
    let temp_c: Float
    let condition: WeatherDataCondition
    let wind_kph: Float
    let wind_degree: Int
    let vis_km: Float
    let uv: Float
    let precip_mm: Float
}

struct WeatherDataForecastDay: Identifiable {
    let id: UUID = UUID()
    let date: String
    let maxtemp_c: Float
    let mintemp_c: Float
    let chanceOfRain: Int
    let chanceOfSnow: Int
    let condition: WeatherDataCondition
    let hours: [WeatherDataForecastDayHour]
}

struct WeatherDataForecastDayHour: Identifiable {
    let id: UUID = UUID()
    let time: String
    let temp_c: Float
    let condition: WeatherDataCondition
    let wind_kph: Float
    let wind_degree: Int
    let precip_mm: Float
    let chanceOfRain: Int
    let chanceOfSnow: Int
    let vis_km: Float
}

struct WeatherDataCondition {
    let text: String
    let code: Int
}

struct WeatherDataAlerts {
    let headline: String
    let severity: String
    let areas: String
    let event: String
    let note: String
    let effective: String
    let expires: String
    let description: String
    let instruction: String
}
