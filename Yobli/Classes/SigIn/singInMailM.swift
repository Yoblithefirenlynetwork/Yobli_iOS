//
//  singInMailM.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/*MARK: MAIN INFORMATION
 
 Class singInMailM
 
 First class of the process to create an account using an e-mail.
 
 Variables:
 
 Outlet weak var termsAndConditions - TextView that it is empty and be later be fill to hold a clickable text (this one is the same in ViewController, refer to it if you have any doubts about how it works)
 
 Outlet weak var mailString - textField that will be used to get the email of the user
 
 Functions:
 
 viewDidLoad - Main func, it also contain the text that will be contained in the termsAndCondition variable.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
 isValidEmail - It is use to make sure the user is writting and email account and not other type of text.
 
 sendToNext - function connected to the button "Continuar", it will let the user go to the next view: "singInMailP", but will make sure an e-mail was put in the textField and is valid.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD

class singInMailM: UIViewController, UITextViewDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var termsAndConditions: UITextView!
    @IBOutlet weak var mailString: UITextField!
    
    // MARK: VARs/LETs
    
    var newEmail = ""
    
    // MARK: MAIN FUCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        termsAndConditions.delegate = self
        
        termsAndConditions.textColor = UIColor.init(hexString: "#0C0C0C")
        
        mailString.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.mailString.layer.cornerRadius = 10
        
    }
    
    enum LinkType: String {
        case termsAndConditions
        case privacyPolicy
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBOutlet weak var termsHyperlinkTextView: UITextView! {
        didSet {
            
            termsAndConditions.hyperLink(originalText: "Al presionar Crear cuenta o Iniciar sesión, aceptas nuestros Términos y Condiciones y nuestro Aviso de Privacidad.",
                                                linkTextsAndTypes: ["Términos y Condiciones": LinkType.termsAndConditions.rawValue,
                                                                     "Aviso de Privacidad": LinkType.privacyPolicy.rawValue])
                
            termsAndConditions.textAlignment = .center
            termsAndConditions.font = UIFont(name: "Avenir Medium", size: 13)
            termsAndConditions.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#087EFC")]
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func sendToNext(_ sender: UIButton) {
        
        //Check if the mailString is empty, if it is not it can be saved
        
        if( (mailString.text?.isEmpty)! ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado un correo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if(  self.isValidEmail(mailString.text!) ){
            
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = "Verificando..."
            
            let query : PFQuery = PFUser.query()!
            query.whereKey("email", equalTo:mailString.text!)
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                
                loader.hide(animated: true)
                
                if let objects = objects {
                    
                    //The email hasnt been use
                    
                    //Send the information to the next view and go to the next view
                    
                    if(objects.count == 0){
                    
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singInMailUN") as? singInMailUN
                        
                        viewController?.email = self.newEmail
                        self.navigationController?.pushViewController(viewController!, animated: true)
                        
                    }else{
                        
                        let alert = UIAlertController(title: "ERROR", message: "Ya hay un usuario registrado con ese correo", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else if let error = error{
                    // The find succeeded.
                    
                    let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        } else{
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado una dirección de correo correcta", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
//    // MARK: TEXTVIEW FUNCTIONS
//
//    //Terms And Condition func
//
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//
//        if URL.absoluteString == "1"{
//
//            UIApplication.shared.open(Foundation.URL(string: "https://brounie.com/public/files/Aviso-de-Privacidad.pdf")! as URL, options: [:], completionHandler: nil)
//
//        }
//
//        return false
//
//    }
    
    //MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let linkType = LinkType(rawValue: URL.absoluteString) {
            // TODO: handle linktype here with switch or similar.
            
            if linkType.rawValue == "termsAndConditions" {
                UIApplication.shared.open(Foundation.URL(string: "https://www.yobli.com/terminos")! as URL, options: [:], completionHandler: nil)
            }else if linkType.rawValue == "privacyPolicy" {
                UIApplication.shared.open(Foundation.URL(string: "https://www.yobli.com/privacidad")! as URL, options: [:], completionHandler: nil)
            }
        }
        return false
    }
    
    // MARK: OTHER FUNCTIONS
    
    //isValidEmail works to prove that the email is an email
    
    func isValidEmail(_ email: String) -> Bool {
        
        newEmail = email.replacingOccurrences(of: " ", with: "")
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: newEmail)
        
    }
}
