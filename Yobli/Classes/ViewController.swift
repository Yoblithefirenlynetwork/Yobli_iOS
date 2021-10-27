//
//  ViewController.swift
//  Yobli
//
//  Created by Humberto on 7/6/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/*
 
 Class ViewController
 
 Main class of the app Yobli
 
 It let you go to two new views: logInOptions or signInOptions, this wasnt done by code, it was done directly in the Main.storyboard, also let you get access to the Terms and Conditions of the Application.
 
 Variables:
 
    Outlet weak var termsAndConditions - TextView that it is empty and be later be fill to hold a clickable text
 
 Functions:
 
 viewDidLoad - Main func, it also contain the text that will be contained in the termsAndCondition variable.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
*/

import UIKit

class ViewController: UIViewController, UITextViewDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var termsAndConditions: UITextView!
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        termsAndConditions.delegate = self
        
        termsAndConditions.textColor = UIColor.init(hexString: "#0C0C0C")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
    
    @IBAction func logInOption(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "logInOptions") as? logInOptions
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func signInOption(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singInOptions") as? singInOptions
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    // MARK: TEXTVIEW FUNCTIONS
    
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//
//        //If the text pressed has the next value, and action will occur in this case, it will open the URL inside the if.
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

