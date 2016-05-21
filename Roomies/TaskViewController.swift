//
//  TaskViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController {
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var roomTasks = [NSMutableDictionary]()
    var roomUsers = [NSMutableDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let room = prefs.stringForKey("currentRoom")!
        TaskModel.getTasksForRoom(room) { data, response, error in
            do {
                if let room = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    //                    print("room information:")
                    //                    print(room)
                    let tasks = room["tasks"] as! [NSMutableDictionary]
                    self.roomTasks = tasks
                    
                    let users = room["users"] as! [NSMutableDictionary]
                    self.roomUsers = users
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
//                        self.update()
                        print(self.roomTasks)
                    })
                }
            } catch {
                print("Something went wrong")
            }

        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TaskCell")
        
        return cell!
    }
    
    
}
