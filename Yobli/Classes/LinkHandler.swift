//
//  LinkHandler.swift
//  Yobli
//
//  Created by Brounie on 06/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit

class LinkHandler{
    
    class func goTo(url: URL) -> UIViewController?{
        
        let urlOnlyPath = url.path
        
        let separator = "/"
        
        let tokens = urlOnlyPath.components(separatedBy: separator)
        
        //THREE TOKEN WILL BE CREATE: "", "type", "uniqueId"
        
        if(tokens.count != 3){
            
            return nil
            
        }
        
        let type = tokens[1]
        let uniqueId = tokens[2]
        
        //TAB
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbarTemp = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as? UITabBarController
        
        guard let tabbar = tabbarTemp else{
            
            return nil
            
        }
        
        tabbar.selectedIndex = 2
        
        if( type == "User" || type == "user" ){
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile {
                    
                    viewcontroller.yoberId = uniqueId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    return tabbar
                    
                }else{
                    
                    return nil
                    
                }
                
            }else{
                
                return nil
                
            }
            
            
        }else if( type == "Course" || type == "course" ){
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse {
                    
                    viewcontroller.courseId = uniqueId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    return tabbar
                    
                }else{
                    
                    return nil
                    
                }
                
            }else{
                
                return nil
                
            }
            
            
        }else if( type == "Service" || type == "service" ){
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreService") as? exploreService {
                    
                    viewcontroller.serviceId = uniqueId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    return tabbar
                    
                }else{
                    
                    return nil
                    
                }
                
            }else{
                
                return nil
                
            }
            
            
        }else if( type == "Voluntary" || type == "voluntary" ){
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreVoluntary") as? exploreVoluntary {
                    
                    viewcontroller.voluntaryId = uniqueId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    return tabbar
                    
                }else{
                    
                    return nil
                    
                }
                
            }else{
                
                return nil
                
            }
            
            
        }else if( type == "Blog" || type == "blog" ){
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreBlog") as? exploreBlog {
                    
                    viewcontroller.blogId = uniqueId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    return tabbar
                    
                }else{
                    
                    return nil
                    
                }
                
            }else{
                
                return nil
                
            }
            
            
        }else{
                
            return nil
            
        }
        
    }
    
}
