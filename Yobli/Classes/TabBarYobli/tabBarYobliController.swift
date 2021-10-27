//
//  tabBarYobliController.swift
//  Yobli
//
//  Created by Brounie on 04/02/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase

class tabBarYobliController: UITabBarController, UITabBarControllerDelegate{
    
    private var conversations = [Conversation]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        delegate = self
        
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
                    self?.tabBar.items?[3].badgeValue = nil
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    
                    if let counter = self?.conversations.count, (counter > 0){
                        
                        self?.tabBar.items?[3].badgeValue = "\(counter)"
                        self?.tabBar.items?[3].image = UIImage(named: "iconMessagesBlack")
                        
                    }
                    
                    
                }
                
            case .failure(let error):
                self?.tabBar.items?[3].badgeValue = nil
                print("Not conversations get \(error)")
            }
            
            
        })
        
        
        
    }
    
}
