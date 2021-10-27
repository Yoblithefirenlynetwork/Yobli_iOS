//
//  PaymentHandler.swift
//  Yobli
//
//  Created by Brounie on 08/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit

class PaymentHandler{
    
    func returnConektaKey() -> String{
        
        let conektaKey = "key_PLth86XRJbhayYWqd7z3urw"  //THIS IS THE FOR DEVELOPMENT
        //let conektaKey =  "key_br8fxzNHvyKitcMd4qqrDBw" //THIS IS THE FOR PRODUCTION
            
        
        // //THIS IS FOR PUBLISHMENT
        
        return conektaKey

    }
    
    //Esto va al momento de registrar el usuario
    func customerId(){
        
        guard let user = PFUser.current(), let email = user.email, let name = user["name"] as? String else{
            
            print("This should happen")
            
            return
            
        }
            
        let params = NSMutableDictionary()
        params.setObject(email, forKey: "email" as NSCopying)
        params.setObject(name, forKey: "name" as NSCopying)
            
        PFCloud.callFunction(inBackground: "createConektaCustomer", withParameters: params as [NSObject : AnyObject],block:{ (result, error)  -> Void in
            
            if let error = error{
                
                print("ERROR customerI")
                print("\(error)")
                
            }else if let results = result{
                
                let res = results as? AnyObject
                let id = res?.object(forKey: "id") as? String
                print("Res: \(res)")
                print("Results: \(results)")
                print("Este es el id: \(id)")
                
                guard let createdId = id else{
                    print("It should not be null")
                    return
                }
                
                //Set id for Conekta
                
                user["customer_id"] = createdId
                    
                user.saveInBackground(block: { (success, error) in
                
                    if let error = error{
                        
                        print("Something went wrong: \(error)")
                        
                    }else{
                        
                        print("Id : " + createdId)
                        
                    }
                    
                })
                    
            }
            
        })
        
        
    }
    
}

