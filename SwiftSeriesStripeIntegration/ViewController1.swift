//
//  ViewController1.swift
//  Alamofire
//
//  Created by Mac3 on 14/05/20.
//

import UIKit
import Stripe

@available(iOS 13.0, *)
class ViewController1: UIViewController {

    var customerContext : STPCustomerContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerContext = STPCustomerContext(keyProvider: MyAPIClient())
        // Do any additional setup after loading the view.
    }
    

    @IBAction func clickedBtnCLicked1(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(identifier: "VC") as! ViewController
        vc.customerContext =  customerContext
        
        navigationController?.pushViewController(vc, animated: false)
    }
}
