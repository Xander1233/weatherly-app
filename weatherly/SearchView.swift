//
//  SearchView.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI

struct SearchView: View {
    
    @State var searchQuery = ""
    
    @State var data: [City] = [
        
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(data.filter {
                    searchQuery.isEmpty || $0.name.contains(searchQuery)
                }) { element in
                    CityTile(cityName: element.name)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .searchable(text: $searchQuery, prompt: "Search for a city")
        }
    }
}

struct City: Identifiable {
    let id: UUID = UUID()
    let name: String
    let country: String
    let temp_c: Float
}

enum Weather {
    case clear
    case rain
    case thunder
    case fog
    case cloudy
    case snow
}
