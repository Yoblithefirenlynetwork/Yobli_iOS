//
//  messageYoberMain.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase
import MBProgressHUD

class messageYoberMain: UIViewController {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var contactsTable: UITableView!
    
    //MARK: VARs/LETs
    
    private var usersContacts = [[String: String]]()
    private var conversations = [Conversation]()
    private var receiversId = [String?]()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getConversations()
        
        self.navigationController?.isNavigationBarHidden = true
        
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
            
            self.sendAlert()
            
        }
        
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

extension messageYoberMain: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        receiversId = []
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]
        
        if let userObjectId = PFUser.current()!.objectId{
            
            
            DBFirebaseController.shared.getIfConversation2(receiverId: conversations[indexPath.row].otherUserId, senderId: userObjectId) { result in
                
                switch result{
                case.success(let answer):
                    self.receiversId.append(answer)
                case.failure( _):
                    self.receiversId.append(nil)
                }
                
            }
            
        }
        
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "messageMainContactCellY") as! messageMainContactCell
        
        cell.configure(model: model)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.showHUD(progressLabel: "Cargando...")
        
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
                self.dismissHUD(isAnimated: true)
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = object {
                
                if let name = object["name"] as? String {
                    
                    //TITLE VIEWCONTROLLER
                    
                    let viewController = messagePrivate(otherUserId: model.otherUserId, otherUserName: name, userId: userObjectId, userName: userName, senderSideId: model.id, receiverSideId: self.receiversId[indexPath.row])
                    
                    print("yober")
                    print("senderSideId: \(model.id)")
                    print("receiverSideId: \(String(describing: self.receiversId[indexPath.row]))")
                    
                    //RIGHTBUTTON
                    
                    let image = UIImage(named: "plusService")
                    let button = UIButton()
                    button.frame = CGRect(x: 0, y: 0, width: 108, height: 42)
                    button.addTarget(viewController, action: #selector(viewController.goToCreateService), for: .touchUpInside)
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
                    buttonGo.addTarget(viewController, action: #selector(viewController.goToProfileFromImageUser), for: .touchUpInside)
                    
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
                    
                    self.dismissHUD(isAnimated: true)
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
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

extension messageYoberMain{
    
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
