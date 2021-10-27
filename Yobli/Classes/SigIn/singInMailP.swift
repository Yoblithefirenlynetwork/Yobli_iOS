//
//  singInMailP.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/*MARK: MAIN INFORMATION
 
 Class singInMailP
 
 Class where the password will be given.
 
 Variables:
 
 Outlet weak var termsAndConditions - TextView that it is empty and be later be fill to hold a clickable text (this one is the same in ViewController, refer to it if you have any doubts about how it works)
 
 Outlet weak var passwordString - textField that will be used to get the password of the user
 
 Functions:
 
 viewDidLoad - Main func, it also contain the text that will be contained in the termsAndCondition variable.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
 sendToNext - function connected to the button "Continuar", it will let the user go to the next view: "singInMailP2", but will make sure a password was put in the textField and is valid.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */


import Foundation
import UIKit

class singInMailP: UIViewController, UITextViewDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var passwordString: UITextField!
    
    @IBOutlet weak var termsAndConditions: UITextView!
    
    // MARK: VARs/LETs
    
    //Here are the variables that will get filled by the previous controller
    var email = ""
    var username = ""
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        termsAndConditions.delegate = self
        
        termsAndConditions.textColor = UIColor.init(hexString: "#0C0C0C")
        
        passwordString.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.passwordString.layer.cornerRadius = 10
        
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
        
        //Check if the passwordString is empty, if it is not it can be saved
        
        if( (passwordString.text?.isEmpty)! ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado una contraseña", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if(passwordString.text!.count < 6){
            
            let alert = UIAlertController(title: "ERROR", message: "La contraseña debe tener mínimo 6 carácteres", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        
        }else{
            
            //Send the information to the next view and go to the next view
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailP2") as? singInMailP2
            
            viewController?.email = email
            viewController?.username = username
            viewController?.password = passwordString.text!
            self.navigationController?.pushViewController(viewController!, animated: true)
            
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
    
    
}
