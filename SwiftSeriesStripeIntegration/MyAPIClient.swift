//
//  MyAPIClient.swift
//  SwiftSeriesStripeIntegration
//
//  Created by Chandra Bhushan on 28/12/2019.
//  Copyright © 2019 Chandra Bhushan. All rights reserved.
//

import Foundation
import Stripe
import  Alamofire

class MyAPIClient: NSObject,STPCustomerEphemeralKeyProvider {
    
    enum APIError: Error {
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }
    
    static let sharedClient = MyAPIClient()
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let parameters = ["api_version":apiVersion, "customer_id" : "29"]
        
        AF.request(URL(string: "https://tsprojects.net/demo/dev/supplyandapply/index.php?route=openapi/checkout/getStripeEphemeral")!, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:]).responseJSON { (apiResponse) in
            let data = apiResponse.data
            guard let json = ((try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]) as [String : Any]??) else {
                completion(nil, apiResponse.error)
                return
            }
            completion(json, nil)
            print(json)
            
        }        
    }
    
    
    func createPaymentIntent(customerId: String, amount: String, paymentMethodId: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        
        let parameters = ["customer_id" : customerId,"amount": amount,"payment_method_id" : paymentMethodId]
        
        AF.request(URL(string: "https://tsprojects.net/demo/dev/supplyandapply/index.php?route=openapi/checkout/paymentInt")!, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:]).responseJSON { (apiResponse) in
            
            let data = apiResponse.data
            guard let json = ((try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]) as [String : Any]??),
                let secret = json?["clientSecret"] as? String else {
                    //               completion(nil, apiResponse.error)
                    return
            }
            print(secret)
            completion(.success(secret))
        }
    }
}

