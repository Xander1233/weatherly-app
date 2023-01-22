//
//  PurchaseScreen.swift
//  weatherly
//
//  Created by David Neidhart on 16.01.23.
//

import SwiftUI
import StoreKit

struct PurchaseScreen: View {
    
    @State private var text = ""
    
    @State private var products: [SKProduct] = []
    
    var body: some View {
        
        VStack {
            Text(text)
            
            ForEach(products, id: \.self) { (product) in
                
                Button {
                    if !purchase(product) {
                        text = "This device is not capable of processing In-App Purchases."
                    }
                } label: {
                    Text("Buy \(product.localizedTitle) for \(IAPManager.shared.formatPrice(for: product) ?? "N/A€")")
                }
                
            }
        }
        .onAppear {
            
            IAPManager.shared.getProducts { result in
                
                switch result {
                case .success(let success):
                    products = success
                    print(success.map {
                        return $0.localizedTitle
                    }.joined())
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    func purchase(_ product: SKProduct) -> Bool {
        
        if !IAPManager.shared.canMakePayments() {
            return false
        }
        
        IAPManager.shared.buy(product: product) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                text = "Successfully purchased \(product.localizedTitle)"
            }
        }
        
        return true
    }
    
}
