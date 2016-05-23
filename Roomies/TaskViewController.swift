//
//  TaskViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController, CancelButtonDelegate, NewTaskViewControllerDelegate {
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var roomTasks = [NSMutableDictionary]()
    var roomUsers = [NSMutableDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let room = prefs.stringForKey("currentRoom")!
        TaskModel.getTasksForRoom(room) { data, response, error in
            do {
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    //                    print("room information:")
                    //                    print(room)
                    let tasks = roomData["tasks"] as! [NSMutableDictionary]
                    self.roomTasks = tasks
                    
                    let users = roomData["users"] as! [NSMutableDictionary]
                    self.roomUsers = users
                    print(roomData["users"]!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
//                        self.update()
                        print(self.roomTasks)
                        self.tabBarController?.navigationItem.prompt = "\(roomData["name"]!)"
                    })
                }
            } catch {
                print("Something went wrong")
            }

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTaskSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewTaskViewController
            controller.userArray = roomUsers
            //            print(roomUsers)
            controller.cancelButtonDelegate = self
            controller.delegate = self
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as? TaskCell
        
        let users = roomTasks[indexPath.row]["users"] as! NSArray
        cell?.responsibleRoomiesLabel.text = stringifyResponsibleUsers(users)
        cell?.objectiveLabel.text = roomTasks[indexPath.row]["objective"] as? String
        cell?.dueDateLabel.text = roomTasks[indexPath.row]["expiration_date"] as? String
        
        return cell!
    }
    
    func newTaskViewController(controller: NewTaskViewController, didFinishAddingRoom task: NSMutableDictionary) {
        dismissViewControllerAnimated(true, completion: nil)
        print(task)
        roomTasks.append(task)
        self.tableView.reloadData()
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stringifyResponsibleUsers(users: NSArray) -> String {
        var userString = ""
//        print(users)
        for idx in 0..<users.count {
            let user = users[idx]["name"] as! String
            if users.count < 2 {
                userString += user
            } else if idx < users.count - 2 {
                userString += "\(user), "
            } else if idx == users.count - 2 {
                userString += "\(user) and "
            } else {
                userString += "\(user)"
            }
            
        }
        print(userString)
        
        return userString
    }
    
    
}
