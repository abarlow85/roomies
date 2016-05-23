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
    var tasks = [[NSMutableDictionary]]()
    var nickname: String!
    
    
    @IBAction func roomSelectionButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("BackToRoomSelectionSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConnectedUserUpdateNotification:", name: "userWasConnectedNotification", object: nil)
//        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Room Selection", style: .Plain, target: self, action: roomSelectionButtonPressed((self.tabBarController?.navigationItem.leftBarButtonItem)!))
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tasks = [roomTasks]
        SocketIOManager.sharedInstance.getTask { (taskInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tasks.append(taskInfo)
                self.tableView.reloadData()
                self.scrollToBottom()
            })
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TaskCell")
        
        return cell!
    }
    
    func backToRoomSelection() {
        performSegueWithIdentifier("BackToRoomSelectionSegue", sender: self)
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.tasks.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.tasks.count - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
}
