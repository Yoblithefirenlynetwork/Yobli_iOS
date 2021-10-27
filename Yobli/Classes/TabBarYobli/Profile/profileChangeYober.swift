//
//  profileChangeYober.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class profileChangeYober: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
        self.viewChange()
        
    }
    
    func viewChange(){
        
        let user = PFUser.current()!
        
        if let newState = user["yober"] as? Bool{
            
            if(newState == false){
                
                let newGrade = PFObject(className: "Grade")
                
                user["yober"] = true
                
                newGrade["grade"] = 0.0
                newGrade["numberOfGrades"] = 0
                newGrade["yoberId"] = user.objectId
                newGrade["yober"] = user
                
                user.saveInBackground { (success: Bool?, error: Error?) in
                    
                    if let error = error {
                        self.sendErrorTypeAndDismiss(error: error)
                    } else if success != nil {
                        
                        newGrade.saveInBackground { (success: Bool?, error: Error?) in
                            
                            if let error = error {
                                self.sendErrorTypeAndDismiss(error: error)
                            } else if success != nil {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                                    
                                    let tabBarYober = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    
                                    appDelegate.window?.rootViewController = tabBarYober
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }else{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    
                    let tabBarYober = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = tabBarYober
                    
                }
                
            }
            
        }
        
    }
    
}
