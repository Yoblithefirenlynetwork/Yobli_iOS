//
//  ParseErrorHandler.swift
//  Yobli
//
//  Created by Brounie on 05/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FirebaseAuth
import Firebase

//MARK: ERROR CODES PARSE

/*

 ** 100: The Internet connection appears to be offline.
 ** 101: No results matched the query
 ** 130: Invalid file upload
 ** 209: Invalid Session Token
 
*/

class ParseErrorHandler{
    
    class func handleParseError(error: Error) -> UIAlertController{
        
        let nsError = error as NSError
        
        switch (nsError.code) {
        case 209:
            return handleInvalidSessionToken(error: error, nsError: nsError)
        default:
            return handleOtherErrors(error: error, nsError: nsError)
        }
        
    }
    
    class func handleParseErrorExpected(error: Error) -> UIAlertController?{
        
        let nsError = error as NSError
        
        switch (nsError.code) {
        case 209:
            return handleInvalidSessionToken(error: error, nsError: nsError)
        default:
            return nil
        }
        
    }
    
    private class func handleInvalidSessionToken(error: Error, nsError: NSError) -> UIAlertController{
        
        let alert = UIAlertController(title: "ERROR \(nsError.code)", message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default){ (_) in
            
            PFUser.logOut()
            
            let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            let nav = UINavigationController(rootViewController: goTo)
            
            nav.isNavigationBarHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = nav
            
        }
        
        alert.addAction(action)
        
        return alert
        
    }
    
    private class func handleOtherErrors(error: Error, nsError: NSError) -> UIAlertController{
        
        let alert = UIAlertController(title: "ERROR: \(nsError.code)", message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Cerrar", style: .cancel, handler: nil)
        
        alert.addAction(action)
            
        return alert
        
    }
    
    public class func handleConektaError(error: Error) -> UIAlertController{
        
        let alert = UIAlertController(title: "ERROR CONEKTA", message: "\(error)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Cerrar", style: .cancel, handler: nil)
        
        alert.addAction(action)
            
        return alert
        
    }
    
}

extension UIViewController{
 
    func sendAlert(){
        
        PFUser.logOut()
        
        let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let nav = UINavigationController(rootViewController: goTo)
        
        nav.isNavigationBarHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
        
        let alert = UIAlertController(title: "ATENCIÓN", message: "La sesión ha expirado/o no ha iniciado sesión", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
            
        nav.present(alert, animated: true, completion: nil)
    
    }
    
    func notDIrection(){
        
        let alert = UIAlertController(title: "Aviso", message: "No puedes reservar hasta completar la información de tu perfil y agregar una dirección válida", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func sendErrorType(error: Error){
        
        let newAlert = ParseErrorHandler.handleParseError(error: error)
        
        self.present(newAlert, animated: true, completion: nil)
        
    }
    
    func sendErrorFromConekta(error: Error){
        
        let newAlert = ParseErrorHandler.handleConektaError(error: error)
        
        self.present(newAlert, animated: true, completion: nil)
        
    }
    
    func sendErrorTypeExpected(error: Error){
        
        let newAlert = ParseErrorHandler.handleParseErrorExpected(error: error)
        
        guard let alert = newAlert else{
            
            print(error.localizedDescription)
            
            return
            
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func sendErrorTypeAndDismiss(error: Error){
        
        let nsError = error as NSError
        
        switch (nsError.code) {
        case 209:
            let alert = ParseErrorHandler.handleParseError(error: error)
            self.present(alert, animated: true, completion: nil)
        default:
            let alert = UIAlertController(title: "ERROR: \(nsError.code)", message: error.localizedDescription, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Cerrar", style: .default){ (_) in
                
                _ = self.navigationController?.popViewController(animated: true)
                
            }
            
            alert.addAction(action)
                
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    func customError(description: String){
        
        let alert = UIAlertController(title: "ERROR", message: description, preferredStyle: .alert)
                    
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}
