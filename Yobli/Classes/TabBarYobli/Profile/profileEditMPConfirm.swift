//
//  profileEditMPConfirm.swift
//  Yobli
//
//  Created by Brounie on 30/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Firebase
import FirebaseAuth
import MBProgressHUD

class profileEditMPConfirm: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //MARK: VARs/LETs
    
    var decision = ""
    var uEmail = ""
    
    let support = supportView()
    
    //MARK: MAIN FUNCTIONS VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        emailField.generalBottomLine()
        passwordField.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func goReAuthenticate(_ sender: Any) {
        
        if( (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado un correo/o contraseña", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if( self.isValidEmail(emailField.text!) ){
            
            if( emailField.text! == uEmail ){
                
                self.reAunthenticateFirebase(email: emailField.text!, password: passwordField.text!)
                
            }else{
                
                let alert = UIAlertController(title: "ERROR", message: "La dirección de correo del usuario no coincide", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado una direccion de correo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    func reAunthenticateFirebase(email: String, password: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Comprobando..."
    
        let user = Auth.auth().currentUser
        
        let credential : AuthCredential = EmailAuthProvider.credential(withEmail: emailField.text!, password: passwordField.text!)

        // Prompt the user to re-provide their sign-in credentials

        user?.reauthenticate(with: credential, completion: {(authResult, error) in
            
            loader.hide(animated: true)
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else{
                // User re-authenticated.
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileEditMP") as? profileEditMP
                
                viewController?.decision = self.decision
                viewController?.uEmail = self.uEmail
            
                self.navigationController?.pushViewController(viewController!, animated: true)
                
            }
        })
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
