//
//  logInRecoverP.swift
//  Yobli
//
//  Created by Humberto on 7/14/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class logInRecoverP
 
 Try to send an email to the user to recover password
 
 Variables:
 
 Outlet weak var userMail - The mail of the user
 
 Functions:
 
 viewDidLoad - Main func.
 
 getPasswordBack - Inside this class will be the specifications on what to do to reset the password
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */


import Foundation
import UIKit
import Parse
import Firebase
import FirebaseAuth
import MBProgressHUD

class logInRecoverP: UIViewController {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var userMail: UITextField!
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userMail.generalBottomLine()
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func getPasswordBack(_ sender: Any) {
        
        //Check if the userMail contains information
        
        if( (userMail.text?.isEmpty)! ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado un correo de usuario", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            //Send a request for reset the password
            
            guard let email = userMail.text else{
             
                print("Should happen because is not empty")
                return
                
            }
            
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = "Enviando correo..."
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                
                loader.hide(animated: true)
                
                if (error != nil) {
                    
                    let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }else {
                    
                    let alert = UIAlertController(title: "AVISO", message: "Un correo sera enviado a la dirección que proporcionó para reestablecer la contraseña", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default){ (_) in
                        
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }
                    
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
            
        }
    }
    
}
