//
//  profileMain.swift
//  Yobli
//
//  Created by Brounie on 26/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase
import FirebaseAuth

class profileMain: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var userMainPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMemberTime: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var userPhone: UILabel!
    @IBOutlet weak var userMail: UILabel!
    @IBOutlet weak var userPaymentMethods: UITableView!
    @IBOutlet weak var userLocation: UITableView!
    
    // MARK: VARs/LETs
    var myCards = [PFObject]()
    
    var allAddress = [userAddress]() //Struct in profileRAddress
    var returnAddress = [Data]()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        userPaymentMethods.delegate = self
        userPaymentMethods.dataSource = self
        userLocation.delegate = self
        userLocation.dataSource = self
        
        userMainPhoto.roundCompleteImageColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateView()
        self.queryCards()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func logOut(_ sender: Any) {
        
        try!
            Auth.auth().signOut()
        PFUser.logOut()
        
        let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let nav = UINavigationController(rootViewController: goTo)
        
        nav.isNavigationBarHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
        
    }
    
    @IBAction func editProfile(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileMainEdit") as? profileMainEdit
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func addToDirections(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileRAddress") as? profileRAddress
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func addToPaymentMethods(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileRCard") as? profileRCard
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func goToYoberProfile(_ sender: Any) {
        
        guard let user = PFUser.current(), let isYober = user["yober"] as? Bool else{
            
            self.sendAlert()
            
            return
            
        }
        
        if( isYober == true ){
            
            let goTo = UIStoryboard(name: "TabProfile", bundle: nil).instantiateViewController(withIdentifier: "profileChangeYober") as! profileChangeYober
            
            let nav = UINavigationController(rootViewController: goTo)
            
            nav.isNavigationBarHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = nav
            
        }else{
            
            let alert = UIAlertController(title: "ATENCIÓN", message: "Tú cuenta ahora también será Yober, ¿Estás seguro/a?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Volverse Yober", style: .default){ (_) in
                
                let goTo = UIStoryboard(name: "TabProfile", bundle: nil).instantiateViewController(withIdentifier: "profileChangeYober") as! profileChangeYober
                
                let nav = UINavigationController(rootViewController: goTo)
                
                nav.isNavigationBarHidden = true
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = nav
                
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    @IBAction func sendSOS(_ sender: Any) {
        
        let alert = UIAlertController(title: "ATENCIÓN", message: "¿Está seguro/a de llamar a emergencias?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        let action = UIAlertAction(title: "Contactar", style: .default){ (_) in
            
            guard let number = URL(string: "tel://" + "911") else {
                return
            }
            
            UIApplication.shared.open(number)
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    
    //MARK: UPDATE VIEW
    
    func updateView(){
        
        let user = PFUser.current()!
        
        if let imageInformation = user["userPhoto"] as? PFFileObject{
            
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.userMainPhoto.image = image
                }
            }
        }
        
        if let newName = user["name"] as? String{
            self.userName.text = newName
        }else{
            self.userName.text = nil
        }
        
        if let newDate = user.createdAt{
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy, HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            let labelDate = dateFormatter.string(from: newDate)
            
            self.userMemberTime.text = "Miembro desde: " + labelDate
            
        }else{
            
            self.userMemberTime.text = nil
            
        }
        
        if let newDescription = user["userDescription"] as? String{
            self.userDescriptionLabel.text = newDescription
        }else{
            self.userDescriptionLabel.text = nil
        }
        
        if let newCode = user["userPhoneCode"] as? String{
            
            if let newPhone = user["userPhoneNumber"] as? String{
                self.userPhone.text = newCode + newPhone
            }else{
                self.userPhone.text = nil
            }
            
        }else{
            self.userPhone.text = nil
        }
        
        if let newMail = user["email"] as? String{
            self.userMail.text = newMail
        }else{
            self.userDescriptionLabel.text = nil
        }
        
        if let newAddress = user["locations"] as? [Data]{
            
            var newArrayOfAddress = [userAddress]()
            
            returnAddress = newAddress
            
            let decoder = JSONDecoder()
            
            for address in newAddress{
                
                if let addressObtain = try? decoder.decode(userAddress.self, from: address) {
                    
                    newArrayOfAddress.append(addressObtain)
                    
                }
                
            }
            
            allAddress = newArrayOfAddress
            
            
        }
        
        let cardsQuery = PFQuery(className: "Card")
        cardsQuery.whereKey("user", equalTo: user )
        cardsQuery.order(byDescending: "createdAt")
        
        cardsQuery.findObjectsInBackground { (results, error) in
            
            if let error = error{
                
                print("\(error.localizedDescription)")
                
            }else if let results = results{
                
                self.myCards = results
                
                self.userPaymentMethods.reloadData()
                
            }
            
        }
        
    }
    
    //MARK: GET CARDS
    
    func queryCards(){
        
        guard let user = PFUser.current() else {
            
            print("This shouldnt happen")
            
            return
            
        }
        
        let cardsQuery = PFQuery(className: "Card")
        cardsQuery.whereKey("user", equalTo: user )
        cardsQuery.order(byDescending: "createdAt")
        
        cardsQuery.findObjectsInBackground { (results, error) in
            
            if let error = error{
                
                print("\(error.localizedDescription)")
                
            }else if let results = results{
                
                self.myCards = results
                
                self.userPaymentMethods.reloadData()
                
            }
            
        }
        
    }
    
    
    
}



// MARK: EXTENSION TABLEVIEW

extension profileMain: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if( tableView == userPaymentMethods ){
            
            return myCards.count
            
        }else if( tableView == userLocation ){
            
            return allAddress.count
            
        }
            
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if( tableView == userPaymentMethods ){
            
            let cell = userPaymentMethods.dequeueReusableCell(withIdentifier: "selectPMCell") as! selectCACell
                    
            cell.delegate = self
            cell.numberInArray = indexPath.row
            cell.typeOfContent = "Card"
            
            let cardNumber = myCards[indexPath.row]["lastFourDigits"] as? String
            let cardSelected = myCards[indexPath.row]["default"] as? Bool
              
            let cardNumberString = cardNumber ?? ""
            
            cell.textContent.text = "**** **** **** \(cardNumberString)"
            
            if(cardSelected == true){
                
                cell.selectButton.setImage(UIImage(named: "optionSelectIcon"), for: .normal)
                
            }else{
                cell.selectButton.setImage(UIImage(named: "optionNoSelectIcon"), for: .normal)
            }
            
            return cell
            
        }else{
            
            let cell = userLocation.dequeueReusableCell(withIdentifier: "selectACell") as! selectCACell
            
            cell.delegate = self
            cell.numberInArray = indexPath.row
            cell.typeOfContent = "Address"
            
            cell.textContent.text = fillAddress(position: indexPath.row)
            cell.selectButton.setImage(UIImage(named: "optionNoSelectIcon"), for: .normal)
            
            if(allAddress[indexPath.row].selected == true){
                
                cell.selectButton.setImage(UIImage(named: "optionSelectIcon"), for: .normal)
                
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if(tableView == userLocation){
            
            let delete = deleteAction(at: indexPath, type: "Address")
            
            return UISwipeActionsConfiguration(actions: [delete])
            
        }else{
            
            let delete = deleteAction(at: indexPath, type: "Card")
            
            return UISwipeActionsConfiguration(actions: [delete])
        }
        
    }
    
    func deleteAction(at indexPath: IndexPath, type: String) -> UIContextualAction{
        
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
            self.updateTable(position: indexPath.row, type: type)
            completion(true)
        }
        
        action.backgroundColor = UIColor.systemRed
        
        return action
        
    }
    
    func fillAddress(position: Int) -> String{
    
        var result = ""
        
        if allAddress[position].number == "" {
            result = allAddress[position].street + ", " + allAddress[position].reference + ", " + allAddress[position].colony + ", " + allAddress[position].city + ", " + allAddress[position].state
        }else{
            result = allAddress[position].street + ", " + allAddress[position].number + ", " + allAddress[position].reference + ", " + allAddress[position].colony + ", " + allAddress[position].city + ", " + allAddress[position].state
            
        }
        return result
    }
    
    //MARK: DELETE CARD
    
    //UPDATE TABLE WHEN DOING DELETE
    
    func updateTable(position: Int, type: String){
        
        if( type == "Address" ){
            
            allAddress.remove(at: position)
            self.updateAddressChanges()
            
        }else if( type == "Card" ){
            
            guard let cardSelected = myCards[position]["default"] as? Bool, let user = PFUser.current(), let cardId = myCards[position]["cardTokenId"] as? String, let userConektaId = user["customer_id"] as? String else{
                return
            }
            
            if cardSelected == true{
                
                let alert = UIAlertController(title: "ERROR", message: "La tarjeta que buscas borrar, es tu tarjeta por defecto", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
                
                print("Can delete")
                
                let params = NSMutableDictionary()
                
                params.setObject(userConektaId, forKey: "customer_id" as NSCopying)
                params.setObject(cardId, forKey: "card_id" as NSCopying)
                    
                PFCloud.callFunction(inBackground: "deletePaymentMethod", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
                    
                    if let error = error{
                        
                        print("Error during deleteCard")
                        
                        self.sendErrorType(error: error)
                        
                    }else{
                        
                        self.myCards[position].deleteInBackground { (result, error) in
                            
                            if let error = error{
                                
                                self.sendErrorType(error: error)
                                
                            }else{
                                
                                self.queryCards()
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    
}

// MARK: EXTENSION selectOptionCA

extension profileMain: selectOptionCA{
    
    func selectedOption(type: String, position: Int) {
        
        if(type == "Card"){
            
            self.updateDefaultCard(position: position)
            
        }else if(type == "Address"){
            
            var x = 0
            
            for address in allAddress{
                
                if(address.selected == true){
                    
                    allAddress[x].selected = false
                    break
                    
                }
                
                x = x + 1
                
            }
            
            allAddress[position].selected = true
            
            self.updateAddressChanges()
            
        }
        
    }
    
    func updateDefaultCard(position: Int){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        //Array to set everything to false and true
        
        var x = 0
        
        for card in self.myCards{
            
            if( x == position  ){
                
                card["default"] = true
                
            }else{
                
                card["default"] = false
                
            }
            
            x = x + 1
            
        }
        
        //Set the card to default in parse and save All with the changes after
        
        let params = NSMutableDictionary()
        
        let card = self.myCards[position]
        
        if let cardId = card.object(forKey: "cardTokenId") as? String{
            
            params.setObject(cardId, forKey: "source_id" as NSCopying)
            
            if let customerId = user["customer_id"] as? String{
                
                params.setObject(customerId, forKey: "customer_id" as NSCopying)
                
                PFCloud.callFunction(inBackground: "updateConektaCustomerDefaultSource", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
                    
                    if let error = error{
                        
                        print("Error during default card")
                        
                        self.sendErrorFromConekta(error: error)
                        
                    }else{
                        
                        PFObject.saveAll(inBackground: self.myCards) { (result, error) in
                            
                            if let error = error{
                                
                                print("Error during saving all cards")
                                
                                self.sendErrorType(error: error)
                                
                            }else{
                                
                                self.queryCards()
                                
                            }
                            
                        }
                        
                    }
                    
                })
            
            }else{
                
                print("This shouldnt happen, but if it does we need to create a customer_id")
                
            }
            
        }
        
    }
    
    func updateAddressChanges(){
        
        var newAddress = [Data]()
        
        for address in allAddress{
            
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(address) {
                
                newAddress.append(encoded)
                
            }
            
        }
        
        returnAddress = newAddress
        
        guard let user = PFUser.current() else{
            self.sendAlert()
            return
        }
        
        user["locations"] = returnAddress
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                    
                self.userLocation.reloadData()
                
            }
            
        }
        
    }
    
}
