//
//  ExploreReportViewController.swift
//  Yobli
//
//  Created by Francisco javier Moreno Torres on 21/06/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import UIKit
import Parse

class ExploreReportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var seendButton: UIButton!
    
    var objectIdYober = ""
    let user = PFUser.current()
    var isBlock = false
    var isReport = false
    var yobersBlock = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isReport == true {
            
            self.reportView.isHidden = false
            self.blockView.isHidden = true
            
            self.seendButton.setTitle("ENVIAR", for: .normal)
            
            reportTextView.delegate = self
            reportTextView.text = ""
            reportTextView.textColor = UIColor.lightGray
            
            self.reportTextView.layer.borderWidth = 1.0
            self.reportTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        if self.isBlock == true {
            
            self.reportView.isHidden = true
            self.blockView.isHidden = false
            
            self.seendButton.setTitle("BLOQUEAR", for: .normal)
            
            self.messageLabel.text = "Si bloqueas al Yober no podrá ver nada relacionado a el."
            
        }
        
        self.dismissWithSwipe()
        self.hideKeyboardWhenTappedAround()
    }
  
    //MARK: - Actions
    
    //MARK: SEND A REPORT FUNCION
    
    func sendTheReport(){
        
        
        let report = PFObject(className: "Report")
        
        let yoberId = PFObject(withoutDataWithClassName: "_User", objectId: self.objectIdYober)
        let userId = PFObject(withoutDataWithClassName: "_User", objectId: self.user?.objectId)
        
        report.setObject(yoberId, forKey: "reported")
        report.setObject(userId, forKey: "reporter")
        report.setObject(self.reportTextView.text, forKey: "details")
        report.setObject(true, forKey: "active")
        
        report.saveInBackground { (succeeded, error)  in
            if (succeeded) {
                let alert = UIAlertController(title: "AVISO", message: "Reporte enviado, gracias por ayudar a mejorar esta comunidad", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
                alert.addAction(action)
                    
                self.present(alert, animated: true, completion: nil)
            }else{
                print("error")
            }
        }
    }
    
    func sendBlockYober() {
        
        self.yobersBlock = self.user?["blockYobers"] as? [String] ?? [""]
        print("yoberBlock: \(self.yobersBlock)")
        let query = PFQuery(className:"_User")
        query.getObjectInBackground(withId: self.user?.objectId ?? "") { (user: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                self.yobersBlock.append(self.objectIdYober)
                user["blockYobers"] = self.yobersBlock
                user.saveInBackground()
                print("yoberBlock2: \(self.yobersBlock)")
            }
        }
    }

    
    //MARK: - Actions
    
    @IBAction func goBack(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    @IBAction func sendReport(_ sender: UIButton) {
        
        if self.isReport == true {
            if( (reportTextView.text?.isEmpty)! || reportTextView.text == ""){
                let alert = UIAlertController(title: "ERROR", message: "No se ha dado una razón", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }else{
                self.sendTheReport()
            }
        }
        if self.isBlock == true {
            self.sendBlockYober()
        }
    }
}
