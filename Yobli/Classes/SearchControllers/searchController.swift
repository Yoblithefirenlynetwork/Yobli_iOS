//
//  searchController.swift
//  Yobli
//
//  Created by Brounie on 02/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class searchController: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTable: UITableView!
    
    //MARK: VARs/LETs
    
    var listServices = [PFObject]()
    var listCourses = [PFObject]()
    var listVoluntaries = [PFObject]()
    var listBlogs = [PFObject]()
    var listUsers = [PFObject]()
    var counter = 0
    var arrayOfResults = [String]()
    
    //MARK: MAIN FUNCTION
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        resultsTable.delegate = self
        resultsTable.dataSource = self
        searchBar.delegate = self
        
        self.dismissWithSwipe()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        
        searchBar.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: QUERIES FUNCTION
    
    
    func queryCourse(text: String){
        
        let currentDate = Date()
        
        let query = PFQuery(className: "Course")
        
        query.whereKey("name", matchesRegex: text)
        query.whereKey("date", greaterThan: currentDate)
        query.addDescendingOrder("view")
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let objects = objects{
                
                if objects.count > 0{
                    
                    self.counter = self.counter + 1
                    self.arrayOfResults.append("Course")
                    self.listCourses = objects
                    
                }
                
                self.queryService(text: text)
                
            }else{
                
                self.queryService(text: text)
                
            }
            
        }
        
    }
    
    func queryService(text: String){
        
        let query = PFQuery(className: "Service")
        
        query.whereKey("name", matchesRegex: text)
        query.whereKey("private", equalTo: false)
        query.addDescendingOrder("view")
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let objects = objects{
                
                if objects.count > 0{
                    
                    self.counter = self.counter + 1
                    self.arrayOfResults.append("Service")
                    self.listServices = objects
                    
                }
                
                self.queryVoluntary(text: text)
                
            }else{
                
                self.queryVoluntary(text: text)
                
            }
            
        }
        
    }
    
    func queryVoluntary(text: String){
        
        let currentDate = Date()
        
        let query = PFQuery(className: "Voluntary")
        
        query.whereKey("name", matchesRegex: text)
        query.whereKey("date", greaterThan: currentDate)
        query.addDescendingOrder("view")
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let objects = objects{
                
                if objects.count > 0{
                    
                    self.counter = self.counter + 1
                    self.arrayOfResults.append("Voluntary")
                    self.listVoluntaries = objects
                    
                }
                
                self.queryBlog(text: text)
                
            }else{
                
                self.queryBlog(text: text)
                
            }
            
        }
        
    }
    
    func queryBlog(text: String){
        
        let query = PFQuery(className: "Blog")
        
        query.whereKey("name", matchesRegex: text)
        query.whereKey("active", equalTo: true)
        query.addDescendingOrder("view")
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let objects = objects{
                
                if objects.count > 0{
                    
                    self.counter = self.counter + 1
                    self.arrayOfResults.append("Blog")
                    self.listBlogs = objects
                    
                }
                
                self.queryUser(text: text)
                
            }else{
                
                self.queryUser(text: text)
                
            }
            
        }
        
    }
    
    func queryUser(text: String){
        
        let query : PFQuery = PFUser.query()!
        
        query.whereKey("name", matchesRegex: text)
        query.whereKey("yober", equalTo: true)
        query.addDescendingOrder("updatedAt")
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let objects = objects{
                
                if objects.count > 0{
                    
                    self.counter = self.counter + 1
                    self.arrayOfResults.append("User")
                    self.listUsers = objects
                    
                }
                
                self.resultsTable.reloadData()
                
                self.dismissHUD(isAnimated: true)
                
            }else{
                
                self.resultsTable.reloadData()
                
                self.dismissHUD(isAnimated: true)
                
            }
            
        }
        
    }
    
    
}

//MARK: SEARCHBAR EXTENSION

extension searchController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text{
            
            counter = 0
            arrayOfResults = []
            
            self.showHUD(progressLabel: "Cargando...")
            
            queryCourse(text: text)
            
        }
        
        self.dismissKeyboard()
        
    }
    
}

//MARK: TABLEVIEW EXTENSION

extension searchController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return counter
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch arrayOfResults[section] {
        case "Service":
            return listServices.count
        case "Course":
            return listCourses.count
        case "Voluntary":
            return listVoluntaries.count
        case "Blog":
            return listBlogs.count
        case "User":
            return listUsers.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            view.tintColor = UIColor.black
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
        } else {
            // User Interface is Light
            view.tintColor = UIColor.white
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.black
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch arrayOfResults[section] {
        case "Service":
            return "Servicio(s)"
        case "Course":
            return "Curso(s)"
        case "Voluntary":
            return "Voluntariado(s)"
        case "Blog":
            return "Blog(s)"
        case "User":
            return "Yober(s)"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch arrayOfResults[indexPath.section] {
        case "Service":
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            cell.object = listServices[indexPath.row]
            
            return cell
        case "Course":
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            cell.object = listCourses[indexPath.row]
            
            return cell
        case "Voluntary":
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            cell.object = listVoluntaries[indexPath.row]
            
            return cell
        case "Blog":
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            cell.object = listBlogs[indexPath.row]
            
            return cell
        case "User":
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            cell.object = listUsers[indexPath.row]
            
            return cell
        default:
            let cell = resultsTable.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultCell
            
            return cell
        }
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch arrayOfResults[indexPath.section] {
        case "Service":
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreService") as? exploreService
            
            guard let id = listServices[indexPath.row].objectId else{
                return
            }
            
            viewController?.serviceId = id
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        case "Course":
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse
            
            guard let id = listCourses[indexPath.row].objectId else{
                return
            }
            
            viewController?.courseId = id
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        case "Voluntary":
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreVoluntary") as? exploreVoluntary
            
            guard let id = listVoluntaries[indexPath.row].objectId else{
                return
            }
            
            viewController?.voluntaryId = id
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        case "Blog":
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreBlog") as? exploreBlog
            
            guard let id = listBlogs[indexPath.row].objectId else{
                return
            }
            
            viewController?.blogId = id
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        case "User":
            if let keyOfYober : String = listUsers[indexPath.row].value(forKey: "objectId") as? String{
            
                let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile
            
                viewController?.yoberId = keyOfYober
            
                self.navigationController?.pushViewController(viewController!, animated: true)
            
            }else{
            
                print("It didnt work")
            
            }
        default:
            print("Hi")
        }
    }
    
}

//MARK: EXTENSION HUD

extension searchController{
    
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
}
