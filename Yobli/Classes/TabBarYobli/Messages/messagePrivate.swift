//
//  messagePrivate.swift
//  Yobli
//
//  Created by Brounie on 02/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import Parse
import IQKeyboardManagerSwift

// MARK: MAIN CLASS

class messagePrivate: MessagesViewController, messageCustomDelegate{
    
    //MARK: VARs/LETs
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    public var isNewConversation = false
    public var isFirstMessageAfterEnter = true
    public let otherUserId: String
    public let userId: String
    public let otherUserName: String
    public let userName: String
    private var conversationSenderSideId: String?
    private var conversationReceiverSideId: String?
    
    private var messages = [Message]()
    
    private var selfSender : Sender?{
        
        let chatFunction = ChatMainController()
        
        let newName = chatFunction.safeNameUser(name: userName)
        
        return Sender(photoURL: "", senderId: userId, displayName: newName)
        
    }
    
    //MARK: INIT
    
    init(otherUserId: String, otherUserName: String, userId: String, userName: String, senderSideId: String?, receiverSideId: String?){
        
        self.otherUserId = otherUserId
        self.userId = userId
        self.otherUserName = otherUserName
        self.userName = userName
        self.conversationSenderSideId = senderSideId
        self.conversationReceiverSideId = receiverSideId
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationSenderSideId{
            
            listenForMessages(id: conversationId, actualUserId: userId)
            
        }else if let conversationId2 = conversationReceiverSideId{
            
            listenForMessages(id: conversationId2, actualUserId: userId)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.otherUserId = ""
        self.otherUserName = ""
        self.userId = ""
        self.userName = ""
        self.conversationSenderSideId = nil
        self.conversationReceiverSideId = nil
        super.init(coder: aDecoder)
    }
    
    //MARK: VIEWDIDLOAD
    
    override func viewDidLoad(){
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: messageCollectionFlowLayout() )
        messagesCollectionView.register(messagePrivateCell.self)
        
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
                layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
                layout.textMessageSizeCalculator.incomingAvatarSize = .zero
                layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
                layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
                layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
                layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
                layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
            
        }
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    //MARK: COLLECTION VIEW
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("No messages")
        }
            
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case .custom = message.kind {
            
            let cell = messagesCollectionView.dequeueReusableCell(messagePrivateCell.self, for: indexPath)
            
            cell.delegate = self
            cell.position = indexPath
            
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            
            return cell
            
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
        
    }
    
    func checkServiceYober(serviceId: String) {
        
        let activityQuery = PFQuery(className: "Reservation")
        activityQuery.whereKey("activityId", equalTo: serviceId)
        
        activityQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                print("error: \(error)")
                print(error.localizedDescription)
            } else if let objects = objects {
                if objects.count == 0 {
                    let alert = UIAlertController(title: "AVISO", message: "Este servicio no ha sido reservado por el usuario", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                            
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "AVISO", message: "El servicio ya fue reservado por el usuario", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                            
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkServiceUser(serviceId: String) {
        
        let activityQuery = PFQuery(className: "Reservation")
        activityQuery.whereKey("activityId", equalTo: serviceId)
        
        activityQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                print("error: \(error)")
                print(error.localizedDescription)
            } else if let objects = objects {
                if objects.count == 0 {
                    self.goToPrivateRegister(id: serviceId)
                }else{
                    let alert = UIAlertController(title: "AVISO", message: "Usted ya reservó este servicio", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                            
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func goTo(position: IndexPath) {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("No messages")
        }
            
        let message = messagesDataSource.messageForItem(at: position, in: messagesCollectionView)
        
        switch message.kind {
        
        case .custom(let content):
            
            guard let arrayNS = content as? NSArray else{
                return
            }
            
            let serviceId = "\(arrayNS[0])"
            
            if(message.sender.senderId == self.selfSender?.senderId){
                
                self.checkServiceYober(serviceId: serviceId)
                
            }else{
                self.checkServiceUser(serviceId: serviceId)
            }
            
        default:
            break
            
        }
        
    }
    
    //MARK: VIEWWILLDISSAPEAR
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let conversationId = conversationSenderSideId {
            
            if messages.count > 0, let lastMessage = messages.last {
                
                let id = lastMessage.sender.senderId
                
                if( id != self.userId ){
                
                    self.listenForMessages(id: conversationId, actualUserId: self.userId)
                    
                }
                
            }
            
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.clipsToBounds = true
        
        messageInputBar.inputTextView.becomeFirstResponder()
        
        super.viewDidAppear(animated)
        
        if( messages.count > 0 ){
        
            self.messagesCollectionView.scrollToBottom()
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
         
            self.sendAlert()
            
        }
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.clipsToBounds = true
        
        super.viewWillAppear(animated)
        
    }
    
    //MARK: EXTRA MESSAGES FUNCTIONS
    
    private func listenForMessages(id: String, actualUserId: String){
        
        DBFirebaseController.shared.getAllMessagesForConversation(id: id, readerId: actualUserId, completion: { [weak self] result in
            
            switch result{
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToBottom()
                }
                
            case .failure(let error):
                 print("Couldn't get messages: \(error)")
            
            }
        
        })
        
    }
    
}

//MARK: MESSAGE EXTENSION

extension messagePrivate: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate{
    
    func currentSender() -> SenderType {
        
        if let sender = selfSender{
            
            return sender
            
        }
        
        ///THIS SHOULD NEVER HAPPEN
        
        return Sender(photoURL: "", senderId: "error123", displayName: "Error")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if ( messages[indexPath.section].sender.senderId == self.selfSender?.senderId ){
            
            return UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
            
        }
        
        return UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor.black
    }
    
}

//MARK: INPUTBAR EXTENSION

extension messagePrivate: InputBarAccessoryViewDelegate{
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let newSender = self.selfSender, let messageId = createMessageId() else{
            
            return
            
        }
        
        //Send Message
        
        let chatFunction = ChatMainController()
        let newName = chatFunction.safeNameUser(name: userName)
        let newMessage = Message(sender: newSender,
                                 messageId: messageId,
                                 sentDate: Date(),
                                 kind: .text(text))
        
        if isNewConversation{
            //create convo in database
            
            DBFirebaseController.shared.createNewConversation(otherUserId: otherUserId, otherUserName: otherUserName, firstMessage: newMessage, actualUserId: userId, actualUserName: newName, completion: { [weak self] success,id  in
            
                if success {
                    
                    self?.isNewConversation = false
                    self?.isFirstMessageAfterEnter = false
                    self?.conversationSenderSideId = id
                    if let conversationId = self?.conversationSenderSideId, let userId = self?.userId{
                        
                        self?.listenForMessages(id: conversationId, actualUserId: userId)
                        
                    }
                    
                }else{
                    
                    print("failed to sent")
                    
                }
                
                
            })
            
        }else{
            
            /*
                This is done to check three possible outcomes before sending your first message in this conversation
             
                - conversationSenderSideId != nil && conversationReceiverSideId != nil : Lo que significa que solo necesita enviar un mensaje sin hacer nada previo
                
                - conversationSenderSideId != nil && conversationReceiverSideId == nil : Lo que significa que el remitente tiene esta conversación, pero el receptor la borra y necesita volver a conectarla.
             
                - conversationSenderSideId == nil && conversationReceiverSideId != nil : Lo que significa que el receptor tiene esta conversación, pero el remitente la borra y necesita conectarla de nuevo.
             
            */
            
            if isFirstMessageAfterEnter == true {
                if conversationSenderSideId != nil && conversationReceiverSideId != nil {
                    
                    print("conversationSenderSideId2: \(conversationSenderSideId)")
                    print("conversationReceiverSideId2: \(conversationReceiverSideId)")
                    
                    guard let conversationId = conversationSenderSideId else{
                        return
                    }
                    DBFirebaseController.shared.sendAMessage(conversation: conversationId, newMessage: newMessage, receiverName: otherUserName, receiverId: otherUserId, senderId: userId,  completion: { success in
                        if success{
                            self.isFirstMessageAfterEnter = false
                        }else{
                            print("failed to send")
                        }
                    })
                }else if conversationSenderSideId != nil && conversationReceiverSideId == nil {
                    
                    print("conversationSenderSideId: \(conversationSenderSideId)")
                    print("conversationReceiverSideId: \(conversationReceiverSideId)")
                    
                    // aqui entra cuando seduplica
//                    guard let conversationId = conversationSenderSideId else {
//                        return
//                    }
//                    DBFirebaseController.shared.sendAndCreateConversationForReceiver(conversationId: conversationId, newMessage: newMessage, receiverName: otherUserName, receiverId: otherUserId, senderId: userId, senderName: newName, completion: { success in
//                        if success{
//                            self.isFirstMessageAfterEnter = false
//                            // aqui entra despues cuando se duplica
//                        }else{
//                            print("failed to send")
//                        }
//                    })
                    guard let conversationId = conversationSenderSideId else{
                        return
                    }
                    DBFirebaseController.shared.sendAMessage(conversation: conversationId, newMessage: newMessage, receiverName: otherUserName, receiverId: otherUserId, senderId: userId,  completion: { success in
                        if success{
                            self.isFirstMessageAfterEnter = false
                        }else{
                            print("failed to send")
                        }
                    })
                }else{
                    guard let conversationId = conversationReceiverSideId else{
                        return
                    }
                    DBFirebaseController.shared.sendAndCreateConversationForSender(conversationId: conversationId, newMessage: newMessage, receiverName: otherUserName, receiverId: otherUserId, senderId: userId, senderName: newName, completion: { success in
                        if success{
                            self.isFirstMessageAfterEnter = false
                        }else{
                            print("failed to send")
                        }
                    })
                }
            }else{
                //aqui entra cuando esta bien
                
                guard let conversationId = conversationSenderSideId else{
                    return
                }
                
                DBFirebaseController.shared.sendAMessage(conversation: conversationId, newMessage: newMessage, receiverName: otherUserName, receiverId: otherUserId, senderId: userId,  completion: { success in
                    
//                    "Content-Type": "application/json",
//                    "Authorization": "key=<Server_key>"
//                    
//                    {
//                        "to": "<Device FCM token>",
//                        "notification": {
//                          "title": "Check this Mobile (title)",
//                          "body": "Rich Notification testing (body)",
//                          "mutable_content": true,
//                          "sound": "Tri-tone"
//                          },
//
//                       "data": {
//                        "url": "<url of media image>",
//                        "dl": "<deeplink action on tap of notification>"
//                          }
//                    }

                    if success{
                        print("conversationId: \(conversationId)")
                        print("newMessage: \(newMessage)")
                        print("receiverName: \(self.otherUserName)")
                        print("receiverId:\(self.otherUserId)")
                        print("senderId:\(self.userId)")
                        print("message sent")
                        
                    }else{
                        
                        print("failed to send")
                        
                    }
                    
                })
                
                
            }
            
            
        }
        
        inputBar.inputTextView.text = ""
        
        
    }
    
    private func createMessageId() -> String?{
        
        //date, otherUserId, UserId, randomInt
        
        let dateString = Self.dateFormatter.string(from: Date())
        //let dateString = Date().toString(dateFormat: "dd MM yyyy HH:mm:ss")
        
        let newIdentifier = "\(otherUserId)_\(userId)_\(dateString)"
        
        return newIdentifier
        
        
    }
    
}

//MARK: NAVIGATION CONTROLLER

extension messagePrivate: UINavigationControllerDelegate{
    
    @objc func goToYoberProfileFromOtherTab(){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        //TAB
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreAgenda") as? exploreAgenda {
                
                viewcontroller.yoberId = otherUserId
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
    @objc func goToYoberProfile(){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreAgenda") as? exploreAgenda {
                
                viewcontroller.yoberId = otherUserId
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
    @objc func goToCreateService(){
        
        let storyboard = UIStoryboard(name: "TabYoberMessage", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "serviceMessagePageController") as! serviceMessagePageController
        
        viewController.messagePrivatePrevious = self
    
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func goBack(){
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @objc func goToProfileFromImageYober(){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        //TAB
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile {
                
                viewcontroller.yoberId = otherUserId
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
    @objc func goToProfileFromImageUser(){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        //TAB
        
        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
        
        tabbar.selectedIndex = 0
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaClienteDetails") as? agendaClienteDetails {
                
                viewcontroller.subscriberId = otherUserId
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
    //MARK: SEND FUNCTION
    
    func sendService(sendService: PFObject) {
        
        var service = PFObject(className: "Service")
        
        sendService.saveInBackground { (result: Bool?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorType(error: error)
                
            }else if result == true{
                
                service = sendService
                
                guard let serviceId = service.objectId, let serviceName = service["name"] as? String else{
                    
                    print("This didn't work")
                    return
                    
                }
                
                guard let newSender = self.selfSender, let messageId = self.createMessageId() else{
                    
                    print("The second part didnt work")
                    return
                    
                }
                
                let messageNS : NSArray = [serviceId, serviceName]
                
                print(messageNS)
                
                //Send Message
                let newMessage = Message(sender: newSender,
                                         messageId: messageId,
                                         sentDate: Date(),
                                         kind: .custom(messageNS))
                
                guard let conversationId = self.conversationSenderSideId else{
                    return
                }
                
                DBFirebaseController.shared.sendAMessage(conversation: conversationId, newMessage: newMessage, receiverName: self.otherUserName, receiverId: self.otherUserId, senderId: self.userId,  completion: { success in
                    
                    if success{
                        
                        print("message sent")
                        
                        return
                        
                    }else{
                        
                        print("failed to send")
                        
                        return
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func goToPrivateRegister(id: String){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreRegisterPrivateService") as? exploreRegisterPrivateService {
                
                viewcontroller.serviceId = id
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
}
