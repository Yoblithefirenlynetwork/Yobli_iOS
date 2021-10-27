//
//  DBFirebaseController.swift
//  Yobli
//
//  Created by Brounie on 04/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Parse

class DBFirebaseController{
    
    static let shared = DBFirebaseController()
    
    private let database = Database.database().reference()
    
    //MARK: USER INSERT FUNC
    
    public func insertUser(user: YobliUser, completion: @escaping (Bool) -> Void ){
        
        database.child(user.id).setValue([
            "name": user.editName
        
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write in the database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    
                    let newUser = ["name": user.editName, "id": user.id]
                    
                    usersCollection.append(newUser)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                    
                }else{
                    //create the array
                    
                    let newUsersCollection: [[String: String]] = [
                    
                        ["name": user.editName, "id": user.id]
                        
                    ]
                    
                    self.database.child("users").setValue(newUsersCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                    
                }
                
            })
            
        })
        
    }
    
    /* Desing
     
     users[
     
        [
            name: ""
            email: ""
     
        ],[
            name: ""
            email: ""

        ]
     
     ]
     
     */
    
    //MARK: USER RETRIEVE FUNC
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
     
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(customErrors.failedToFetch))
                return
            }
            
            completion(.success(value))
            
        })
    
    }
    
    //MARK: CHANGEUSERNAME
    
    public func changeUserName(oldUserName : String, newName: String, userEmail: String){
        
        
        
    }
    
    //MARK: CUSTOM ERRORS
    
    public enum customErrors: Error{
        case failedToFetch
        case failedToGet
        case failedToSet
    }
    
}

//MARK: CONVERSATION FUNCTIONS

extension DBFirebaseController{
    
    /*
     
     Conversation
     
     
     conversations [
        [
            "conversation_id": "dsfdsfdsfdsf"
            "other_user_id"
            "latest_message"{
         
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
         
            }
        ],
     
     
     ]
     
     "dsfdsfdsfdsf"{
        "messages":[
            {
                "id": String,
                "type": text, photo, video,
                "content": String,
                "date": Date(),
                "sender_id": String,
                "isRead": true/false
            }
        ]
     }
     
     
     */
    
    //MARK: CREATE CONVERSATION
    
