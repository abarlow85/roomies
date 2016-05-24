//
//  SocketIOManager.swift
//  Roomies
//
//  Created by Nigel Koh on 5/23/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://54.201.88.135")!)
    
    func establishConnection() {
        socket.connect()
        listenForOtherTasks()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
//    func connectToServerWithNickname(nickname: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
//        socket.emit("connectUser", nickname)
//        
//        socket.on("userList") { ( dataArray, ack) -> Void in
//            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
//        }
//    
//    }
    
//    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
//        socket.emit("exitUser", nickname)
//        completionHandler()
//    }
//    
    func sendTaskAlert(date: NSString, objective: String){
        socket.emit("newTaskAlert", date, objective)
    }
    
    func getTaskAlertAndScheduleNotification(completionHandler: (taskInfo: [String:AnyObject]) -> Void) {
        socket.on("getNewTaskAlert") { (dataArray, socketAck) -> Void in
            
            print("data array here:")
            var taskDictionary = [String: AnyObject]()
            print(dataArray)
            taskDictionary["date"] = dataArray[0]
            taskDictionary["objective"] = dataArray[1]
            completionHandler(taskInfo: taskDictionary)
        }
    }
    
    func sendTask(task: NSMutableDictionary) {
        print("tasks here...")
        print(task)
        let taskObjective = task["objective"] as! String
        var taskUsers = [NSDictionary]()
        let task_users = task["users"] as! NSArray
        for idx in 0..<task_users.count {
//            print("\(task_users[idx]["name"]!) is here")
            taskUsers.append(task_users[idx] as! NSDictionary)
        }
//        let taskUsers = task["users"] as! String
        let taskExpirationDate = task["expiration_date"] as! String
        socket.emit("task", taskObjective, taskUsers, taskExpirationDate)

    }
//
//    
    func getTask(completionHandler: (taskInfo: [String:AnyObject]) -> Void) {
        socket.on("newTask") { (dataArray, socketAck) -> Void in
            
            var taskDictionary = [String: AnyObject]()
            taskDictionary["objective"] = dataArray[0]
            taskDictionary["users"] = dataArray[1]
            taskDictionary["expiration_date"] = dataArray[2]
            print(dataArray)
//            let data = dataArray[0] as! String
            completionHandler(taskInfo: taskDictionary)
        }
    }
//
//    
    private func listenForOtherTasks() {
        socket.on("newTaskUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("newTaskWasAddedNotification", object: dataArray[0] as! String)
        }
        
//        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
//            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! [String: AnyObject])
//        }
//        
//        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
//            NSNotificationCenter.defaultCenter().postNotificationName("userWasDisconnectedNotification", object: dataArray[0] as! String)
//        }
//        
//        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
//            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: dataArray[0] as? [String: AnyObject])
//        }
    }
//
//    
//    func sendStartTypingMessage(nickname: String) {
//        socket.emit("startType", nickname)
//    }
//    
//    
//    func sendStopTypingMessage(nickname: String) {
//        socket.emit("stopType", nickname)
//    }
    
}
