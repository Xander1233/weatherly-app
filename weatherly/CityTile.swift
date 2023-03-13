//
//  CityTile.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

struct CityView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var data: City
    
    @State var errorMessage = ""
    
    @State var locData: WeatherDataCity? = nil
    
    @State var isFavorite = false
    
    @State var showAlert = false
    
    var setSelected: () -> Void = {
        
    }
    
    @State var isDeepLinked = false
    
    var hours: [HourOrAstro] {
        
        if locData == nil {
            return []
        }
        
        let array = getTimesAfterCurrentTime(times: locData?.forecast.first?.hours ?? [])
        
        let hasSunriseAlreadyOccured = !isHourBetweenNow(timeString: String(locData?.forecast.first?.astro.sunrise ?? "00:00 AM"))
        
        let hasSunsetAlreadyOccured = isHourBetweenNow(timeString: String(locData?.forecast.first?.astro.sunset ?? "00:00 AM"))
        
        let newArray: [HourOrAstro] = appendArray(array1: array, array2: getTimesBeforeCurrentTime(times: locData?.forecast[1].hours ?? []), astro: WeatherDataForecastDayAstro(sunrise: hasSunriseAlreadyOccured ? locData?.forecast[1].astro.sunrise ?? "00:01" : locData?.forecast.first?.astro.sunrise ?? "00:01", sunset: hasSunsetAlreadyOccured ? locData?.forecast[1].astro.sunset ?? "00:02" : locData?.forecast.first?.astro.sunset ?? "00:02"))
        
        return newArray
    }
    
    var body: some View {
        
        VStack {
            if errorMessage != "" {
                Text("error-occured")
                Text("error \(errorMessage)")
            } else if let locData = locData {
                
                VStack {
                    List {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(hours) { (astroOrHour) in
                                        
                                        if let hour = astroOrHour.hour {
                                            HourView(data: hour)
                                                .padding(.horizontal, 2)
                                        }
                                        
                                        if let astro = astroOrHour.astro {
                                            AstroView(data: astro)
                                                .padding(.horizontal, 2)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("7day-forecast")) {
                            ForEach(locData.forecast) { (day) in
                                DayView(data: day, city: data)
                            }
                        }
                    }
                    .refreshable {
                        fetch()
                    }
                }
            } else {
                HStack {
                    ProgressView()
                    Text("fetch-data")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("failed-to-add %@"))
        }
        .toolbar {
            if locData != nil {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
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
            }
            
        }
        .navigationTitle("\(data.name)")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            fetch()
        }
        .onChange(of: scenePhase) { (newValue) in
            
            if newValue == .active {
                fetch()
            }
            
        }
        
    }
    
    func isHourBetweenNow(timeString: String) -> Bool {
        
        let timeAndAMPM = timeString.components(separatedBy: " ")
        
        let isAM = timeAndAMPM[1].uppercased() == "AM"
        
        let time = timeAndAMPM[0]
        
        let now = Date()
        let calendar = Calendar.current
        let hourComponents = time.components(separatedBy: ":")
        let hour = Int(hourComponents[0])! + (isAM ? 0 : 12)
        let minute = Int(hourComponents[1])!
        let hourDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now)!
        
        return hourDate > now
    }
    
    private func fetch() {
        setSelected()
        
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
                            
                            var astro: WeatherDataForecastDayAstro = WeatherDataForecastDayAstro(sunrise: "", sunset: "")
                            
                            if let resDayAstro = entry["astro"] as? [String: Any] {
                                var sunrise: String = ""
                                if let astroSunrise = resDayAstro["sunrise"] as? String {
                                    sunrise = astroSunrise
                                }
                                var sunset: String = ""
                                if let astroSunset = resDayAstro["sunset"] as? String {
                                    sunset = astroSunset
                                }
                                astro = WeatherDataForecastDayAstro(sunrise: sunrise, sunset: sunset)
                            }
                            
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
                            
                            forecastRes.append(WeatherDataForecastDay(date: date, maxtemp_c: day_maxtemp, mintemp_c: day_mintemp, chanceOfRain: day_chanceRain, chanceOfSnow: day_chanceSnow, condition: WeatherDataCondition(text: day_condition_text, code: day_condition_code), hours: hours, astro: astro))
                        }
                        
                    }
                    
                    var alerts: [WeatherDataAlerts] = []
                    
                    if let alertsObj = resData["alerts"] as? [String: Any], let alertArray = alertsObj["alert"] as? [Any] {
                        
                        for i in 0..<alertArray.count {
                            
                            let alert = alertArray[i] as! [String: Any]
                            
                            // let alerts: WeatherDataAlerts?
                            
                            var headl: String?
                            var severi: String?
                            var area: String?
                            var eventString: String?
                            var notes: String?
                            var effectiveFrom: String?
                            var expiresOn: String?
                            var descrip: String?
                            var instruc: String?
                            
                            if let headline = alert["headline"] as? String {
                                headl = headline
                            }
                            
                            if let severity = alert["severity"] as? String {
                                severi = severity
                            }
                            
                            if let areas = alert["areas"] as? String {
                                area = areas
                            }
                            
                            if let event = alert["event"] as? String {
                                eventString = event
                            }
                            
                            if let note = alert["note"] as? String {
                                notes = note
                            }
                            
                            if let effective = alert["effective"] as? String {
                                effectiveFrom = effective
                            }
                            
                            if let expires = alert["expires"] as? String {
                                expiresOn = expires
                            }
                            
                            if let description = alert["desc"] as? String {
                                descrip = description
                            }
                            
                            if let instruction = alert["instruction"] as? String {
                                instruc = instruction
                            }
                            
                            alerts.append(WeatherDataAlerts(headline: headl!, severity: severi!, areas: area!, event: eventString!, note: notes!, effective: effectiveFrom!, expires: expiresOn!, description: descrip!, instruction: instruc!))
                            
                        }
                        
                    }
                    
                    locData = WeatherDataCity(forecast: forecastRes, alerts: alerts)
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
    
    func getAstroIndices(sunrise: String, sunset: String, array: [HourOrAstro]) -> [String: Any] {
        
        let hours = array.filter {
            return $0.hour != nil
        }.map { $0.hour }
        
        let sunriseSplitted = sunrise.split(separator: ":")
        let sunriseIsPM = sunrise.split(separator: " ")[1] == "PM"
        let sunriseHours = Int(sunriseSplitted[0]) ?? 0
        var sunriseHoursString = "\(sunriseIsPM ? sunriseHours + 12 : sunriseHours)"
        if sunriseHoursString.count == 1 {
            sunriseHoursString = "0\(sunriseHoursString)"
        }
        let sunriseTime = "\(sunriseHoursString):00"
        
        var sunriseIndex = 0
        
        for (index, hour) in hours.enumerated() {
            if hour!.time.split(separator: " ")[1] == sunriseTime {
                sunriseIndex = index
            }
        }
        
        let sunsetSplitted = sunset.split(separator: ":")
        let sunsetIsPM = sunset.split(separator: " ")[1] == "PM"
        let sunsetHours = Int(sunsetSplitted[0]) ?? 0
        var sunsetHoursString = "\(sunsetIsPM ? sunsetHours + 12 : sunsetHours)"
        if sunsetHoursString.count == 1 {
            sunsetHoursString = "0\(sunsetHoursString)"
        }
        let sunsetTime = "\(sunsetHoursString):00"
        
        var sunsetIndex = 0
        
        for (index, hour) in hours.enumerated() {
            if hour!.time.split(separator: " ")[1] == sunsetTime {
                sunsetIndex = index
            }
        }
        
        return [
            "sunrise": sunriseIndex > sunsetIndex ? sunriseIndex + 1 : sunriseIndex,
            "sunset": sunsetIndex > sunriseIndex ? sunsetIndex + 1 : sunsetIndex,
            "sunsetTime": "\(sunsetHoursString):\(sunsetSplitted[1].split(separator: " ")[0])",
            "sunriseTime": "\(sunriseHoursString):\(sunriseSplitted[1].split(separator: " ")[0])"
        ]
    }
    
    func appendArray(array1: [WeatherDataForecastDayHour], array2: [WeatherDataForecastDayHour], astro: WeatherDataForecastDayAstro) -> [HourOrAstro] {
        
        // Create a new array
        var newArray = [HourOrAstro]()
        // Loop through the first array
        for item in array1 {
            // Add the item to the new array
            newArray.append(HourOrAstro(hour: item))
        }
        // Loop through the second array
        for item in array2 {
            // Add the item to the new array
            newArray.append(HourOrAstro(hour: item))
        }
        
        let astroIndices = getAstroIndices(sunrise: astro.sunrise, sunset: astro.sunset, array: newArray)
        
        let sunrise = astroIndices["sunrise"] ?? 0
        let sunset = astroIndices["sunset"] ?? 0
        
        let sunriseTime = astroIndices["sunriseTime"]
        let sunsetTime = astroIndices["sunsetTime"]
        
        let sunriseIndex = (sunrise as! Int) + 1
        let sunsetIndex = (sunset as! Int) + 1
        
        if sunriseIndex >= newArray.count {
            newArray.append(HourOrAstro(astro: SunriseOrSunset(hour: sunriseTime as! String, isSunrise: true)))
        } else {
            newArray.insert(HourOrAstro(astro: SunriseOrSunset(hour: sunriseTime as! String, isSunrise: true)), at: sunriseIndex)
        }
        
        if sunsetIndex >= newArray.count {
            newArray.append(HourOrAstro(astro: SunriseOrSunset(hour: sunsetTime as! String, isSunrise: false)))
        } else {
            newArray.insert(HourOrAstro(astro: SunriseOrSunset(hour: sunsetTime as! String, isSunrise: false)), at: sunsetIndex)
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
    let astro: WeatherDataForecastDayAstro
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

struct WeatherDataForecastDayAstro {
    let sunrise: String
    let sunset: String
}


struct HourOrAstro: Identifiable {
    
    let id = UUID()
    
    init(hour: WeatherDataForecastDayHour) {
        self.hour = hour
    }
    
    init(astro: SunriseOrSunset) {
        self.astro = astro
    }
    
    var hour: WeatherDataForecastDayHour? = nil
    var astro: SunriseOrSunset? = nil
}

struct SunriseOrSunset {
    let hour: String
    let isSunrise: Bool
}