    public func createNewConversation(otherUserId: String, otherUserName: String, firstMessage: Message, actualUserId: String, actualUserName: String, completion: @escaping (Bool, String?) -> Void){
        
        let ref = database.child("\(actualUserId)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else{
                
                completion(false, nil)
                print("user_not_found, impossible!")
                return
                
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = messagePrivate.dateFormatter.string(from: messageDate)//messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
            
            var message = ""
            
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String : Any] = [
                "id": conversationId,
                "other_user_id": otherUserId,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let receiver_newConversationData: [String : Any] = [
                "id": conversationId,
                "other_user_id": actualUserId,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            //UPDATE RECEIVER CONVERSATIONS
            
            self?.database.child("\(otherUserId)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                
                if var conversations = snapshot.value as? [[String : Any]]{
                    
                    //The receiver has a conversation array
                    
                    conversations.append(receiver_newConversationData)
                    self?.database.child("\(otherUserId)/conversations").setValue(conversations)
                    
                }else{
                    
                    self?.database.child("\(otherUserId)/conversations").setValue([receiver_newConversationData])
                    
                }
                
            })
            //CURRENT USER CONVERSATIONS UPDATE
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                
                //The user has a conversation array
                
                conversations.append(newConversationData)
                
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else{
                        
                        completion(false, nil)
                        return
                        
                    }
                    
                    self?.finishCreatingConversation(conversationId: conversationId, firstMessage: firstMessage, actualUserId: actualUserId, otherUserName: otherUserName, completion: completion)
                    
                })
                
            }else{
                
                userNode["conversations"] = [newConversationData]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else{
                        
                        completion(false, nil)
                        return
                        
                    }
                    
                    self?.finishCreatingConversation(conversationId: conversationId, firstMessage: firstMessage, actualUserId: actualUserId, otherUserName: otherUserName, completion: completion)
                    
                })
                
            }
            
        })
        
    }
    
    //MARK: FINISH CREATE CONVERSATION
    
    private func finishCreatingConversation(conversationId: String, firstMessage: Message, actualUserId: String, otherUserName: String, completion: @escaping(Bool, String?) -> Void ){
        
        let messageDate = firstMessage.sentDate
        let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
        
        var message = ""
        
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let collectionMessage: [String : Any] = [
        
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_id": actualUserId,
            "is_read": false,
            "name": otherUserName
            
        ]
        
        
        let value: [String: Any] = [
        
            "messages":[
                
                collectionMessage
                
            ]
        
        ]
        
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: {error, _ in
            
            guard error == nil else{
                completion(false, nil)
                return
            }
            
            completion(true, conversationId)
            
            
        })
        
    }
    
    //MARK: FUNC GETALLCONVERSATIONS
    
    public func getAllConversations(id: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        
        database.child("\(id)/conversations").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String : Any]] else{
                
                completion(.failure(customErrors.failedToFetch))
                return
                
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String : Any],
                      let sendDate = latestMessage["date"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    
                    return nil
                    
                }
                
                if let content = latestMessage["message"] as? String{
                    
                    let latestMObject = LatestMessage(date: sendDate, text: content, isRead: isRead)
                    
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                    
                }else if let content = latestMessage["message"] as? NSArray{
                    
                    let latestMObject = LatestMessage(date: sendDate, text: "\(content[1])", isRead: isRead)
                    
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                    
                }else{
                    
                    return nil
                    
                }
                
            })
            
            completion(.success(conversations))
            
            
        })
        
    }
    
    //MARK: FUNC GET NOT READ CONV
    
    public func getNotReadConversations(id: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        
        database.child("\(id)/conversations").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String : Any]] else{
                
                completion(.failure(customErrors.failedToFetch))
                return
                
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String : Any],
                      let sendDate = latestMessage["date"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    
                    return nil
                    
                }
                
                if( isRead == false ){
                
                    if let content = latestMessage["message"] as? String{
                        
                        let latestMObject = LatestMessage(date: sendDate, text: content, isRead: isRead)
                        
                        return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                        
                    }else if let content = latestMessage["message"] as? NSArray{
                        
                        let latestMObject = LatestMessage(date: sendDate, text: "\(content[1])", isRead: isRead)
                        
                        return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                        
                    }else{
                        
                        return nil
                        
                    }
                    
                }else{
                    
                    return nil
                    
                }
                
            })
            
            completion(.success(conversations))
            
            
        })
        
    }
    
    //MARK: FUNC GETCONVERSATION IF TRUE
    
    public func getIfConversation(receiverId: String, senderId: String, completion: @escaping (Result<String?, Error>) -> Void){
        
        database.child("\(senderId)/conversations").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String : Any]] else{
                
                completion(.failure(customErrors.failedToFetch))
                return
                
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String : Any],
                      let sendDate = latestMessage["date"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    
                    return nil
                    
                }
                
                if let content = latestMessage["message"] as? String{
                    
                    let latestMObject = LatestMessage(date: sendDate, text: content, isRead: isRead)
                    
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                    
                }else if let content = latestMessage["message"] as? NSArray{
                    
                    let latestMObject = LatestMessage(date: sendDate, text: "\(content[1])", isRead: isRead)
                    
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                    
                }else{
                    
                    return nil
                    
                }
                
            })
            
            for conversation in conversations{
                
                if(conversation.otherUserId == receiverId){
                    
                    completion(.success(conversation.id))
                    break
                    
                }
                
                completion(.success(nil))
                
            }
            
        })
        
    }
    
    //MARK: FUNC GETCONVERSATION 2 IF TRUE
    
    public func getIfConversation2(receiverId: String, senderId: String, completion: @escaping (Result<String?, Error>) -> Void){
        
        print("receiverId: \(database.child("\(receiverId)/conversations"))")
        
        database.child("\(receiverId)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String : Any]] else{
                print("valueMal: \(snapshot.value.debugDescription)")
                completion(.failure(customErrors.failedToFetch))
                return
            }
            print("value: \(value)")
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserId = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String : Any],
                      let sendDate = latestMessage["date"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                if let content = latestMessage["message"] as? String{
                    let latestMObject = LatestMessage(date: sendDate, text: content, isRead: isRead)
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                }else if let content = latestMessage["message"] as? NSArray{
                    let latestMObject = LatestMessage(date: sendDate, text: "\(content[1])", isRead: isRead)
                    return Conversation(id: conversationId, otherUserId: otherUserId, latestMessage: latestMObject)
                }else{
                    return nil
                }
            })
            print("conversations: \(conversations)")
            for conversation in conversations{
                if(conversation.otherUserId == senderId){
                    completion(.success(conversation.id))
                    break
                }
                completion(.success(nil))
            }
        })
    }
    
    //MARK: DELETE CONVERSATION
    
    func deleteConversation(conversationId: String, userId: String, completion: @escaping (Bool) -> Void ){
        
        let ref = database.child("\(userId)/conversations")
        
        ref.observeSingleEvent(of: .value){ snapshot in
            
            if var conversations = snapshot.value as? [[String : Any]]{
                
                var position = 0
                
                for conversation in conversations{
                    
                    if let id = conversation["id"] as? String, id == conversationId{
                        
                        break
                        
                    }
                    
                    position = position + 1
                    
                }
                
                conversations.remove(at: position)
                
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    completion(true)
                    
                })
            }
            
        }
        
    }
    
    
    // MARK: GET ALL MESSAGES
    
    public func getAllMessagesForConversation(id: String, readerId: String, completion: @escaping (Result<[Message], Error>) -> Void){
    
        self.database.child("\(id)/messages").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String : Any]] else{
                
                completion(.failure(customErrors.failedToFetch))
                return
                
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let senderId = dictionary["sender_id"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = messagePrivate.dateFormatter.date(from: dateString),
                      let type = dictionary["type"] as? String else{
                        
                        return nil
                    
                }
                let sender = Sender(photoURL: "", senderId: senderId, displayName: name)
                
                if let content = dictionary["content"] as? String{
                    
                    return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
                    
                }else if let content = dictionary["content"] as? NSArray{
                    
                    return Message(sender: sender, messageId: messageId, sentDate: date, kind: .custom(content))
                    
                }else{
                    
                    return nil
                    
                }
                
                
            })
            
            guard let lastMessage = messages.last else{
                
                completion(.failure(customErrors.failedToFetch))
                return
                
            }
            
            let lastDate = messagePrivate.dateFormatter.string(from: lastMessage.sentDate)
            
            var message : Any?
            
            switch lastMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let service):
                if let newService = service as? NSArray{
                    
                    print(newService)
                    
                    message = newService
                }
            }
            
            self.database.child("\(readerId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                
                guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                    
                    completion(.failure(customErrors.failedToFetch))
                    return
                    
                }
                
                let updatedValue: [String : Any] = [
                    
                    "date": lastDate,
                    "is_read": true,
                    "message": message
                    
                ]
                
                var targetConversation: [String : Any]?
                var position = 0
                
                for newConversation in currentUserConversations{
                    
                    if let currentId = newConversation["id"] as? String, currentId == id{
                        
                        targetConversation = newConversation
                        break
                        
                    }
                    
                    position = position + 1
                    
                }
                
                targetConversation?["latest_message"] = updatedValue
                
                guard let trueTargetConversation = targetConversation else{
                    
                    completion(.failure(customErrors.failedToGet))
                    return
                    
                }
                
                currentUserConversations[position] = trueTargetConversation
                
                self.database.child("\(readerId)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                    
                    guard error == nil else{
                        
                        completion(.failure(customErrors.failedToSet))
                        return
                        
                    }
                    
                })
                
            })
            
            completion(.success(messages))
            
        })
        
    }
    
    //MARK: SEND MESSAGE
    
    public func sendAMessage(conversation: String, newMessage: Message, receiverName: String, receiverId: String, senderId: String, completion: @escaping (Bool) -> Void){
        
        //add to messages
        
        //update last send message
        
        //update recepient latest message
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else{
                
                return
                
            }
            
            guard var currentMessages = snapshot.value as? [[String : Any]] else{
                
                completion(false)
                return
                
            }
            
            let messageDate = newMessage.sentDate
            let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
            
            var message : Any?
            
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let service):
                if let newService = service as? NSArray{
                    
                    print(newService)
                    
                    message = newService
                }
            }
            
            
            
            let newMessageEntry: [String : Any] = [
            
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_id": senderId,
                "is_read": false,
                "name": receiverName
                
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                
                guard error == nil else{
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(senderId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    let updatedValue: [String : Any] = [
                        
                        "date": dateString,
                        "is_read": true,
                        "message": message
                        
                    ]
                    
                    var targetConversation: [String : Any]?
                    var position = 0
                    
                    for newConversation in currentUserConversations{
                        
                        if let currentId = newConversation["id"] as? String, currentId == conversation{
                            
                            targetConversation = newConversation
                            break
                            
                        }
                        
                        position = position + 1
                        
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    
                    guard let trueTargetConversation = targetConversation else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    currentUserConversations[position] = trueTargetConversation
                    
                    strongSelf.database.child("\(senderId)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        
                        guard error == nil else{
                            
                            completion(false)
                            return
                            
                        }
                        
                        //UPDATE LATEST MESSAGE FOR THE RECEIVER
                        
                        strongSelf.database.child("\(receiverId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else{
                                
                                completion(false)
                                return
                                
                            }
                            
                            let updatedValue: [String : Any] = [
                                
                                "date": dateString,
                                "is_read": false,
                                "message": message
                                
                            ]
                            
                            var targetConversation: [String : Any]?
                            var position = 0
                            
                            for newConversation in otherUserConversations{
                                
                                if let currentId = newConversation["id"] as? String, currentId == conversation{
                                    
                                    targetConversation = newConversation
                                    break
                                    
                                }
                                
                                position = position + 1
                                
                            }
                            
                            targetConversation?["latest_message"] = updatedValue
                            
                            guard let trueTargetConversation = targetConversation else{
                                
                                completion(false)
                                return
                                
                            }
                            
                            otherUserConversations[position] = trueTargetConversation
                            
                            strongSelf.database.child("\(receiverId)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                
                                guard error == nil else{
                                    
                                    completion(false)
                                    return
                                    
                                }
                                
                                completion(true)
                                
                            })
                            
                        })
                        
                    })
                    
                })
                
            })
            
        })
        
        
        
        
    }
    
    //MARK: CREATE CONVERSATION != NIL, == NIL
    
    public func sendAndCreateConversationForReceiver(conversationId: String, newMessage: Message, receiverName: String, receiverId: String, senderId: String, senderName: String, completion: @escaping (Bool) -> Void){
        
        //First Part, adding the new information to the database
        
        
        let messageDate = newMessage.sentDate
        let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
        
        
        var message : Any?
        
        switch newMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(let service):
            if let newService = service as? NSArray{
                message = newService
            }
        }
        
        let receiver_newConversationData: [String : Any] = [
            "id": conversationId,
            "other_user_id": senderId,
            "latest_message": [
                "date": dateString,
                "message": message,
                "is_read": false
            ]
        ]
            
        print(receiver_newConversationData)
        
        //UPDATE RECEIVER CONVERSATIONS
            
        self.database.child("\(receiverId)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                
            print("Go to receiverEmail conversations")
            
            if var conversations = snapshot.value as? [[String : Any]]{
                
                print("It doesnt have a conversation array")
                    
                //The receiver has a conversation array
                    
                conversations.append(receiver_newConversationData)
                self?.database.child("\(receiverId)/conversations").setValue(conversations)
                self?.sendAMessageSender(conversation: conversationId, newMessage: newMessage, receiverName: receiverName, receiverId: receiverId, senderId: senderId, completion: { result in
                    
                    switch(result){
                    case true:
                        completion(result)
                    case false:
                        completion(result)
                    
                    }
                    
                })
                    
            }else{
                
                print("It has a conversation array")
                    
                self?.database.child("\(receiverId)/conversations").setValue([receiver_newConversationData])
                
                self?.sendAMessageSender(conversation: conversationId, newMessage: newMessage, receiverName: receiverName, receiverId: receiverId, senderId: senderId, completion: { result in
                    
                    switch(result){
                    case true:
                        completion(result)
                    case false:
                        completion(result)
                    
                    }
                    
                })
                
            }
                
        })
            
    }
    
    //MARK: SEND MESSAGE ONLY TO SENDER
    
    public func sendAMessageSender(conversation: String, newMessage: Message, receiverName: String, receiverId: String, senderId: String, completion: @escaping (Bool) -> Void){
        
        //add to messages
        
        //update last send message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else{
                
                return
                
            }
            
            guard var currentMessages = snapshot.value as? [[String : Any]] else{
                
                completion(false)
                return
                
            }
            
            let messageDate = newMessage.sentDate
            let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
            
            var message : Any?
            
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let service):
                if let newService = service as? NSArray{
                    message = newService
                }
            }
            
            let newMessageEntry: [String : Any] = [
            
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_id": senderId,
                "is_read": false,
                "name": receiverName
                
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                
                guard error == nil else{
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(senderId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    let updatedValue: [String : Any] = [
                        
                        "date": dateString,
                        "is_read": true,
                        "message": message
                        
                    ]
                    
                    var targetConversation: [String : Any]?
                    var position = 0
                    
                    for newConversation in currentUserConversations{
                        
                        if let currentId = newConversation["id"] as? String, currentId == conversation{
                            
                            targetConversation = newConversation
                            break
                            
                        }
                        
                        position = position + 1
                        
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    
                    guard let trueTargetConversation = targetConversation else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    currentUserConversations[position] = trueTargetConversation
                    
                    strongSelf.database.child("\(senderId)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        
                        guard error == nil else{
                            
                            completion(false)
                            return
                            
                        }
                        
                        completion(true)
                        
                    })
                    
                })
                
            })
            
        })
        
    }
    
    //MARK: CREATE CONVERSATION == NIL, != NIL
    
    public func sendAndCreateConversationForSender(conversationId: String, newMessage: Message, receiverName: String, receiverId: String, senderId: String, senderName: String, completion: @escaping (Bool) -> Void){
        
        let ref = database.child("\(senderId)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            print("Got to singleEvent")
            
            guard var userNode = snapshot.value as? [String: Any] else{
                
                completion(false)
                print("user_not_found, impossible!")
                return
                
            }
            
            print("User found")
            
            //First Part, adding the new information to the database
            
            let messageDate = newMessage.sentDate
            let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
            
            var message : Any?
            
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let service):
                if let newService = service as? NSArray{
                    message = newService
                }
            }
            
            let newConversationData: [String : Any] = [
                "id": conversationId,
                "other_user_id": receiverId,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": true
                ]
            ]
            
            //CURRENT USER CONVERSATIONS UPDATE
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                
                //The user has a conversation array
                
                conversations.append(newConversationData)
                
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    self?.sendAMessageReceiver(conversation: conversationId, newMessage: newMessage, receiverName: receiverName, receiverId: receiverId, senderId: senderId, completion: { result in
                        
                        switch(result){
                        case true:
                            completion(result)
                        case false:
                            completion(result)
                        }
                        
                    })
                    
                    
                })
                
            }else{
                
                print("It doesnt have conversations")
                
                userNode["conversations"] = [newConversationData]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else{
                        
                        print("There was an error")
                        print(error?.localizedDescription as Any)
                        completion(false)
                        return
                        
                    }
                    
                    self?.sendAMessageReceiver(conversation: conversationId, newMessage: newMessage, receiverName: receiverName, receiverId: receiverId, senderId: senderId, completion: { result in
                        
                        switch(result){
                        case true:
                            completion(result)
                        case false:
                            completion(result)
                        
                        }
                        
                    })
                    
                })
                
            }
            
        })
            
    }
    
    //MARK: SEND MESSAGE ONLY TO RECEIVER
    
    public func sendAMessageReceiver(conversation: String, newMessage: Message, receiverName: String, receiverId: String, senderId: String, completion: @escaping (Bool) -> Void){
        
        //add to messages
        
        //update last send message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else{
                
                return
                
            }
            
            guard var currentMessages = snapshot.value as? [[String : Any]] else{
                
                completion(false)
                return
                
            }
            
            let messageDate = newMessage.sentDate
            let dateString = messagePrivate.dateFormatter.string(from: messageDate) //messageDate.toString(dateFormat: "d MMM yyyy HH:mm:ss 'CDT'")
            
            var message : Any?
            
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let service):
                if let newService = service as? NSArray{
                    message = newService
                }
            }
            
            let newMessageEntry: [String : Any] = [
            
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_id": senderId,
                "is_read": false,
                "name": receiverName
                
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                
                guard error == nil else{
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(receiverId)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    
                    guard var otherUserConversations = snapshot.value as? [[String: Any]] else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    let updatedValue: [String : Any] = [
                        
                        "date": dateString,
                        "is_read": false,
                        "message": message
                        
                    ]
                    
                    var targetConversation: [String : Any]?
                    var position = 0
                    
                    for newConversation in otherUserConversations{
                        
                        if let currentId = newConversation["id"] as? String, currentId == conversation{
                            
                            targetConversation = newConversation
                            break
                            
                        }
                        
                        position = position + 1
                        
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    
                    guard let trueTargetConversation = targetConversation else{
                        
                        completion(false)
                        return
                        
                    }
                    
                    otherUserConversations[position] = trueTargetConversation
                    
                    strongSelf.database.child("\(receiverId)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                        
                        guard error == nil else{
                            
                            completion(false)
                            return
                            
                        }
                        
                        completion(true)
                        
                    })
                    
                })
                
            })
            
        })
        
    }
    
}
