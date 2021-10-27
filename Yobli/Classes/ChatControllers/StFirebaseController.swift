//
//  StFirebaseController.swift
//  Yobli
//
//  Created by Brounie on 05/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StFirebaseController{
    
    static let shared = StFirebaseController()
    
    private let storage = Storage.storage().reference()
    
    //naming standard: images/email_profile_picture.jpeg
    
    public typealias uploadPictureComplete = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(data: Data, fileName: String, complete: @escaping(uploadPictureComplete)){
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else{
                print("Couldn't upload picture")
                complete(.failure(StorageError.failToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                
                guard let url = url else{
                
                    print("Fail to get URL")
                    complete(.failure(StorageError.failToGetDownloadURL))
                    return
                    
                }
                
                let urlString = url.absoluteString
                
                print("This is the download URL: "+urlString)
                complete(.success(urlString))
                
            })
            
        })
        
    }
    
    public func deleteImage(fileName: String, complete: @escaping(Bool) -> Void ){
        
        storage.child("images/\(fileName)").delete { error in
            
            guard error == nil else{
                
                print("It couldnt be delete it")
                complete(false)
                return
                
            }
            
            print("It was delete it")
            complete(true)
            
        }
        
    }
    
    public enum StorageError: Error{
        case failToUpload
        case failToGetDownloadURL
    }
    
    public func downloadURL(path: String, completion: @escaping (Result<URL, Error>) -> Void ){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            
            guard let url = url, error == nil else{
                completion(.failure(StorageError.failToGetDownloadURL))
                return
            }
            
            completion(.success(url))
            
        })
    }
    
}
