//
//  profileYoberChangeUser.swift
//  Yobli
//
//  Created by Brounie on 26/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class profileYoberChangeUser: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewChange()
        
    }
    
    func viewChange(){
        
        let user = PFUser.current()!
        
        if let newState = user["yoberExclusive"] as? Bool{
            
            if(newState == true){
            
                user["yoberExclusive"] = false
                
                user.saveInBackground { (success: Bool?, error: Error?) in
                    
                    if let error = error {
                        self.sendErrorTypeAndDismiss(error: error)
                    } else if success != nil {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                            
                            let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                            
                            goTo.selectedIndex = 4
                            
                            let nav = UINavigationController(rootViewController: goTo )
                            nav.isNavigationBarHidden = true
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            
                            appDelegate.window?.rootViewController = nav
                            
                        }
                        
                    }
                    
                }
                
            }else{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    
                    let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                    
                    goTo.selectedIndex = 4
                    
                    let nav = UINavigationController(rootViewController: goTo )
                    nav.isNavigationBarHidden = true
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = nav
                    
                }
                
            }
            
        }
        
    }
    
}
