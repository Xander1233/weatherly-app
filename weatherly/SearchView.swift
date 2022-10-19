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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cityData) { element in
                    NavigationLink {
                        CityView(data: element)
                    } label: {
                        Text("\(element.name), \(element.region), \(element.country)")
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
    }
    
    func getData() {
        
        if searchQuery.isEmpty || searchQuery.count < 2 {
            cityData = []
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
