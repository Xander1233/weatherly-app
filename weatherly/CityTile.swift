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
    
    @State var isFavorite = false
    
    @State var showAlert = false
    
    var hours: [WeatherDataForecastDayHour] {
        
        if locData == nil {
            return []
        }
        
        var array = getTimesAfterCurrentTime(times: locData?.forecast.first?.hours ?? [])
        
        if array.count < 24 {
            array = appendArray(array1: array, array2: getTimesBeforeCurrentTime(times: locData?.forecast[1].hours ?? []))
        }
            
        return array
    }
    
    var body: some View {
        
        VStack {
            if errorMessage != "" {
                Text("An error occured. That shouldn't have happened.")
                Text("Error: \(errorMessage)")
            } else if let locData = locData {
                
                VStack {
                    List {
                        
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(hours) { (hour) in
                                        HourView(data: hour)
                                            .padding(.horizontal, 2)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("7-day Forecast")) {
                            ForEach(locData.forecast) { (day) in
                                DayView(data: day)
                            }
                        }
                    }
                }
                .toolbar {
                    Button {
                        if isFavorite {
                            removeFromFavorites()
                        } else {
                            addToFavorites()
                        }
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                    }
                }
                
            } else {
                ProgressView()
                Text("Fetching Data")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Failed to add " + data.name + " to your favorites"))
        }
        .navigationTitle("\(data.name)")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            
            Functions.functions(region: "europe-west3")
                .httpsCallable("isFavorite")
                .call(["name": data.name, "region": data.region, "country": data.country]) { (result, error) in
                    
                    if let error = error {
                        errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let res = result?.data as? [String:Any] {
                        isFavorite = (res["isFavorite"] as? Bool) ?? false
                    }
                    
                }
            
            Functions.functions(region: "europe-west3")
                .httpsCallable("getLocation")
                .call(["location": data.name]) { (result, error) in
                    
                    if let error = error {
                        errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let resData = result?.data as? [String: Any] {
                        
                        var forecastRes: [WeatherDataForecastDay] = []
                        
                        if let forecastOuter = resData["forecast"] as? [String: Any], let forecastInnerOuter = forecastOuter["forecast"] as? [String: Any], let forecast = forecastInnerOuter["forecastday"] as? [Any] {
                            
                            for i in 0..<forecast.count {
                                
                                let entry = forecast[i] as! [String: Any]
                                
                                var date: String = ""
                                var day_maxtemp: Double = 0.0
                                var day_mintemp: Double = 0.0
                                var day_chanceRain: Int = 0
                                var day_chanceSnow: Int = 0
                                var day_condition_text: String = ""
                                var day_condition_code: Int = 0
                                var hours: [WeatherDataForecastDayHour] = []
                                
                                if let resDate = entry["date"] as? String {
                                    date = resDate
                                }
                                
                                if let resDayData = entry["day"] as? [String: Any] {
                                    
                                    if let resDayMaxTemp = resDayData["maxtemp_c"] as? Double {
                                        day_maxtemp = resDayMaxTemp
                                    }
                                    
                                    if let resDayMinTemp = resDayData["mintemp_c"] as? Double {
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
                                
                                
                                if let entryHours = entry["hour"] as? [Any] {
                                    for j in 0..<entryHours.count {
                                        
                                        let hourData = entryHours[j] as! [String: Any]
                                        
                                        var hourTime: String = ""
                                        var hourTemp: Double = 0.0
                                        var hourConditionText: String = ""
                                        var hourConditionCode: Int = 0
                                        var hourWindKph: Double = 0.0
                                        var hourWindDegree: Int = 0
                                        var hourPrecip: Double = 0.0
                                        var hourChanceOfRain: Int = 0
                                        var hourChanceOfSnow: Int = 0
                                        var hourVis: Double = 0.0
                                        
                                        if let resTime = hourData["time"] as? String {
                                            hourTime = resTime
                                        }
                                        
                                        if let resTemp = hourData["temp_c"] as? Double {
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
                                        
                                        if let windKph = hourData["wind_kph"] as? Double {
                                            hourWindKph = windKph
                                        }
                                        
                                        if let windDeg = hourData["wind_degree"] as? Int {
                                            hourWindDegree = windDeg
                                        }
                                        
                                        if let precip = hourData["precip_mm"] as? Double {
                                            hourPrecip = precip
                                        }
                                        
                                        if let chanceRain = hourData["chance_of_rain"] as? Int {
                                            hourChanceOfRain = chanceRain
                                        }
                                        
                                        if let chanceSnow = hourData["chance_of_snow"] as? Int {
                                            hourChanceOfSnow = chanceSnow
                                        }
                                        
                                        if let vis = hourData["vis_km"] as? Double {
                                            hourVis = vis
                                        }
                                        
                                        hours.append(WeatherDataForecastDayHour(time: hourTime, temp_c: hourTemp, condition: WeatherDataCondition(text: hourConditionText, code: hourConditionCode), wind_kph: hourWindKph, wind_degree: hourWindDegree, precip_mm: hourPrecip, chanceOfRain: hourChanceOfRain, chanceOfSnow: hourChanceOfSnow, vis_km: hourVis))
                                    }
                                }
                                
                                forecastRes.append(WeatherDataForecastDay(date: date, maxtemp_c: day_maxtemp, mintemp_c: day_mintemp, chanceOfRain: day_chanceRain, chanceOfSnow: day_chanceSnow, condition: WeatherDataCondition(text: day_condition_text, code: day_condition_code), hours: hours))
                            }
                            
                        }
                        
                        locData = WeatherDataCity(forecast: forecastRes)
                    }
                    
                }
            
        }
        
    }
    
    private func addToFavorites() {
        
        Functions.functions(region: "europe-west3")
            .httpsCallable("addToFavorites")
            .call(["city": data.name, "country": data.country, "region": data.region]) { (result, error) in
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                
                isFavorite = true
                
            }
        
    }
    
    private func removeFromFavorites() {
        
        Functions.functions(region: "europe-west3")
            .httpsCallable("removeFromFavorites")
            .call(["city": data.name, "country": data.country, "region": data.region]) { (result, error) in
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                
                isFavorite = false
                
            }
        
    }
    
    func getTimesBeforeCurrentTime(times: [WeatherDataForecastDayHour]) -> [WeatherDataForecastDayHour] {
        // Get the current time
        let now = Date()
        // Create a date formatter
        let formatter = DateFormatter()
        // Set the date format
        formatter.dateFormat = "HH:00"
        // Get the current time as a string
        let nowString = formatter.string(from: now)
        
        // Create an array to hold the times after the current time
        var timesAfterCurrentTime = [WeatherDataForecastDayHour]()
        // Loop through the times
        for time in times {
            
            let compareTo = time.time.split(separator: " ")[1]
            
            // If the time is after the current time
            if compareTo < nowString {
                
                // Add the time to the array
                timesAfterCurrentTime.append(time)
            }
        }
        // Return the array of times after the current time
        return timesAfterCurrentTime
    }
    
    func getTimesAfterCurrentTime(times: [WeatherDataForecastDayHour]) -> [WeatherDataForecastDayHour] {
        // Get the current time
        let now = Date()
        // Create a date formatter
        let formatter = DateFormatter()
        // Set the date format
        formatter.dateFormat = "HH:00"
        // Get the current time as a string
        let nowString = formatter.string(from: now)
        
        // Create an array to hold the times after the current time
        var timesAfterCurrentTime = [WeatherDataForecastDayHour]()
        // Loop through the times
        for time in times {
            
            let compareTo = time.time.split(separator: " ")[1]
            
            // If the time is after the current time
            if compareTo >= nowString {
                
                // Add the time to the array
                timesAfterCurrentTime.append(time)
            }
        }
        // Return the array of times after the current time
        return timesAfterCurrentTime
    }
    
    func appendArray(array1: [WeatherDataForecastDayHour], array2: [WeatherDataForecastDayHour]) -> [WeatherDataForecastDayHour] {
        // Create a new array
        var newArray = [WeatherDataForecastDayHour]()
        // Loop through the first array
        for item in array1 {
            // Add the item to the new array
            newArray.append(item)
        }
        // Loop through the second array
        for item in array2 {
            // Add the item to the new array
            newArray.append(item)
        }
        // Return the new array
        return newArray
    }

}


struct WeatherDataCity {
    let id = UUID()
    var forecast: [WeatherDataForecastDay] = []
    var current: WeatherDataCurrent? = nil
    var alerts: [WeatherDataAlerts] = []
}

struct WeatherDataCurrent {
    let temp_c: Double
    let condition: WeatherDataCondition
    let wind_kph: Double
    let wind_degree: Int
    let vis_km: Double
    let uv: Double
    let precip_mm: Double
}

struct WeatherDataForecastDay: Identifiable {
    let id: UUID = UUID()
    let date: String
    let maxtemp_c: Double
    let mintemp_c: Double
    let chanceOfRain: Int
    let chanceOfSnow: Int
    let condition: WeatherDataCondition
    let hours: [WeatherDataForecastDayHour]
}

struct WeatherDataForecastDayHour: Identifiable {
    let id: UUID = UUID()
    let time: String
    let temp_c: Double
    let condition: WeatherDataCondition
    let wind_kph: Double
    let wind_degree: Int
    let precip_mm: Double
    let chanceOfRain: Int
    let chanceOfSnow: Int
    let vis_km: Double
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
