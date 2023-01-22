//
//  SearchView.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseFunctions

struct SearchView: View {
    
    @State var searchQuery = ""
    
    @State var cityData: [City] = []
    
    @State var trendings: [City] = []
    
    @State var updateData = true
    
    @State var selected: City? = nil
    
    var body: some View {
        NavigationView {
            List {
                
                if searchQuery.count < 2 && trendings.count > 0 {
                    Text("Trending")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
                
                ForEach(searchQuery.count < 2 ? trendings : cityData) { element in
                    NavigationLink {
                        CityView(data: element) {
                            selected = element
                            searchQuery = "\(searchQuery.count < 2 ? "" : element.name)"
                        }
                    } label: {
                        if searchQuery.count < 2 {
                            FavoriteView(data: element)
                        } else {
                            Text("\(element.name), \(element.region), \(element.country)")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, prompt: "Search for a city")
            .onChange(of: searchQuery) { (newQ) in
                getData()
            }
        }
        .onAppear {
            Functions.functions(region: "europe-west3").httpsCallable("getFeaturedLocations")
                .call { res, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let resData = res?.data as? [String: [Any]], let locations = resData["locations"] as? [[String: String]] {
                        
                        trendings = []
                        
                        for i in 0..<locations.count {
                            
                            let entry = locations[i]
                            
                            var name: String = ""
                            var region: String = ""
                            var country: String = ""
                            
                            if let cityName = entry["city"] {
                                name = cityName
                            }
                            
                            if let cityRegion = entry["region"] {
                                region = cityRegion
                            }
                            
                            if let cityCountry = entry["country"] {
                                country = cityCountry
                            }
                            
                            trendings.append(City(name: name, country: country, region: region))
                        }
                        
                    }
                    
                }
        }
    }
    
    func getData() {
        
        if (selected != nil && selected?.name == searchQuery) || searchQuery.isEmpty || searchQuery.count < 2 {
            return
        }
        
        Functions.functions(region: "europe-west3").httpsCallable("autoCompleteLocation")
            .call(["query": searchQuery]) { (result, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let resData = result?.data as? [String: [Any]], let data = resData["data"] as? [[String: Any]] {
                    
                    cityData = []
                    
                    for i in 0..<data.count {
                        
                        let entry = data[i]
                        
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
                        
                        
                        cityData.append(City(name: name, country: country, region: region))
                        
                    }
                    
                }
                
            }
        
        return
    }
}

struct City: Identifiable {
    let id: UUID = UUID()
    let name: String
    let country: String
    let region: String
}

enum Weather {
    case clear
    case rain
    case thunder
    case fog
    case cloudy
    case snow
}
