//
//  messageMain.swift
//  Yobli
//
//  Created by Brounie on 23/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase

class messageMain: UIViewController {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var contactsTable: UITableView!
    
    //MARK: VARs/LETs
    
    private var usersContacts = [[String: String]]()
    private var conversations = [Conversation]()
    private var receiversId = [String?]()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.getConversations()
        
        self.navigationController?.isNavigationBarHidden = true
        
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
         
            self.sendAlert()
            
        }
        
        self.getConversations()
    }
    
    //MARK: RETRIEVE FUNCTIONS
    
    func getConversations(){
        
        guard let objectId = PFUser.current()!.objectId else{
            return
        }
        
        DBFirebaseController.shared.getAllConversations(id: objectId, completion: { [weak self] result in
            
            switch result{
            
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.contactsTable.reloadData()
                }
                
            case .failure(let error):
                print("Not conversations get \(error)")
                
            
            }
            
            
        })
        
        
        
    }
    
    
}

//  MARK: TABLEVIEW EXTENSION

extension messageMain: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.receiversId = []
        
        let model = conversations[indexPath.row]
        
        if let userObjectId = PFUser.current()!.objectId{
            
            DBFirebaseController.shared.getIfConversation2(receiverId: conversations[indexPath.row].otherUserId, senderId: userObjectId) { result in
                
                switch result{
                case.success(let answer):
                    print("answer: \(answer)")
                    self.receiversId.append(answer)
                case.failure(let answer2):
                    print("answer: \(answer2)")
                    self.receiversId.append(nil)
                }
                
            }
            
        }
        
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "messageMainContactCellU") as! messageMainContactCell
        
        cell.configure(model: model)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        contactsTable.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        let object = PFUser.current()
        guard let userObjectId = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            
            return
            
        }
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:model.otherUserId)
        
        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = object {
                
                if let name = object["name"] as? String{
                    
                    if object["yober"] as? Bool == true {
                        
                        //let modelId = model.id.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
                        
                        let viewController = messagePrivate(otherUserId: model.otherUserId, otherUserName: name, userId: userObjectId, userName: userName, senderSideId: model.id, receiverSideId: self.receiversId[indexPath.row])
                        
                        print("senderSideIdYober: \(model.id)")
                        print("receiverSideIdYober: \(String(describing: self.receiversId[indexPath.row]))")
                        
                        //RIGHTBUTTON
                        
                        let image = UIImage(named: "reserveService")
                        let button = UIButton()
                        button.frame = CGRect(x: 0, y: 0, width: 108, height: 47)
                        button.addTarget(viewController, action: #selector(viewController.goToYoberProfileFromOtherTab), for: .touchUpInside)
                        button.setImage(image, for: .normal)
                        
                        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 108)
                        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 42)
                        heightConstraint.isActive = true
                        widthConstraint.isActive = true
                        
                        let rightButtonPlusService = UIBarButtonItem(customView: button)
                        
                        //LEFT BUTTON
                        
                        //First Button - User Image
                        
                        let buttonGo = UIButton()
                        buttonGo.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
                        
                        let widthConstraintGo = buttonGo.widthAnchor.constraint(equalToConstant: 42)
                        let heightConstraintGo = buttonGo.heightAnchor.constraint(equalToConstant: 42)
                        heightConstraintGo.isActive = true
                        widthConstraintGo.isActive = true
                        
                        buttonGo.setImageUser(name: model.otherUserId)
                        buttonGo.addTarget(viewController, action: #selector(viewController.goToProfileFromImageYober), for: .touchUpInside)
                        
                        let leftImageUser = UIBarButtonItem(customView: buttonGo)
                        
                        //Second Button - Return Image
                        
                        let arrowBack = UIImage(named: "arrowBack")
                        let buttonBack = UIButton()
                        buttonBack.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
                        buttonBack.addTarget(viewController, action: #selector(viewController.goBack), for: .touchUpInside)
                        buttonBack.setImage(arrowBack, for: .normal)
                        
                        let widthConstraintBack = buttonBack.widthAnchor.constraint(equalToConstant: 42)
                        let heightConstraintBack = buttonBack.heightAnchor.constraint(equalToConstant: 42)
                        heightConstraintBack.isActive = true
                        widthConstraintBack.isActive = true
                        
                        let leftButtonBack = UIBarButtonItem(customView: buttonBack)
                        
                        //ADD BUTTONS AND VIEWS
                        
                        viewController.navigationItem.setTitle("Conversación", subtitle: name)
                        viewController.navigationItem.rightBarButtonItem = rightButtonPlusService
                        viewController.navigationItem.leftBarButtonItems = [leftButtonBack, leftImageUser]
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
                    } else {
                        
                        let viewController = messagePrivate(otherUserId: model.otherUserId, otherUserName: name, userId: userObjectId, userName: userName, senderSideId: model.id, receiverSideId: self.receiversId[indexPath.row])
                        
                        print("senderSideId: \(model.id)")
                        print("receiverSideId: \(String(describing: self.receiversId[indexPath.row]))")
                        
                        //LEFT BUTTON
                        
                        //First Button - User Image
                        
                        let leftImageUser = UIBarButtonItem()
                        leftImageUser.setImage(name: model.otherUserId)
                        
                        //Second Button - Return Image
                        
                        let arrowBack = UIImage(named: "arrowBack")
                        let buttonBack = UIButton()
                        buttonBack.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
                        buttonBack.addTarget(viewController, action: #selector(viewController.goBack), for: .touchUpInside)
                        buttonBack.setImage(arrowBack, for: .normal)
                        
                        let widthConstraintBack = buttonBack.widthAnchor.constraint(equalToConstant: 42)
                        let heightConstraintBack = buttonBack.heightAnchor.constraint(equalToConstant: 42)
                        heightConstraintBack.isActive = true
                        widthConstraintBack.isActive = true
                        
                        let leftButtonBack = UIBarButtonItem(customView: buttonBack)
                        
                        //ADD BUTTONS AND VIEWS
                        
                        viewController.navigationItem.setTitle("Conversación", subtitle: name)
                        viewController.navigationItem.leftBarButtonItems = [leftButtonBack, leftImageUser]
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let delete = deleteAction(at: indexPath)
//
//        return UISwipeActionsConfiguration(actions: [delete])
//
//    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
            self.deleteConversation(position: indexPath.row)
            completion(true)
        }
        
        action.backgroundColor = UIColor.systemRed
        
        return action
        
    }
    
    func deleteConversation(position: Int){
        
        guard let id = PFUser.current()!.objectId else{
            return
        }
        
        DBFirebaseController.shared.deleteConversation(conversationId: conversations[position].id, userId: id, completion: { success in
            
            if success == true{
                
                self.getConversations()
                
            }
            
        })
        
    }
    
    
}
