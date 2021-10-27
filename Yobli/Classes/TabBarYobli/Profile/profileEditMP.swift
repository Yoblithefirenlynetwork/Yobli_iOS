//
//  profileEditMP.swift
//  Yobli
//
//  Created by Brounie on 30/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit
import Firebase
import FirebaseAuth
import MBProgressHUD

class profileEditMP: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var titleField: UILabel!
    
    //MARK: VARs/LETs
    
    var decision = ""
    var uEmail = ""
    
    let support = supportView()
    
    //MARK: MAIN FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        
        confirmTextField.generalBottomLine()
        newTextField.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        
        if( (newTextField.text?.isEmpty)! || (confirmTextField.text?.isEmpty)! ){
            
            self.printPerError(error: "Un campo no ha sido completado")
            
        }else if ( (newTextField.text!) != (confirmTextField.text!) ){
            
            self.printPerError(error: "Los campos no son iguales")
            
        }else{
            
            if( decision == "Email" ){
        
                if( self.isValidEmail(newTextField.text!) ){
                    
                    if( newTextField.text! != uEmail ){
                        
                        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
                        loader.mode = MBProgressHUDMode.indeterminate
                        loader.backgroundView.color = UIColor.gray
                        loader.backgroundView.alpha = 0.5
                        loader.label.text = "Verificando..."
                        
                        let query : PFQuery = PFUser.query()!
                        query.whereKey("email", equalTo: self.newTextField.text!)
                        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                            
                            loader.hide(animated: true)
                            
                            if let objects = objects {
                                
                                //The email hasnt been use
                                
                                if(objects.count == 0){
                                
                                    self.updateEmailFireBase(email: self.newTextField.text!)
                                    
                                }else{
                                    
                                    self.printPerError(error: "Ya hay un usuario registrado con ese correo")
                                    
                                }
                                
                            } else if let error = error{
                                // The find succeeded.
                                
                                self.printError(error: error)
                                
                            }
                            
                        }
                        
                    }else{
                        
                        self.printPerError(error: "La dirección de correo no es nueva")
                        
                    }
                    
                }else{
                    
                    self.printPerError(error: "No se ha insertado una direccion de correo")
                    
                }
                
            }else{
                
                if( newTextField.text!.count > 5){
                    
                    self.updatePasswordFireBase(password: newTextField.text!)
                    
                }else{
                    
                    self.printPerError(error: "El tamaño de la contraseña es muy corta, mínimo 6 carácteres")
                    
                }
                
                
            }
            
        }
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        if (decision == "Email"){
            
            newTextField.placeholder = "Nuevo correo"
            confirmTextField.placeholder = "Confirmar nuevo correo"
            titleField.text = "CAMBIAR CORREO"
            
        }else{
            
            newTextField.placeholder = "Nueva contraseña"
            confirmTextField.placeholder = "Confirmar nueva contraseña"
            newTextField.isSecureTextEntry = true
            confirmTextField.isSecureTextEntry = true
            titleField.text = "CAMBIAR CONTRASEÑA"
            
        }
        
    }
    
    //MARK: UPDATE EMAIL FUNCTIONS
    
    func updateEmailFireBase(email: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Comprobando cambio"
        
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
          
            loader.hide(animated: true)
            
            if let error = error{
                
                self.printError(error: error)
                
            }else{
                
                self.updateEmailParse(email: email)
                
            }
            
        }
    }
    
    func updateEmailParse(email: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando..."
        
        let user = PFUser.current()!
        
        user.email = email
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            loader.hide(animated: true)
            
            if let error = error{
                
                self.printError(error: error)
                
            }else if success != nil{
                
                self.printSuccess(message: "Nuevo correo guardado con éxito")
                
            }
            
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK: UPDATE PASSWORD FUNCTIONS
    
    func updatePasswordFireBase(password: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Comprobando..."
        
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
          
            loader.hide(animated: true)
            
            if let error = error{
                
                self.printError(error: error)
                
            }else{
                
                self.updatePasswordParse(password: password)
                
            }
            
        }
    }
    
    func updatePasswordParse(password: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando"
        
        let currentUser = PFUser.current()!
        
        currentUser.password = self.support.dummyPassword
            
        currentUser.saveInBackground {  (success: Bool?, error: Error?) in
            
            loader.hide(animated: true)
            
            if let error = error{
                
                self.printError(error: error)
                
            }else if success != nil{
                
                PFUser.logInWithUsername(inBackground: currentUser.email!, password: currentUser.password!) { (user, error) in
                    
                    if let error = error{
                        
                        self.printError(error: error)
                        
                    }else if user != nil{
                    
                        self.printSuccess(message: "Nueva contraseña guardada con éxito")
                        
                    }
                }
                
            }
            
        }
        
    }
    
    //MARK: ALERT FUNCTIONS
    
    func printError(error: Error){
        
        let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func printPerError(error: String){
        
        let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func printSuccess(message: String){
        
        let alert = UIAlertController(title: "ÉXITO", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
            
            let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
            
            goTo.selectedIndex = 4
            
            let nav = UINavigationController(rootViewController: goTo )
            nav.isNavigationBarHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = nav
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
