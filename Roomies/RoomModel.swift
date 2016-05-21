//
//  RoomModel.swift
//  Roomie
//
//  Created by Nigel Koh on 5/17/16.
//  Copyright © 2016 Nigel Koh. All rights reserved.
//

import Foundation
import UIKit

class RoomModel {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    static func getRooms(completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        let url = NSURL(string: "http://localhost:8000/rooms")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    static func selectRoom(roomData: NSMutableDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void ) {
        
        if let url = NSURL(string: "http://localhost:8000/users/addtoroom") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let bodyData = "{\"_id\":\"\(roomData["_id"] as! String)\", \"user\":\"\(roomData["user"] as! String!)\"}"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
            
        }
        
    }
    
    static func addRoom(roomData: NSMutableDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void ) {
        
        if let url = NSURL(string: "http://localhost:8000/rooms/create") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let bodyData = "{\"name\":\"\(roomData["name"] as! String)\", \"category\":\"\(roomData["category"] as! String)\", \"user\":\"\(roomData["user"] as! String)\"}"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
            
        }
        
    }
    
}