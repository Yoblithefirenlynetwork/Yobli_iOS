//
//  signInFinalDecision.swift
//  Yobli
//
//  Created by Brounie on 11/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase
import FirebaseAuth
import MBProgressHUD

class signInFinalDecision: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var beYoberButton: UIButton!
    @IBOutlet weak var beYoberUser: UIButton!
    
    //MARK: MAIN FUNCTION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beYoberButton.roundCustomButton(divider: 8)
        beYoberUser.roundCustomButton(divider: 8)
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func beYober(_ sender: UIButton) {
        
        self.whoYouWannaBe(decision: true)
        
    }
    
    @IBAction func beUser(_ sender: UIButton) {
        
        self.whoYouWannaBe(decision: false)
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    func whoYouWannaBe(decision: Bool){
        
        //AFTER Making the decision of what type of profile you will be, the user first will create its ConektaCustomer
        
        guard let user = PFUser.current(), let email = user.email, let name = user["name"] as? String else{
            
            print("This shouldn't happen")
            self.sendAlert()
            
            return
            
        }
        
        self.showHUD(progressLabel: "Realizando los últimos ajustes...")
            
        let params = NSMutableDictionary()
        params.setObject(email, forKey: "email" as NSCopying)
        params.setObject(name, forKey: "name" as NSCopying)
        
        PFCloud.callFunction(inBackground: "createConektaCustomer", withParameters: params as [NSObject : AnyObject],block:{ (result, error)  -> Void in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                self.sendErrorFromConekta(error: error)
                
            }else if let results = result{
                
                let res = results as? AnyObject
                let id = res?.object(forKey: "id") as? String
                print("Res: \(res)")
                print("Results: \(results)")
                print("Este es el id: \(id)")
                
                guard let createdId = id else{
                    self.dismissHUD(isAnimated: true)
                    print("It should not be null")
                    return
                }
                
                //Set id for Conekta
                
                user["customer_id"] = createdId
                
                //Set decision that will determine how it will open sesion
                
                user["yoberMain"] = decision
                user["yoberExclusive"] = decision
                user["yober"] = decision
                
                //This one is optional
                
                if let installation = PFInstallation.current() {
                    
                    if let idInstallation = installation.objectId {
                        
                        if( idInstallation != user["installationString"] as? String ){
                            
                            user.setObject(installation, forKey: "installation")
                            user.setObject(idInstallation, forKey: "installationString")
                            
                        }
                        
                    }
                    
                }
                
                //Now you will save the necessary information in the user, and go to one of the two open sessions
                
                user.saveInBackground { (result, error) in
                    
                    if let error = error{
                        
                        print("Something went wrong during save")
                        self.dismissHUD(isAnimated: true)
                        self.sendErrorType(error: error)
                        
                    }else{
                        
                        if result == true{
                            
                            self.dismissHUD(isAnimated: true)
                            
                            //Create grade connection to grade user in the future
                            
                            let newGrade = PFObject(className: "Grade")
                            
                            newGrade["grade"] = 0.0
                            newGrade["numberOfGrades"] = 0
                            newGrade["yoberId"] = user.objectId
                            newGrade["yober"] = user
                            
                            newGrade.saveInBackground()
                            
                            if decision == true {
                                
                                let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as? UITabBarController
                                
                                viewController?.selectedIndex = 4
                                
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                
                                appDelegate.window?.rootViewController = viewController
                                
                            }else{
                                
                                let tabBarYobli = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                                            
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            
                                appDelegate.window?.rootViewController = tabBarYobli
                                
                            }
                            
                        }else{
                            
                            self.dismissHUD(isAnimated: true)
                            
                            let alert = UIAlertController(title: "Error", message: "El guardado no se ha podido realizar", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                                
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
                    
            }else{
                
                self.dismissHUD(isAnimated: true)
                print("No other option work, something is wrong")
                
            }
            
        })
        
    }
    
}

extension signInFinalDecision{
    
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
}
