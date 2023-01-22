//
//  PaymentManager.swift
//  weatherly
//
//  Created by David Neidhart on 18.01.23.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    static let shared = IAPManager()

    var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    
    enum IAPManagerError: Error {
        case NoProductIDsFound
        case NoProductsFound
        case PaymentWasCancelled
        case ProductRequestFailed
    }
    
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAPIDs", withExtension: "plist") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            
            let productIds = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            
            return productIds
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        
        onReceiveProductsHandler = productsReceiveHandler
        
        guard let productIds = getProductIDs() else {
            productsReceiveHandler(.failure(.NoProductIDsFound))
            return
        }
        
        print(productIds.joined())
        
        let request = SKProductsRequest(productIdentifiers: Set(productIds))
        
        request.delegate = self
        
        request.start()
    }
    
    func formatPrice(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
     
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
}

extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .NoProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .NoProductsFound: return "No In-App Purchases were found."
        case .PaymentWasCancelled: return "In-App Purchase process was cancelled."
        case .ProductRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        
        if products.count < 1 {
            onReceiveProductsHandler?(.failure(.NoProductsFound))
            return
        }
        
        onReceiveProductsHandler?(.success(products))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.ProductRequestFailed))
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                break
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.PaymentWasCancelled))
                    }
                    
                    print("IAPError: ", error.localizedDescription)
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
    
}
