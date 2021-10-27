//
//  exploreBlog.swift
//  Yobli
//
//  Created by Brounie on 07/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import WebKit

class exploreBlog: UIViewController{
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var blogImage: UIImageView!
    @IBOutlet weak var blogTitle: UILabel!
    @IBOutlet weak var blogsmallDescription: UILabel!
    @IBOutlet weak var blogAuthor: UILabel!
    @IBOutlet weak var blogDate: UILabel!
    @IBOutlet weak var blogDescription: UITextView!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var blogBodyView: UIView!
    @IBOutlet weak var webViewPDF: WKWebView!
    
    var blog = PFObject(className: "Blog")
    var blogId = ""
    var isPDF = false
    var urlPDF = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("blogId: \(blogId)")
        //self.dismissWithSwipe()
        
        if self.isPDF == false {
            self.blogBodyView.isHidden = false
            self.pdfView.isHidden = true
            self.initQuery(id: blogId)
        }else{
            self.blogBodyView.isHidden = true
            self.pdfView.isHidden = false
            
            let url: URL! = URL(string: self.urlPDF)
            print("url: \(url)")
            webViewPDF.load(URLRequest(url: url))
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    @IBAction func share(_ sender: Any) {
        
//        let urlCustom = URL(string: "https://yobli.brounieapps.com/Blog/\(blogId)" )
//
//        guard let customURL = urlCustom else {
//
//            print("Couldnt create url")
//
//            return
//
//        }
//
//        let av = UIActivityViewController(activityItems: [customURL], applicationActivities: nil)
//
//        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
        let someText:String = "Yobli"
        let objectsToShare:URL = URL(string: "https://parse.yobli.com/Blog/\(blogId)")!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]

        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: INIT QUERY
    
    func initQuery(id: String){
        
        let queryAlt = PFQuery(className: "Blog")
        
        queryAlt.whereKey("objectId", equalTo: id)
        
        queryAlt.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
                
            } else if let object = object {
                // The find succeeded.
                
                self.blog = object
                
                guard let views = self.blog["view"] as? Int else{
                    print("This should never happen")
                    return
                }
                
                self.blog["view"] = views + 1
                
                self.blog.saveInBackground()
                
                self.updateView()
            
            }
            
        }
        
    }
    
    //MARK: UPDATE VIEW
    
    func updateView(){
        
        guard let title = blog["name"] as? String, let subTitle = blog["subTitle"] as? String, let author = blog["author"] as? String, let date = blog["date"] as? Date, let content = blog["content"] as? String, let id = blog.objectId else{
            
            return
            
        }
        
        if let imageInformation = blog["logo"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.blogImage.image = image
                }
                
            }
            
        }else{
            
            self.blogImage.image = nil
            
        }
        
        blogTitle.text = title
        blogsmallDescription.text = subTitle
        blogAuthor.text = author
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateStyle = .short
        
        blogId = id
        
        let labelDate = dateFormatter.string(from: date)
        
        blogDate.text = labelDate
        blogDescription.text = content
        
        mainView.layoutIfNeeded()
        
    }
}
