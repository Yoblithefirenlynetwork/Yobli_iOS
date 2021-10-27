//
//  serviceYoberMain.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class serviceYoberMain: UIViewController{
    
    @IBOutlet weak var curseButton: UIButton!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var voluntaryButton: UIButton!
    
    var reservation = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initStrings()
        self.initDetail()
        
    }
    
    //MARK: - initStrings
    
    func initStrings() {
    
        self.curseButton.setTitle("Cursos", for: .normal)
        self.serviceButton.setTitle("Servicios", for: .normal)
        self.voluntaryButton.setTitle("Voluntariados", for: .normal)
        
    }
    
    func initDetail() {
        self.curseButton.backgroundColor = UIColor.init(hexString: "#FF32A5")
        self.curseButton.layer.cornerRadius = 20
        self.curseButton.setTitleColor(UIColor.white, for: .normal)
        
        self.serviceButton.backgroundColor = UIColor.init(hexString: "#00D7FE")
        self.serviceButton.layer.cornerRadius = 20
        self.serviceButton.setTitleColor(UIColor.white, for: .normal)
        
        self.voluntaryButton.backgroundColor = UIColor.init(hexString: "#FFE231")
        self.voluntaryButton.layer.cornerRadius = 20
        self.voluntaryButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    //MARK: - Actions
    
    @IBAction func curseButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "serviceYoberServicesViewController") as? serviceYoberServicesViewController
        
        viewController?.type = "Course"
        viewController?.titleString = "Cursos"
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    @IBAction func serviceButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "serviceYoberServicesViewController") as? serviceYoberServicesViewController
        
        viewController?.type = "Service"
        viewController?.titleString = "Servicios"
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func voluntaryButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "serviceYoberServicesViewController") as? serviceYoberServicesViewController
        
        viewController?.type = "Voluntary"
        viewController?.titleString = "Voluntariados"
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
}

