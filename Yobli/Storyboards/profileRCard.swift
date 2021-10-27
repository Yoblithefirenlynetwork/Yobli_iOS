//
//  profileRCard.swift
//  Yobli
//
//  Created by Brounie on 22/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit
import MBProgressHUD

// MARK: MAIN CLASS

class profileRCard: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cardDate: UITextField!
    @IBOutlet weak var cardCVC: UITextField!
    @IBOutlet weak var cardUser: UITextField!
    @IBOutlet weak var registerCard: UIButton!
    
    // MARK: VARs/LETs
    
    var uCN = ""
    var uCD = ""
    var uCC = ""
    var uCU = ""
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cardNumber.delegate = self
        cardDate.delegate = self
        cardCVC.delegate = self
        cardUser.delegate = self
        
        registerCard.roundCustomButton(divider: 8)
        
        cardNumber.generalBottomLine()
        cardDate.generalBottomLine()
        cardCVC.generalBottomLine()
        cardUser.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveCard(_ sender: Any) {
        
        if( self.notEmpty() == true ){
            
            let numberWOSpaces = uCN.replacingOccurrences(of: " ", with: "")
            print(numberWOSpaces)
             
            let components = uCD.split(separator: "/")
            
            let month = String( components[0] )
            print(month)
            let year = String( components[1] )
            print(year)
            
            self.createConektaCardToken(cardNumber: numberWOSpaces, cardName: uCU, cardCVC: uCC, cardExpMonth: month, cardExpYear: year)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "Alguno de los datos está incompleto o vacío", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func notEmpty() -> Bool{
        
        if( uCN != "" && uCD != "" && uCC != "" && uCU != ""){
            
            if( uCN.count == 19 && uCD.count == 5 && uCC.count == 3){
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
}

// MARK: TEXTFIELD FUNCTIONS

extension profileRCard: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //initially identify your textfield

        if textField == cardNumber {

            // check the chars length cardNumber -> 4, 9 and 14 to add an space
            if (cardNumber?.text?.count == 4 || cardNumber?.text?.count == 9 || cardNumber?.text?.count == 14)  {
                
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    cardNumber?.text = (cardNumber?.text)! + " "
                    
                }
                
            }
            // check the condition not exceed 19 chars
            return !(cardNumber.text!.count >= 19  && (string.count) > range.length)
            
        }else if (textField == cardDate) {
            
            // check the chars length cardDate -> 2 and add a /
            if (cardDate?.text?.count == 2 )  {
                
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    cardDate?.text = (cardDate?.text)! + "/"
                    
                }
                
            }
            // check the condition not exceed 7 chars
            return !(cardDate.text!.count >= 5  && (string.count) > range.length)
            
        }else if (textField == cardCVC) {
            
            // check the condition not exceed 3 chars
            return !(cardCVC.text!.count >= 3  && (string.count) > range.length)
            
        }else{
            return true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField == cardNumber){
            
            uCN = cardNumber.text!
            
        }else if (textField == cardDate ){
            
            uCD = cardDate.text!
            
        }else if (textField ==  cardCVC ){
            
            uCC = cardCVC.text!
            
        }else if (textField == cardUser ){
            
            uCU = cardUser.text!
            
        }
        
    }
    
}

extension profileRCard{
    
    //MARK: CARD CLOUD CONNECTION
    
    //This one will let us now if the card is valid or is false, and create a token to conekt with a User
    
