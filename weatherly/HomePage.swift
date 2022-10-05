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
    
    @State var favorites: [String] = []
    
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
                ScrollView {
                    ForEach($favorites, id: \.self) { favorite in
                        CityTile(cityName: favorite.wrappedValue)
                    }
                }
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
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
                
                if let data = result?.data as? String {
                    print(data)
                    favorites = data.components(separatedBy: ", ")
                }
                
            }
    }
}

struct FavoriteEntry: Identifiable {
    let id: String
    var data: [String: Any]
}
