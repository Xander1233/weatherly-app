//
//  FavoriteView.swift
//  weatherly
//
//  Created by David Neidhart on 22.10.22.
//

import SwiftUI
import FirebaseFunctions

struct FavoriteView: View {
    
    @State var data: City
    
    @State var locData: WeatherDataCity? = nil
    
    @State var isFavorite = false
    
    @State var failed = false
    
    @State var isCurrentLocation = false
    
    var body: some View {
        
        VStack {
            
            VStack {
                HStack {
                    if isCurrentLocation {
                        Image(systemName: "location")
                    }
                    Text("\(data.name)")
                    Spacer()
                }
                HStack {
                    Text("\(data.region), \(data.country)")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                }
            }
            
            if failed {
                Text("Failed to fetch weather data")
            } else if locData != nil {
                
                HStack {
                    Image(systemName: codeToIconIdentifier(code: locData!.current?.condition.code ?? 0))
                    Spacer()
                    Text(String(format: "%.0f°", locData?.current?.temp_c ?? ""))
                }
                
            } else {
                ProgressView()
                Text("Retreiving Data")
            }
            
        }
        .onAppear {
            
            Functions.functions(region: "europe-west3")
                .httpsCallable("getLocation")
                .call(["location": data.name]) { (result, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let resData = result?.data as? [String: Any] {
                        
                        
                        if let condRes = resData["current"] as? [String: Any] {
                            
                            var tempC: Double = 0.0
                            var conditionCode = 0
                            var conditionText = ""
                            
                            if let tempCRes = condRes["temp_c"] as? Double {
                                tempC = tempCRes
                            }
                            if let conditionRes = condRes["condition"] as? [String: Any] {
                                if let condResText = conditionRes["text"] as? String {
                                    conditionText = condResText
                                }
                                
                                if let condResCode = conditionRes["code"] as? Int {
                                    conditionCode = condResCode
                                }
                            }
                            
                            locData = WeatherDataCity(current: WeatherDataCurrent(temp_c: tempC, condition: WeatherDataCondition(text: conditionText, code: conditionCode), wind_kph: 0.0, wind_degree: 1, vis_km: 0.0, uv: 0.0, precip_mm: 0.0))
                        }
                    }
                    
                }
            
        }
        
    }
}
