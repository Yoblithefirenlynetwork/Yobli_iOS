//
//  agendaClientReport.swift
//  Yobli
//
//  Created by Brounie on 18/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class agendaClientReport: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var reportExplanation: UITextView!
    @IBOutlet weak var reportReason: UILabel!
    @IBOutlet weak var reportReasonDisplay: UIButton!
    
    //MARK: VARs/LETs
    
    let reason : [String] = ["Comportamiento Indebido", "Inasistencia injustificada", "Soborno por Calificación", "Comportamiento Racista"]
    
    var selectedButton = UIButton()
    let tableList = UITableView()
    let transparentView = UIView()
    
    var selectionDone = false
    var reportDetails = ""
    var reportReasonResult = ""
    
    var reportedId = ""
    
    var report = PFObject(className: "Report")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        reportExplanation.delegate = self
        reportExplanation.text = "Detalles"
        reportExplanation.textColor = UIColor.lightGray
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")

        self.dismissWithSwipe()
        
        self.reportExplanation.layer.borderColor = UIColor.gray.cgColor
        self.reportExplanation.layer.borderWidth = 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
            
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func displayReasons(_ sender: UIButton) {
        
        selectedButton = reportReasonDisplay
        
        fillTable(frames: reportReasonDisplay.frame, number: reason.count)
        
    }

    @IBAction func sendReport(_ sender: UIButton) {
        
        if( checkDetails() == true ){
        
            let alert = UIAlertController(title: "ATENCIÓN", message: "Estás a punto de mandar un reporte, ¿estás seguro/a?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
                
                self.sendTheReport()
                
            }
            
            alert.addAction(action)
                
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha seleccionado una razón por la que se esta haciendo el reporte", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: CHECK FUNCTION
    
    func checkDetails() -> Bool{
        
        if( selectionDone == true ){
            
            reportReasonResult = self.reportReason.text!
            
            if( reportExplanation.text == nil || reportExplanation.text == "Detalles" ){
                
                reportDetails = ""
                
            }else{
                
                reportDetails = reportExplanation.text!
                
            }
            
            
            return true
            
        }else{
            
            return false
            
        }
        
    }
    
    //MARK: SEND A REPORT FUNCION
    
    func sendTheReport(){
        
        guard let user = PFUser.current() else{
         
            self.sendAlert()
            return
            
        }
        
        let userQuery : PFQuery = PFUser.query()!
        
        userQuery.whereKey("objectId", equalTo: reportedId)
        
        userQuery.getFirstObjectInBackground { (reported, error) in
            
            if let error = error{
                
                self.sendErrorType(error: error)
                
            }else if let reported = reported{
                
                self.report.setObject(reported, forKey: "reported")
                self.report.setObject(user, forKey: "reporter")
                self.report.setObject(self.reportReasonResult, forKey: "reason")
                self.report.setObject(self.reportDetails, forKey: "details")
                self.report.setObject(true, forKey: "active")
                
                self.report.saveInBackground { (result, error) in
                    
                    if let error = error{
                        
                        self.sendErrorType(error: error)
                        
                    }else{
                        
                        let alert = UIAlertController(title: "AVISO", message: "Reporte enviado, gracias por ayudar a mejorar esta comunidad", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
                            
                            _ = self.navigationController?.popViewController(animated: true)
                            
                        }
                        
                        alert.addAction(action)
                            
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    // MARK: TABLE FUNCTIONS
    
    func fillTable(frames: CGRect, number: Int){
        
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        
        if #available(iOS 13.0, *) {
            transparentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.02)
        } else {
            // Fallback on earlier versions
            transparentView.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView) )
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.view.addSubview(tableList)
        
        tableList.layer.cornerRadius = 0.5
        
        tableList.reloadData()
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView))
        
        //self.view.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0.02
            
            if ( number >= 3){
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 150)
                
            }else{
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(number * 50))
                
            }
            
            
            
        }, completion: nil)
        
        
    }
    
    @objc func removeTableView(){
        
        let frames = selectedButton.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0
            
            self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
            
            }, completion: nil)
        
    }
    
}

//MARK: TABLEVIEW EXTENSION

extension agendaClientReport: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.reason.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.textLabel?.text = reason[indexPath.row]
        cell.textLabel?.font = reportReason.font
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        reportReason.text = reason[indexPath.row]
        selectionDone = true
        
        self.removeTableView()
        
    }
    
}

//MARK: TEXTVIEW EXTENSION

extension agendaClientReport: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                textView.textColor = UIColor.white
            } else {
                // User Interface is Light
                textView.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = "Detalles"
            textView.textColor = UIColor.lightGray
        }
    }
    
}
