//
//  UserModel.swift
//  Roomies
//
//  Created by Alec Barlow, Gabe Ratcliff, Nigel Koh on 5/20/16.
//  Copyright © 2016 Alec Barlow, Gabe Ratcliff, Nigel Koh. All rights reserved.
//

import Foundation

class UserModel {
    
    static func registerUser(userData: NSMutableDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void ) {
        
        print(userData);
        if let url = NSURL(string: "http://54.201.88.135/register") {
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "POST"
            let bodyData = "{\"name\":\"\(userData["name"] as! String)\", \"email\":\"\(userData["email"] as! String)\", \"password\":\"\(userData["password"] as! String)\"}"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
            
        }
        
    }
    
    static func loginUser(userData: NSMutableDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void ) {
        
        if let url = NSURL(string: "http://54.201.88.135/login") {
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "POST"
            let bodyData = "{\"email\":\"\(userData["email"] as! String)\", \"password\":\"\(userData["password"] as! String)\"}"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
            
        }
        
    }
    
}

