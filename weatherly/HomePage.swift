//
//  HomePage.swift
//  weatherly
//
//  Created by David Neidhart on 05.10.22.
//

import SwiftUI
import FirebaseFunctions
import FirebaseAuth

struct HomeView: View {
    
    @State var favorites: [City] = []
    
    @State var name = "David"
    
    @State var currentLocation: City?
    
    @StateObject var locationManager = LocationManager()
        
    var userLatitude: Double? {
        return locationManager.lastLocation?.coordinate.latitude
    }
    
    var userLongitude: Double? {
        return locationManager.lastLocation?.coordinate.longitude
    }
    
    var body: some View {
        
        NavigationView {
            //ScrollView {
              //  ForEach(favorites) {
                //    CityTile(data: $0)
              //  }
            //}
            
            List {
                if let currentLocation = currentLocation {
                    Section {
                        NavigationLink {
                            CityView(data: currentLocation)
                        } label: {
                            FavoriteView(data: currentLocation, isCurrentLocation: true)
                        }
                    } header: {
                        HStack {
                            Image(systemName: "location")
                            Text("Current location")
                        }
                    }
                }
                
                if favorites.count == 0 {
                    Section {
                        VStack {
                            HStack {
                                Text("You don't have any favorites yet.")
                                    .font(.title3)
                                    .padding()
                            }
                        }
                    }
                } else {
                    ForEach(favorites) { favorite in
                        NavigationLink {
                            CityView(data: favorite)
                        } label: {
                            FavoriteView(data: favorite)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                Functions.functions(region: "europe-west3")
                                    .httpsCallable("removeFromFavorites")
                                    .call(["city": favorite.name, "country": favorite.country, "region": favorite.region]) { (result, error) in
                                        
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        
                                        let firstIndex = favorites.firstIndex {
                                            return $0.name == favorite.name && $0.region == favorite.region && $0.country == favorite.country
                                        }
                                        
                                        if firstIndex == nil {
                                            return
                                        }
                                        
                                        favorites.remove(at: firstIndex!)
                                    }
                            } label: {
                                Image(systemName: "star.slash.fill")
                            }
                        }
                    }
                    .onMove { (from, to) in
                        favorites.move(fromOffsets: from, toOffset: to)
                        
                        let data = [
                            "favorites": favorites.map { city in
                                return [
                                    "city": city.name,
                                    "region": city.region,
                                    "country": city.country
                                ]
                            }
                        ]
                        
                        Functions.functions(region: "europe-west3")
                            .httpsCallable("rearrangeFavorites")
                            .call(data) { (result, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                                
                            }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if favorites.count > 0 {
                    EditButton()
                }
            }
        }
        .onAppear {
            getCurrentLocation()
            getFavorites()
        }
        .onChange(of: userLatitude) { (newValue) in
            getCurrentLocation()
        }
        .onChange(of: userLongitude) { (newValue) in
            getCurrentLocation()
        }
    }
    
    func getCurrentLocation() {
        
        print(userLatitude, userLongitude)
        
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
                    
                    currentLocation = City(name: name, country: country, region: region)
                }
                
            }
        
    }
    
    func getFavorites() {
        
        let uid = Auth.auth().currentUser?.uid
        
        if uid == nil {
            favorites = []
            return
        }
        
        let functions = Functions.functions(region: "europe-west3")
        
        functions.httpsCallable("getFavorites")
            .call { (result, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                if let favoritesArray = result?.data as? [[String: Any]] {
                    
                    favorites = []
                    
                    for i in 0..<favoritesArray.count {
                        
                        let favorite = favoritesArray[i]
                        
                        var name = ""
                        var region = ""
                        var country = ""
                        
                        if let cityName = favorite["name"] as? String {
                            name = cityName
                        }
                        
                        if let cityRegion = favorite["region"] as? String {
                            region = cityRegion
                        }
                        
                        if let cityCountry = favorite["country"] as? String {
                            country = cityCountry
                        }
                        
                        favorites.append(City(name: name, country: country, region: region))
                    }
                    
                }
            }
    }
}

struct FavoriteEntry: Identifiable {
    let id: String
    var data: [String: Any]
}