    func createConektaCardToken(cardNumber: String, cardName: String, cardCVC: String, cardExpMonth: String, cardExpYear: String){
        
        self.showHUD(progressLabel: "Registrando Tarjeta")
            
        let paymentHandler = PaymentHandler() //HERE IS SAVED THE KER
        
        let conekta = Conekta()
        
        conekta.delegate = self
            
        //Esta llave se cambia
        conekta.publicKey = paymentHandler.returnConektaKey()
            
        conekta.collectDevice()
            
        let card = conekta.card()
            
        card?.setNumber(cardNumber, name: cardName, cvc: cardCVC, expMonth: cardExpMonth, expYear: cardExpYear)
            
        let token = conekta.token()
            
        token?.card = card
            
        token?.create(success: { (data) -> Void in
                
            if(data?["type"] as? String == "parameter_validation_error"){
                
                self.dismissHUD(isAnimated: true)
                
                let alert = UIAlertController(title: "ERROR", message: "La tarjeta no es válida", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
                
                if let tokenId = data?["id"] as? String{
                    
                    print("Se creó el token\(tokenId)")
                    self.createSource(token: tokenId)
                    
                }
                
            }
            
        }, andError: { (error) -> Void in
            
            self.dismissHUD(isAnimated: true)
            
            let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        })
    
    }
    
    
    //This function will Conekta the token of the card with a User
        
    func createSource(token: String){
        
        guard let user = PFUser.current() else{
            
            self.dismissHUD(isAnimated: true)
            
            self.sendAlert()
            
            return
            
        }
        
        let params = NSMutableDictionary()
        
        if let customerId = user["customer_id"] as? String{
            
            params.setObject(token, forKey: "cardToken" as NSCopying)
            params.setObject(customerId, forKey: "customer_id" as NSCopying)
            
            print("PARAMS \(params)")
            
            PFCloud.callFunction(inBackground: "createConektaSource", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
                
                if let error = error{
                    
                    self.dismissHUD(isAnimated: true)
                    
                    let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }else if let results = results{
                    
                    print("createStripeSource \(results)")
                    
                    let res = results as? AnyObject
                    
                    guard let id = res?.object(forKey: "id") as? String, let last4 = res?.object(forKey: "last4") as? String, let brand = res?.object(forKey: "brand") as? String else{
                        
                        let alert = UIAlertController(title: "ERROR", message: "Algún de los valores no es válido", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                        
                    }
                    
                    self.saveCardInParse(id: id, last4: last4, brand: brand)
                    
                }
                
            })
            
        }else{
            
            //THIS WAS ONE WAS CREATE, BECAUSE MAYBE THE USER DIDN'T CREATE A CUSTOMER_ID BEFORE CREATING THE PROFILE
            
            print("Creating customer_id, because it wasnt there")
            
            guard let email = user.email, let name = user["name"] as? String else {
                
                print("If this fail, something is clearly wrong")
                
                self.dismissHUD(isAnimated: true)
                
                self.sendAlert()
                
                return
                
            }
            
            let params = NSMutableDictionary()
            params.setObject(email, forKey: "email" as NSCopying)
            params.setObject(name, forKey: "name" as NSCopying)
                
            PFCloud.callFunction(inBackground: "createConektaCustomer", withParameters: params as [NSObject : AnyObject],block:{ (result, error)  -> Void in
                
                if let error = error{
                    
                    self.dismissHUD(isAnimated: true)
                    
                    print("ERROR customerI")
                    self.sendErrorFromConekta(error: error)
                    
                }else if let results = result{
                    
                    let res = results as? AnyObject
                    let id = res?.object(forKey: "id") as? String
                    print("Res: \(res)")
                    print("Results: \(results)")
                    print("Este es el id: \(id)")
                    
                    //Set id for Conekta
                    
                    guard let createdId = id else{
                        print("It should not be null")
                        self.dismissHUD(isAnimated: true)
                        return
                    }
                    
                    user["customer_id"] = createdId
                        
                    user.saveInBackground(block: { (success, error) in
                    
                        if let error = error{
                            
                            self.dismissHUD(isAnimated: true)
                            
                            print("Something went wrong: \(error)")
                            
                            self.sendErrorType(error: error)
                            
                        }else{
                            
                            print("Id : " + createdId)
                            
                            self.createSource(token: token)
                            
                        }
                        
                    })
                        
                }
                
            })
            
        }
        
    }
    
    //Save Card in Parse after succesfully conect one to a user in Parse
    
    func saveCardInParse(id: String, last4: String, brand: String){
        
        guard let user = PFUser.current() else {
            
            self.dismissHUD(isAnimated: true)
            
            self.sendAlert()
            
            return
        }
            
        let cardObject = PFObject(className: "Card")
        
        cardObject["lastFourDigits"] = last4
        cardObject["cardTokenId"] = id
        cardObject["type"] = brand
        cardObject["user"] = user
        
        cardObject.saveInBackground { (success, error) -> Void in

            if error != nil {
                
                guard let error = error else{
                    
                    print("This should never happen")
                    
                    return
                    
                }
                
                self.dismissHUD(isAnimated: true)
                
                self.sendErrorType(error: error)
                
                
            }else{
                
                self.dismissHUD(isAnimated: true)
                
                let alert = UIAlertController(title: "ÉXITO", message: "La tarjeta ha sido guardada correctamente", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in

                    _ = self.navigationController?.popViewController(animated: true)

                }))
                    
                self.present(alert, animated: true, completion: nil)
            
            }
            
        }
        
    }

}

//MARK: SHOW HUD EXTENSION

extension profileRCard{
    
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
