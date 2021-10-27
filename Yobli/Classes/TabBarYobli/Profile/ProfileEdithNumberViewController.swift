//
//  ProfileEdithNumberViewController.swift
//  Yobli
//
//  Created by Francisco javier Moreno Torres on 13/08/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MBProgressHUD
import Parse

class ProfileEdithNumberViewController: UIViewController, UITextFieldDelegate {

    // MARK: OUTLETS
    
    @IBOutlet weak var phoneCode: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var securityCodeView: UIView!
    @IBOutlet weak var firstSecurityCodeTextField: UITextField!
    @IBOutlet weak var secondSecurityCodeTextField: UITextField!
    @IBOutlet weak var thirdSecurityCodeTextField: UITextField!
    @IBOutlet weak var fourthSecurityCodeTextField: UITextField!
    
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    //Variables modifiable by the previous view
    var email = ""
    var password = ""
    var username = ""
    var userDescription = ""
    var image = UIImage(named: "imageBackground")
    var phone_verificationCode = "" //The code to verify the phone number of the user
    var randomCode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.phoneCode.generalBottomLine()
        self.phoneNumber.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        //self.securityCodeTextField.textContentType = .oneTimeCode
        
        self.firstSecurityCodeTextField.textContentType = .oneTimeCode
        self.secondSecurityCodeTextField.textContentType = .oneTimeCode
        self.thirdSecurityCodeTextField.textContentType = .oneTimeCode
        self.fourthSecurityCodeTextField.textContentType = .oneTimeCode
        
        self.firstSecurityCodeTextField.delegate = self
        self.secondSecurityCodeTextField.delegate = self
        self.thirdSecurityCodeTextField.delegate = self
        self.fourthSecurityCodeTextField.delegate = self
        
        self.sendCodeButton.setTitle("ENVIAR", for: .normal)
        self.continueButton.setTitle("ACEPTAR", for: .normal)
        
        self.securityCodeView.isHidden = true
        self.continueButton.alpha = 0.0
        
    }
    
    //MARK: - Methods
    
    func generateCode() {
        
        var fourUniqueDigits: String {
            var result = ""
            repeat {
                // create a string with up to 4 leading zeros with a random number 0...9999
                result = String(format:"%04d", arc4random_uniform(10000) )
                // generate another random number if the set of characters count is less than four
            } while Set<Character>(result).count < 4
            return result    // ran 5 times
        }
        
        self.randomCode = Int(fourUniqueDigits) ?? 0000
    }
    
    func seendSMS() {
     
        print("randomCode: \(self.randomCode)")
        
        let accountSID = "AC00ba40006dd4a8c074fa27356347ae2f"
        let authToken = "90577bab51b26438e1047251ef3cd4f0"

        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        print("url: \(url)")
        let parameters = ["From": "+18104840627", "To": (self.phoneCode.text ?? "") + (self.phoneNumber.text ?? ""), "Body": "Tú código de verificación es: \(self.randomCode)"]

        AF.request(url, method: .post, parameters: parameters).authenticate(username: accountSID, password: authToken).responseJSON { response in
            debugPrint(response)
        }
        //RunLoop.main.run()
    }
    
    func saveChangesParse(){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando Información"
        
        let user = PFUser.current()
        
        user?["userPhoneNumber"] = phoneNumber.text
        user?["userPhoneCode"] = phoneCode.text
        
        user?.saveInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                self.sendErrorType(error: error)
                loader.hide(animated: true)
                
            }else{
                
                loader.hide(animated: true)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }

    @IBAction func sendCodeButton(_ sender: UIButton) {
        
        //Check if the phoneCode and phoneNumber are empty, if they are not, they can be saved

        if( (phoneCode.text?.isEmpty)! ||  (phoneNumber.text?.isEmpty)! ){

            //Send a message that the number was not given

            let alert = UIAlertController(title: "ERROR", message: "No se ha dado informacion en alguno de los dos campos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)

        } else if(phoneCode.text?.count == 3 && phoneNumber.text?.count == 10){
            
            self.generateCode()
            self.seendSMS()
            self.securityCodeView.isHidden = false
            self.continueButton.alpha = 1.0
            self.sendCodeButton.alpha = 0.0
            
        } else{
            
            let alert = UIAlertController(title: "ERROR", message: "El número de teléfono no es válido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func acceptButton(_ sender: Any) {
        
        let securityCodeone = (self.firstSecurityCodeTextField.text ?? "0") + (self.secondSecurityCodeTextField.text ?? "0")
        
        let securityCodetwo = (self.thirdSecurityCodeTextField.text ?? "0") + (self.fourthSecurityCodeTextField.text ?? "0")
        
        let securityCode = securityCodeone + securityCodetwo
        
        if self.randomCode == Int(securityCode) {
            
            self.saveChangesParse()
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "El código de verificación es incorrecto", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !(string == "") {
            textField.text = string
            if textField == self.firstSecurityCodeTextField {
                self.secondSecurityCodeTextField.becomeFirstResponder()
            }
            else if textField == self.secondSecurityCodeTextField {
                self.thirdSecurityCodeTextField.becomeFirstResponder()
            }
            else if textField == self.thirdSecurityCodeTextField {
                self.fourthSecurityCodeTextField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
            return false
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.text?.count ?? 0) > 0 {

        }
        return true
    }

}
