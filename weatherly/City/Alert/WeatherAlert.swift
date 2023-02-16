//
//  Alert.swift
//  weatherly
//
//  Created by David Neidhart on 30.01.23.
//

import SwiftUI

struct WeatherAlert: View {
    
    @State var data: WeatherDataAlerts
    
    @State var showBigAlert: Bool = false
    
    var body: some View {
        
        let date = getDateObject(dateString: data.effective)
        let expiringDate = getDateObject(dateString: data.expires)
        
        VStack {
            HStack {
                Text(data.event)
                    .font(.system(size: 25))
                Spacer()
            }
            .padding(.leading)
            HStack {
                Text(data.severity)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.leading)
            HStack {
                Text("Issued on \(formatDate(date: date))")
                Spacer()
            }
            .padding(.leading)
            .padding(.top, 5)
            HStack {
                Text("Expires on \(formatDate(date: expiringDate))")
                Spacer()
            }
            .padding(.leading)
        }
        .padding()
        .cornerRadius(5.0)
        .background(.regularMaterial)
        .overlay(RoundedRectangle(cornerRadius: 5.0).stroke(Color.red, lineWidth: 3.5))
        .padding(.all)
        .onTapGesture {
            showBigAlert = true
        }
        .popover(isPresented: $showBigAlert) {
            NavigationView {
                VStack {
                    Text(data.headline)
                        .padding()
                        .font(.title2)
                    
                    Text(data.instruction)
                        .padding()
                    
                    Text(data.note)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Alert")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }
    
    func getDateObject(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateString)!
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}


struct WeatherDataAlerts {
    let headline: String
    let severity: String
    let areas: String
    let event: String
    let note: String
    let effective: String
    let expires: String
    let description: String
    let instruction: String
}
