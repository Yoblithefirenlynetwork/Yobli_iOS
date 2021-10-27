//
//  singInMailUN.swift
//  Yobli
//
//  Created by Brounie on 24/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit

class singInMailUN: UIViewController, UITextViewDelegate, UITextFieldDelegate{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var termsAndConditions: UITextView!
    @IBOutlet weak var usernameString: UITextField!
    
    //MARK: VARs/LETs
    
    var email = ""
    
    // MARK: MAIN FUCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        termsAndConditions.delegate = self
        
        termsAndConditions.textColor = UIColor.init(hexString: "#0C0C0C")
        
        usernameString.generalBottomLine()
        
        usernameString.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.usernameString.layer.cornerRadius = 10
        
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
        
        if( (usernameString.text?.isEmpty)! ){
            
            //Send a message that the username was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado un nombre de usuario", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else{
            
            if self.usernameString.text!.count <= 3 {
                let alert = UIAlertController(title: "ERROR", message: "El nombre debe tener más de 3 caracteres", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Acepar", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            }else{
                self.goToNextView(newUserName: self.usernameString.text!)
            }
        }
    }
    
    //MARK: EXTRA FUNCTIONS
    
    func goToNextView(newUserName: String){
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singInMailP") as? singInMailP
        
        viewController?.email = email
        viewController?.username = newUserName
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
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
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
//            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
//            let typedCharacterSet = CharacterSet(charactersIn: string)
//            let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
//            return alphabet
//        if string.rangeOfCharacter(from: .letters) != nil {
//                return true
//            }else {
//                return false
//            }
//      }
}
