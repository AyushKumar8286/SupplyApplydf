//
//  ViewController.swift
//  SwiftSeriesStripeIntegration
//
//  Created by Chandra Bhushan on 28/12/2019.
//  Copyright © 2019 Chandra Bhushan. All rights reserved.
//



import UIKit
import Stripe
class ViewController: UIViewController {

    var customerContext : STPCustomerContext?
    var paymentContext : STPPaymentContext?
    var isSetShipping = true
    var isButtonTapped = false
    
    @IBOutlet weak var btnSelectPaymentOption: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let config = STPPaymentConfiguration.shared()
        config.requiredShippingAddressFields = nil
        config.companyName = "Testing XYZ"
        customerContext = STPCustomerContext(keyProvider: MyAPIClient())
        paymentContext =  STPPaymentContext(customerContext: customerContext!, configuration: config, theme: .default())

        self.paymentContext?.delegate = self
        self.paymentContext?.hostViewController = self
        self.paymentContext?.paymentAmount = 5000
        paymentContext?.defaultPaymentMethod = nil
        
    }

    deinit {
        customerContext = nil
        paymentContext = nil
    }
    
    @IBAction func clickedSelectPaymentOption(_ sender: Any) {
        self.paymentContext?.pushPaymentOptionsViewController()
    }
    
    
    @IBAction func clickedBtnPayNow(_ sender: Any) {

         self.paymentContext?.requestPayment()
        
    }
    
}

extension ViewController: STPPaymentContextDelegate {
    
       func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
       
        if let paymentOption = paymentContext.selectedPaymentOption {
            btnSelectPaymentOption.setTitle(paymentOption.label, for: .normal)
        } else {
            btnSelectPaymentOption.setTitle("Select Payment", for: .normal)
        }
        
        
//        if paymentContext.selectedPaymentOption != nil  {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//             self.paymentContext?.requestPayment()
//            }
//        }
    }
    
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
       MyAPIClient.sharedClient.createPaymentIntent(customerId: "29", amount: "500", paymentMethodId: paymentResult.paymentMethod?.stripeId ?? "", completion: { (response) in
            switch response {
            case .success(let clientSecret):
                // Assemble the PaymentIntent parameters
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
                paymentIntentParams.paymentMethodParams = paymentResult.paymentMethodParams
                
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    
                    switch status {
                    case .succeeded:
                        // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error) // Report error
                    case .canceled:
                        completion(.userCancellation, nil) // Customer cancelled
                    @unknown default:
                        completion(.error, nil)
                    }
                }
            case .failure(let error):
                completion(.error, error) // Report error from your API
                break
            }
        })        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        customerContext?.clearCache()
        customerContext = nil
        self.paymentContext = nil
        switch status {
        case .error:
            print("error")
        case .success:
            print("success")
            if #available(iOS 13.0, *) {
                self.navigationController?.popViewController(animated: true)
            } else {
                // Fallback on earlier versions
            }
        case .userCancellation:
        return // Do nothing
        default:
            "default"
        }
    }
}
