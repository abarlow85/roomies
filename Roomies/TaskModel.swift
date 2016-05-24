//
//  TaskModel.swift
//  Roomie
//
//  Created by Gabe Ratcliff on 5/17/16.
//  Copyright © 2016 Gabe Ratcliff. All rights reserved.
//

import Foundation
class TaskModel {
    static func getSingleTask (task:String, completionHandler: (data:NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        print(task)
        let url = NSURL(string: "http://54.201.88.135/tasks/" + task)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    static func getTasksForRoom(room:String, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void){
        let url = NSURL(string: "http://54.201.88.135/rooms/" + room)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    static func getUserTasksForRoom(room:String, user:String, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void){
        let url = NSURL(string: "http://54.201.88.135/tasks/" + room + "/" + user)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    static func addTask(taskData:NSDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void){
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(taskData, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print(jsonString)
            if let url = NSURL(string: "http://54.201.88.135/tasks/create") {
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
                task.resume()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func removeTask(taskData:NSDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void){
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(taskData, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print(jsonString)
            if let url = NSURL(string: "http://54.201.88.135/tasks/remove") {
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
                task.resume()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func updateTaskToCompleted(taskData:NSDictionary, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void){
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(taskData, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print(jsonString)
            if let url = NSURL(string: "http://54.201.88.135/tasks/complete") {
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
                task.resume()
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
