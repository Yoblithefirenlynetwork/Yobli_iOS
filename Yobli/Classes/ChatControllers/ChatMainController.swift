//
//  ChatMainController.swift
//  Yobli
//
//  Created by Brounie on 04/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import MessageKit
import Firebase
import FirebaseDatabase
import Parse

// MARK: GENERAL STRUCTURES

struct Message: MessageType{
    
    public var sender: SenderType
    
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind
    
}

extension MessageKind{
    
    var messageKindString: String{
        
        switch self{
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
        
    }
    
}

struct Sender: SenderType{
    
    public var photoURL: String
    
    public var senderId: String
    
    public var displayName: String
    
}

struct YobliUser{
    
    let name : String
    let id : String
    
    var editName: String{
        
        var replace = name.replacingOccurrences(of: ".", with: "_")
        replace = replace.replacingOccurrences(of: "@", with: "_")
        
        return replace
        
    }
    
    var profilePictureName: String{
        
        return "\(id)_profile_picture.jpeg"
        
    }
    
}

struct Conversation{
    
    let id: String
    
    let otherUserId: String
    
    let latestMessage: LatestMessage
    
}

struct LatestMessage{
    
    let date: String
    let text: String
    let isRead: Bool
    
}


// MARK: MAIN CLASS

class ChatMainController{
    
    // MARK: VARs/LETs
    
    private var usersContacts = [[String: String]]()
    public var results = [[String: String]]()
    public var completion: (([String : String]) -> (Void))?
    private var hasFetched = false
    private var userContact = [String: String]()
    public var completionId: ((String?) -> (Void))?
    public var completionId2: ((String?) -> (Void))?
    
    //MARK: OTHER FUNCTIONS
    
    func searchUser(id: String){
        //check if the array has a firebase result,0
        
        if hasFetched{
            //if it does then you can filter
            filterUsers(id: id)
        }else{
            //if not, fetch then filter
            DBFirebaseController.shared.getAllUsers(completion: { [weak self] results in
                
                switch results{
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.usersContacts = usersCollection
                    self?.filterUsers(id: id)
                case .failure(let error):
                     print("Failed to get users: \(error)")
                }
                
            })
            
        }
        
    }
    
    func filterUsers(id: String){
        
        guard hasFetched else{
            return
        }
        
        let results: [[String: String]] = self.usersContacts.filter({
            guard let mainId = $0["id"] else{
                return false
            }
            
            return mainId == id
        })
        
        self.results = results
        self.fillCompletion()
        
    }
    
    func fillCompletion(){
        
        if(self.results.count > 0){
            self.completion?(self.results[0])
        }else{
            print("Algo salió mal")
        }
        
    }
    
    func searchConversationIdInSender(receiverId: String, senderId: String){
        
        DBFirebaseController.shared.getIfConversation(receiverId: receiverId, senderId: senderId, completion: { [weak self] result in
            
            switch result{
            case .success(let conversationId):
                
                self?.completionId?(conversationId)
                
            case .failure(let _):
                self?.completionId?(nil)
            }
            
        })
        
    }
    
    func searchConversationIdInReceiver(receiverId: String, senderId: String){
        
        DBFirebaseController.shared.getIfConversation2(receiverId: receiverId, senderId: senderId, completion: { [weak self] result in
            
            switch result{
            case .success(let conversationId):
                
                self?.completionId2?(conversationId)
                
            case .failure(let _):
                self?.completionId2?(nil)
            }
            
        })
        
    }
    
    func safeNameUser(email: String) -> String{
        var replace = email.replacingOccurrences(of: ".", with: "-")
        replace = replace.replacingOccurrences(of: "@", with: "-")
            
        return replace
    }
    
    func safeNameUser(name: String) -> String{
        var replace = name.replacingOccurrences(of: ".", with: "_")
        replace = replace.replacingOccurrences(of: "@", with: "_")
            
        return replace
    }
    
}
