//
//  tabBarYoberController.swift
//  Yobli
//
//  Created by Brounie on 05/02/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase

class tabBarYoberController: UITabBarController{
    
    @IBOutlet weak var createdTabBar: UITabBar!
    
    private var conversations = [Conversation]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getConversations()
        
        
    }
    
    //MARK: RETRIEVE FUNCTIONS
    
    func getConversations(){
        
        guard let objectId = PFUser.current()!.objectId else{
            self.sendAlert()
            return
        }
        
        DBFirebaseController.shared.getNotReadConversations(id: objectId, completion: { [weak self] result in
            
            switch result{
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    self?.createdTabBar.items?[3].badgeValue = nil
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    
                    if let counter = self?.conversations.count, (counter > 0){
                        
                        self?.createdTabBar.items?[3].badgeValue = "\(counter)"
                        self?.createdTabBar.items?[3].image = UIImage(named: "iconMessagesBlack")
                        
                    }
                    
                    
                }
                
            case .failure(let error):
                self?.createdTabBar.items?[3].badgeValue = nil
                print("Not conversations get \(error)")
            }
            
            
        })
        
        
        
    }
    
    /*
    
    func getAlerts(){
        
        guard let current = PFUser.current() else{
            self.sendAlert()
            return
        }
        
        let queryAlerts = PFQuery(className: "Alert")
        queryAlerts.whereKey("receiver", equalTo: current)
        
        queryAlerts.countObjectsInBackground { (result, error) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else{
                
                if result > 0{
                            
                    self.createdTabBar.items?[2].badgeValue = "\(result)"
                            
                }else{
                        
                    self.createdTabBar.items?[2].badgeValue = nil
                        
                }
                
            }
            
        }
        
    }
    
    */
    
}
