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
    
    var body: some View {
        
        NavigationView {
            //ScrollView {
              //  ForEach(favorites) {
                //    CityTile(data: $0)
              //  }
            //}
            
            if favorites.count == 0 {
                VStack {
                    Image(systemName: "star")
                        .font(.system(size: 70))
                        .opacity(0.4)
                        .foregroundColor(.accentColor)
                    HStack {
                        Text("You don't have any favorites yet.")
                            .font(.title3)
                            .padding()
                    }
                }
            } else {
                List {
                    ForEach(favorites) { favorite in
                        NavigationLink {
                            CityView(data: favorite)
                        } label: {
                            FavoriteView(data: favorite)
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
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    EditButton()
                }
            }
        }
        .onAppear {
            getFavorites()
        }
    }
    
    func getFavorites() {
        
        let uid = Auth.auth().currentUser?.uid
        
        if uid == nil {
            favorites = []
            return
        }
        
        Functions.functions(region: "europe-west3").httpsCallable("getFavorites")
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
