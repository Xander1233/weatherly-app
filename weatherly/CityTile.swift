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

struct CityTileTest: View {
    
    @State var cityName: String
    
    var body: some View {
        Text(cityName)
            .onAppear {
                print(cityName)
            }
    }
}

struct CityTile: View {

    @State var cityName: String
    
    @State var data: City? = nil
    
    var body: some View {
        HStack {
            if data == nil {
                ProgressView()
            } else {
                NavigationLink {
                    CityView(data: data!)
                } label: {
                    HStack {
                        VStack {
                            Text(data!.name)
                                .font(.title2)
                            Text(data!.country)
                                .font(.footnote)
                        }
                        Spacer()
                        VStack {
                            Text("C")
                        }
                    }
                }
                .padding()
                .background(.thickMaterial)
                .cornerRadius(10)
                .padding()
            }
        }
        .onAppear {
            
            let data: [String: String] = [ "location": cityName ]
            
            /*Functions.functions(region: "europe-west3").httpsCallable("getLocation")
                .call(data) { (result, error) in
                    
                    print(error, result)
                    
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                    
                    var city: String = ""
                    var country: String = ""
                    var temp_c: Float = 0.0
                    
                    if let data = result?.data as? [String: Any], let location = data["location"] as? [String: Any]  {
                        
                        if let cityString = location["name"] as? String {
                            city = cityString
                        }
                        
                        if let countryName = location["country"] as? String {
                            country = countryName
                        }
                        
                    }
                    
                    if let data = result?.data as? [String: Any], let current = data["current"] as? [String: Any] {
                        
                        if let tempC = current["temp_c"] as? Float {
                            temp_c = tempC
                        }
                        
                    }
                    
                    self.data = City(name: city, country: country, temp_c: temp_c)
                }*/
        }
    }
}

struct CityView: View {
    
    @State var data: City
    
    var body: some View {
        
        VStack {
            Text(data.name)
                .font(.title)
            Text(data.country)
                .font(.caption)
        }
        .navigationTitle(data.name)
        
    }
}

func addToFavorite(city: String) {
    
    let uid = Auth.auth().currentUser?.uid
    if uid == nil {
        return
    }
    
    Firestore.firestore().collection("users").document(uid!).collection("favorites").addDocument(data: ["city": city])
    
}
