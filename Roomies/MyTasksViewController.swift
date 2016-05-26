//
//  MyTasksViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/24/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

//
//  TaskViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

class MyTasksViewController: UITableViewController, CancelButtonDelegate, NewTaskViewControllerDelegate {
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var roomTasks = [NSMutableDictionary]()
    var roomUsers = [NSMutableDictionary]()
    var tasks = [[NSMutableDictionary]]()
    var nickname: String!
    var observer = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let room = prefs.stringForKey("currentRoom")!
        let currentUser = prefs.stringForKey("currentUser")!
        getUserTasksForRoom(room, user: currentUser)
        checkForObserver()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForObserver()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tasks = [roomTasks]
//        SocketIOManager.sharedInstance.getTask { (taskInfo) -> Void in
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                //                self.tasks.append(taskInfo)
//                //                self.tableView.reloadData()
//                //                self.scrollToBottom()

//                let user = self.prefs.stringForKey("currentUser")!
//                let users = taskInfo["users"] as! NSArray
//                for i in 0..<users.count {
//                    //                    print(users[i])
//                    if users[i]["_id"] as! String == user {
//                        print("otherView")
////                        self.alertNewTask()
//                    }
//                }
//                
//            })
//        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        if observer == true{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            observer = false
        } else {
            observer = true
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        if observer == true{
//            NSNotificationCenter.defaultCenter().removeObserver(self)
//            observer = false
//        } else {
//            observer = true
//        }
    }
    
    func checkForObserver() {
        if observer == false {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TaskViewController.handleTaskUpdateNotification(_:)), name: "TaskWasAddedNotification", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TaskViewController.updateData(_:)), name: "taskWasDeletedOrCompletedNotification", object: nil)
        }
        observer = true
    }
    
    func updateData(notification: NSNotification){
        print("updating data...")
        let room = prefs.stringForKey("currentRoom")!
        let currentUser = prefs.stringForKey("currentUser")!
        getUserTasksForRoom(room, user: currentUser)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
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
        if segue.identifier == "TaskDetailsSegue" {
            //            let controller = segue.destinationViewController as! TaskDetailsViewController
            let barViewController = segue.destinationViewController as! UITabBarController
            let navController = barViewController.viewControllers![0] as! UINavigationController
            let controller = navController.topViewController as! TaskDetailsViewController
            //            controller.cancelButtonDelegate = self
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                //                print(roomTasks[indexPath.row]["_id"])
                let id = roomTasks[indexPath.row]["_id"] as! String
                controller.taskdetails = id
            }
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
        
        let completed = self.roomTasks[indexPath.row]["completed"]! as! String
        if completed == "notcompleted" {
            cell?.objectiveLabel?.text = roomTasks[indexPath.row]["objective"] as! String
        } else {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roomTasks[indexPath.row]["objective"] as! String)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            cell?.objectiveLabel?.attributedText = attributeString;
            
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let task = self.roomTasks[indexPath.row]
            TaskModel.removeTask(task) {
                data, response, error in
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                        print(jsonResult)
                        self.roomTasks.removeAtIndex(indexPath.row)
                        dispatch_async(dispatch_get_main_queue(), {
                            SocketIOManager.sharedInstance.deleteOrCompleteTask()
                            self.tableView.reloadData()
                        })
                    }
                    
                } catch {
                    print("Something went wrong")
                }
                //                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
        
        let share = UITableViewRowAction(style: .Normal, title: "Completed") { (action, indexPath) in
            // complete item at indexPath
            let task = self.roomTasks[indexPath.row]
            TaskModel.updateTaskToCompleted(task){
                data, response, error in
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                        print(jsonResult)
                        SocketIOManager.sharedInstance.deleteOrCompleteTask()
                        self.roomTasks[indexPath.row]["completed"] = "completed"
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                    
                } catch {
                    print("Something went wrong")
                }
            }
            
        }
        
        share.backgroundColor = UIColor.blueColor()
        return [delete, share]
    }
    
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("TaskDetailsSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func newTaskViewController(controller: NewTaskViewController, didFinishAddingTask task: NSMutableDictionary) {
        dismissViewControllerAnimated(true, completion: nil)
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
        //        print(userString)
        
        return userString
    }
    
    
    //socket task update methods
    //    func showBannerLabelAnimated() {
    //        UIView.animateWithDuration(0.75, animations: { () -> Void in
    //            self.lblNewsBanner.alpha = 1.0
    //
    //        }) { (finished) -> Void in
    //            self.bannerLabelTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "hideBannerLabel", userInfo: nil, repeats: false)
    //        }
    //    }
    
//    func scrollToBottom() {
//        let delay = 0.1 * Double(NSEC_PER_SEC)
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
//            if self.tasks.count > 0 {
//                let lastRowIndexPath = NSIndexPath(forRow: self.tasks.count - 1, inSection: 0)
//                self.tableView.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
//            }
//        }
//    }
    
    func getUserTasksForRoom(room: String, user: String) {
        TaskModel.getUserTasksForRoom(room, user: user) { data, response, error in
            do {
                if let tasksData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSMutableDictionary] {
                    //                    print("room information:")
                    //                    print(room)
                    self.roomTasks = tasksData
                    
                    //                    let users = tasksData["users"] as! [NSMutableDictionary]
                    //                    self.roomUsers = users
                    //                    print(roomData["users"]!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        //                        self.update()
                        
                    })
                }
            } catch {
                print("Something went wrong")
            }
            
        }
        
        TaskModel.getTasksForRoom(room) { data, response, error in
            do {
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    //                    print("room information:")
                    //                    print(room)
                    let users = roomData["users"] as! [NSMutableDictionary]
                    self.roomUsers = users
//                    print(roomData["users"]!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        //                        self.update()
                        
                        self.title = "My Tasks: Room \(roomData["name"]!)"
                    })
                }
            } catch {
                print("Something went wrong")
            }
            
        }
    }
    
    func handleTaskUpdateNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let taskInfo = notification.object as! [String: AnyObject]
            let user = self.prefs.stringForKey("currentUser")!
            let users = taskInfo["users"] as! NSArray
            let objective = taskInfo["objective"] as! String
            let date = taskInfo["expiration_date"] as! NSString
            let room = self.prefs.stringForKey("currentRoom")!
            self.getTasksForRoom(room)
            self.tableView.reloadData()
//            self.scrollToBottom()
            print("share instance get task function")
            //                print(taskInfo)
            for i in 0..<users.count {
                if users[i]["_id"] as! String == user {
                    self.alertNewTask(objective, expiration: date)
                }
            }
        })
    }
    
    func alertNewTask(objective: String, expiration: NSString) {
        let alertController = UIAlertController(title: "New Task for you!", message: objective, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            //            alertController.dismissViewControllerAnimated(true, completion: nil)
            print("adding alert")
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        //        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getTasksForRoom(room:String) {
        TaskModel.getTasksForRoom(room) { data, response, error in
            do {
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    let tasks = roomData["tasks"] as! [NSMutableDictionary]
                    self.roomTasks = tasks
                    let users = roomData["users"] as! [NSMutableDictionary]
                    self.roomUsers = users
                    //                    print(roomData["users"]!)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        self.title = "Room \(roomData["name"]!)"
                    })
                }
            } catch {
                print("Something went wrong")
            }
        }
        
    }
    
}

