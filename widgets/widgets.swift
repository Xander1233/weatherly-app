//
//  widgets.swift
//  widgets
//
//  Created by David Neidhart on 14.02.23.
//

import WidgetKit
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
import FirebaseFunctions

struct Provider: IntentTimelineProvider {
    func getSnapshot(for configuration: SelectUsedFavoriteIntent, in context: Context, completion: @escaping (CityEntry) -> Void) {
        let date = Date()
        
        getLocation(for: (configuration.favorite?.intValue ?? 1) - 1, date: date) { city, error in
            if let error = error {
                completion(CityEntry(date: date, error: error))
            }
            getWeatherData(for: city!, date: date) { entry in
                completion(entry)
            }
        }
    }
    
    
    func placeholder(in context: Context) -> CityEntry {
        let date = Date()
        return CityEntry(date: date, error: "Please login")
    }

    func getTimeline(for configuration: SelectUsedFavoriteIntent,in context: Context, completion: @escaping (Timeline<CityEntry>) -> ()) {
        
        let date = Date()
        
        _ = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        
        getLocation(for: (configuration.favorite?.intValue ?? 1) - 1, date: date) { city, error in
            if let error = error {
                completion(Timeline(entries: [CityEntry(date: date, error: error)], policy: .never))
            }
            getWeatherData(for: city!, date: date) { entry in
                completion(Timeline(entries: [entry], policy: .never))
            }
        }
    }
}


struct LocationProvider: TimelineProvider {
    
    @StateObject var locationManager = LocationManagerWidgets()
    
    func getSnapshot(in context: Context, completion: @escaping (CityEntry) -> Void) {
        let date = Date()
        
        getLocation(for: 0, date: date) { city, error in
            
            if let error = error {
                completion(CityEntry(date: date, error: error))
            }
            
            getWeatherData(for: city!, date: date) { entry in
                completion(entry)
            }
        }
    }
    
    
    func placeholder(in context: Context) -> CityEntry {
        let date = Date()
        return CityEntry(date: date, error: "Please login")
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CityEntry>) -> ()) {
        
        let date = Date()
        
        getCurrentLocation(lat: locationManager.lastLocation?.coordinate.latitude, lon: locationManager.lastLocation?.coordinate.longitude) { city in
            getWeatherData(for: city, date: date) { entry in
                completion(Timeline(entries: [entry], policy: .never))
            }
        }
    }
}

struct CityEntry: TimelineEntry {
    
    init(date: Date, city: City, data: CurrentWeather) {
        self.date = date
        self.city = city
        self.data = data
        self.error = nil
    }
    
    init(date: Date, error: String) {
        self.date = date
        self.error = error
        self.city = nil
        self.data = nil
    }
    
    let date: Date
    let city: City?
    let data: CurrentWeather?
    let error: String?
}

struct WidgetView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    var body: some View {
        
        switch widgetFamily {
        case .systemSmall:
            SystemSmall(entry: entry)
        case .accessoryCircular:
            Text("Test")
        case .accessoryRectangular:
            AccessoryRectangle(entry: entry)
        case .systemMedium:
            SystemMedium(entry: entry)
        case .systemLarge:
            Text("Test")
        case .systemExtraLarge:
            Text("Test")
        case .accessoryInline:
            Text("Test")
        @unknown default:
            Text("Test")
        }
        
    }
}

struct SystemSmall: View {
    
    var entry: Provider.Entry

    var body: some View {
        
        if let error = entry.error {
            Text("\(error)")
                .font(.system(size: 8))
        } else {
            HStack {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("\(entry.city!.name)")
                                Spacer()
                            }
                            HStack {
                                Text("\(entry.city!.country)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text(String(format: "%.0f°", entry.data!.temperature))
                            .font(.system(size: 25))
                        Spacer()
                        Image(systemName: "\(codeToIconIdentifierForWidgets(code: entry.data!.conditionCode))")
                    }
                }
                .padding()
            }
        }
    }
}

struct SystemMedium: View {
    var entry: Provider.Entry
    
