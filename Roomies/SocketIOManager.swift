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
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:8000")!)
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServerWithNickname(nickname: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
        
//        listenForOtherMessages()
        
    }
    
//    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
//        socket.emit("exitUser", nickname)
//        completionHandler()
//    }
//    
    func sendTask(objective: String, withNickname nickname: String) {
        socket.emit("task", nickname, objective)
    }
//
//    
    func getTask(completionHandler: (taskInfo: [NSMutableDictionary]) -> Void) {
        socket.on("newTask") { (dataArray, socketAck) -> Void in
            var taskDictionary = [NSMutableDictionary]()
            taskDictionary[0]["objective"] = dataArray[0]
            taskDictionary[0]["users"] = dataArray[1]
            taskDictionary[0]["expiration_date"] = dataArray[2]
            
            completionHandler(taskInfo: taskDictionary)
        }
    }
//
//    
//    private func listenForOtherMessages() {
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
//    }
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
