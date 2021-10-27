//
//  singInMailPh.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class singInMailPh
 
 Class where we will get a phone to save in parse later on, also this process can be skiped, meaning that is not a priority.
 
 extension UITextField.
    It is use to help us create the black bottom lines that appear in the phone number textfield
 
 Variables:
 
 Outlet weak var phoneCode - textField that will contain the country code of the phone
 Outlet weak var phoneNumber - textField that will contain the phone number
 
 Functions:
 
 viewDidLoad - Main func, it also contains the code to make the phonenumber and phonecode text fields had the button lines.
 
 sendToNextWPh - If the user select the button "Continuar", it will take the variables from phoneCode and phoneNumber with the rest of the information saved in the local var variables (password, email ...) and send to the next view, but this will be done by the messageComposeViewController, in here it will make sure that you can send messages and in case the user didnt write anything in the phone fields it will not let you continue.
 
 sendToNextWPn - If the user doesnt want to put its phone information right now, it can skip this step and will not make change to the values of the next view, only for the phone part.
 
 messageComposeViewController - It is the function that will take care of sending the message if it works and make the use the verification code to proceed then it will send the information to the nextView.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Alamofire

//MARK: MAIN CLASS

class singInMailPh: UIViewController, UITextFieldDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var phoneCode: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    //@IBOutlet weak var securityCodeTextField: UITextField!
    
    
    @IBOutlet weak var securityCodeView: UIView!
    @IBOutlet weak var firstSecurityCodeTextField: UITextField!
    @IBOutlet weak var secondSecurityCodeTextField: UITextField!
    @IBOutlet weak var thirdSecurityCodeTextField: UITextField!
    @IBOutlet weak var fourthSecurityCodeTextField: UITextField!
    
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: VARs/LETs
    
    //Variables modifiable by the previous view
    var email = ""
    var password = ""
    var username = ""
    var userDescription = ""
    var image = UIImage(named: "imageBackground")
    var phone_verificationCode = "" //The code to verify the phone number of the user
    var randomCode = 0
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        phoneCode.generalBottomLine()
        phoneNumber.generalBottomLine()
        
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
        self.continueButton.setTitle("CONTINUAR", for: .normal)
        
        self.securityCodeView.isHidden = true
        self.continueButton.alpha = 0.0
        
        self.phoneCode.layer.cornerRadius = 10
        self.phoneNumber.layer.cornerRadius = 10
        
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
    
    @IBAction func sendToNextwPh(_ sender: Any) {
        
        let securityCodeone = (self.firstSecurityCodeTextField.text ?? "0") + (self.secondSecurityCodeTextField.text ?? "0")
        
        let securityCodetwo = (self.thirdSecurityCodeTextField.text ?? "0") + (self.fourthSecurityCodeTextField.text ?? "0")
        
        let securityCode = securityCodeone + securityCodetwo
        
        if self.randomCode == Int(securityCode) {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singInMailId") as? singInMailId

            viewController?.email = self.email
            viewController?.password = self.password
            viewController?.username = self.username
            viewController?.userDescription = self.userDescription
            viewController?.image = self.image
            viewController?.phoneNumber = self.phoneNumber.text!
            viewController?.phoneCode = self.phoneCode.text!

            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "El código de verificación es incorrecto", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }
    
    //This method is for when the user select: Saltar por ahora
    
    @IBAction func sendToNextWoPn(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailId") as? singInMailId
        
        viewController?.email = email
        viewController?.password = password
        viewController?.username = username
        viewController?.userDescription = userDescription
        viewController?.image = image
        self.navigationController?.pushViewController(viewController!, animated: true)
        
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
