//
//  exploreBlogList.swift
//  Yobli
//
//  Created by Brounie on 07/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class exploreBlogList: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var blogTypesCollection: UICollectionView!
    
    @IBOutlet weak var blogListCollection: UICollectionView!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleDataLabel: UILabel!
    
    //MARK: VARs/LETs
    
    var blogType = PFObject(className: "BlogType")
    var blogListArray = [PFObject]()
    var blogTypeArray = [PFObject]()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.queries()
        
        blogTypesCollection.delegate = self
        blogListCollection.delegate = self
        blogTypesCollection.dataSource = self
        blogListCollection.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.noDataView.isHidden = false
        self.titleDataLabel.text = "Selecciona algún tipo de blog"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goToSearch(_ sender: UIButton) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "searchController") as? searchController
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    func queries(){
        
        //Queries to get from the Database
        
        let queryBlog = PFQuery(className:"Blog")
        print("blogType: \(self.blogType)")
        queryBlog.whereKey("type", equalTo: blogType)
        queryBlog.whereKey("active", equalTo: true)
        queryBlog.addDescendingOrder("view")
        
        queryBlog.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                
                if objects.count == 0 {
                    self.noDataView.isHidden = false
                    self.titleDataLabel.text = "No hay blogs disponibles por el momento"
                }else{
                    // The find succeeded.
                    self.blogListArray = objects
                    self.noDataView.isHidden = true
                    self.titleDataLabel.text = ""
                }
                
            }
            
            self.blogListCollection.reloadData()
            
        }
        
        let queryTypeOfBlogs = PFQuery(className: "BlogType")
        
        queryTypeOfBlogs.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                self.blogTypeArray = objects
            }
            
            self.blogTypesCollection.reloadData()
            
        }
        
    }
    
}

//MARK: EXTENSION COLLECTION VIEW

extension exploreBlogList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == blogTypesCollection){
            
            return blogTypeArray.count
            
        }
        
        return blogListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == blogTypesCollection){
            
            let cell2 = blogTypesCollection.dequeueReusableCell(withReuseIdentifier: "exploreBlogTypesCell", for: indexPath) as! exploreBlogTypesCell
            
            cell2.objects = blogTypeArray[indexPath.item]
            
            return cell2
            
        }
        
        let cell = blogListCollection.dequeueReusableCell(withReuseIdentifier: "exploreBlogListCell", for: indexPath) as! exploreBlogListCell
        
        cell.objects = blogListArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == blogListCollection){
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreBlog") as? exploreBlog
            
            guard let id = blogListArray[indexPath.item].objectId else{
                return
            }
            
            viewController?.blogId = id
            viewController?.isPDF = self.blogListArray[indexPath.item]["isPDF"] as? Bool ?? false
            
            let pdfFile = self.blogListArray[indexPath.item]["pdf"] as? PFFileObject
            viewController?.urlPDF = pdfFile?.url ?? ""
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
            
        }else if(collectionView == blogTypesCollection){
            
            blogType = blogTypeArray[indexPath.item]
            
            self.queries()
            
        }
        
    }
    
    //Section Header Up
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerCourse = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "exploreHeaderCollection4", for: indexPath) as! exploreHeaderCollection
        
        guard let title = blogType["name"] as? String else{
            
            headerCourse.typeTitle = ""
            
            return headerCourse
            
        }
        
        headerCourse.typeTitle = title
        
        return headerCourse
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == blogListCollection){
            
            let widthSize = collectionView.frame.width/2 - 20
            let heightSize = widthSize/2 + 15
            
            return CGSize(width: widthSize, height: heightSize)
            
        }else{
            
         let widthSize = 150
         let heightSize = 40
         
         return CGSize(width: widthSize, height: heightSize)
            
        }
        
    }
    
}