    var body: some View {
        if let error = entry.error {
            Text("\(error)")
        } else {
            HStack {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("\(entry.city!.name)")
                                Spacer()
                            }
                            HStack {
                                Text("\(entry.city!.country)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        Spacer()
                        Text(String(format: "%.0f°", entry.data!.temperature))
                            .font(.system(size: 25))
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Text(String(format: "%.0f mm", entry.data!.precipMM))
                                .font(.system(size: 20))
                            Spacer()
                            Text(String(format: "%.0f km", entry.data!.visKm))
                                .font(.system(size: 20))
                        }
                        HStack {
                            Text(String(format: "%.0f kmh", entry.data!.windKph))
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "\(codeToIconIdentifierForWidgets(code: entry.data!.conditionCode))")
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct AccessoryRectangle: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        if let error = entry.error {
            Text("\(error)")
        } else {
            HStack {
                VStack {
                    HStack {
                        Text("\(entry.city!.name)")
                            .font(.system(size: 10))
                        Spacer()
                        Text(String(format: "%.0f°", entry.data!.temperature))
                    }
                    HStack {
                        Text("\(entry.city!.country)")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}

struct WeatherlyWidget: Widget {
    
    let kind: String = "widgets"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectUsedFavoriteIntent.self, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Current Weather Favorites")
        .description("Display the current weather of the first location that is marked as a favorite.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct CurrentLocationWidget: Widget {
    let kind = "widgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LocationProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Current Weather Location")
        .description("Display the current weather of your current location.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let country: String
}

struct CurrentWeather: Identifiable {
    let id = UUID()
    let temperature: Double
    let conditionCode: Int
    let windKph: Double
    let precipMM: Double
    let visKm: Double
}

func getLocation(for favoriteIndex: Int, date: Date, completion: @escaping (City?, String?) -> ()) {
    
    Functions.functions(region: "europe-west3")
        .httpsCallable("getFavorites")
        .call { res, error in
            
            if let error = error {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
            var region: String = ""
            var country: String = ""
            
            if let favoritesArray = res?.data as? [[String: Any]] {
                
                if favoritesArray.isEmpty {
                    completion(nil, "You don't have any favorites. You can add some in the app.")
                }
                
                let index = [ favoriteIndex, favoritesArray.count ].min() ?? 0
                
                if let cityRegion = favoritesArray[index]["region"] as? String {
                    region = cityRegion
                }
                
                if let cityCountry = favoritesArray[index]["country"] as? String {
                    country = cityCountry
                }
                
                if let cityName = favoritesArray[index]["name"] as? String {
                    completion(City(name: cityName, region: region, country: country), nil)
                }
            }
        }
}

func getWeatherData(for city: City, date: Date, completion: @escaping (CityEntry) -> ()) {
    
    Functions.functions(region: "europe-west3")
        .httpsCallable("getLocation")
        .call(["location": city.name]) { (result, error) in
            
            if let error = error {
                print(error)
                completion(CityEntry(date: date, error: "\(error)"))
            }
            
            if let resData = result?.data as? [String: Any] {
                
                if let condRes = resData["current"] as? [String: Any] {
                    
                    var tempC = 0.0
                    var conditionCode = 0
                    var windKph = 0.0
                    var precipMM = 0.0
                    var visKm = 0.0
                    
                    if let tempCRes = condRes["temp_c"] as? Double {
                        tempC = tempCRes
                    }
                    
                    if let windKPH = condRes["wind_kph"] as? Double {
                        windKph = windKPH
                    }
                    
                    if let precipmm = condRes["precip_mm"] as? Double {
                        precipMM = precipmm
                    }
                    
                    if let viskm = condRes["vis_km"] as? Double {
                        visKm = viskm
                    }
                    
                    if let conditionRes = condRes["condition"] as? [String: Any] {
                        if let condResCode = conditionRes["code"] as? Int {
                            conditionCode = condResCode
                        }
                    }
                    
                    
                    completion(CityEntry(date: date, city: city, data: CurrentWeather(temperature: tempC, conditionCode: conditionCode, windKph: windKph, precipMM: precipMM, visKm: visKm)))
                }
            }
        }
    
}

func getCurrentLocation(lat userLatitude: Double?, lon userLongitude: Double?, completion: @escaping (City) -> ()) {
    
    if userLatitude == nil || userLongitude == nil {
        return
    }
    
    let functions = Functions.functions(region: "europe-west3")
    
    functions.httpsCallable("autoCompleteLocation")
        .call(["query": "\(userLatitude!),\(userLongitude!)"]) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let resData = result?.data as? [String: [Any]], let data = resData["data"] as? [[String: Any]] {
                    
                let entry = data[0]
                
                var name = ""
                var country = ""
                var region = ""
                
                if let resName = entry["name"] as? String {
                    name = resName
                }
                
                if let resCountry = entry["country"] as? String {
                    country = resCountry
                }
                
                if let resRegion = entry["region"] as? String {
                    region = resRegion
                }
                completion(City(name: name, region: region, country: country))
            }
        }
}
