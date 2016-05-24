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
    var tasks = [[NSMutableDictionary]]()
    var nickname: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let room = prefs.stringForKey("currentRoom")!
        getTasksForRoom(room)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        setupNotificationSettings()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tasks = [roomTasks]
        SocketIOManager.sharedInstance.getTask { (taskInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                print("task info: \(taskInfo)")
                let user = self.prefs.stringForKey("currentUser")!
                let users = taskInfo["users"] as! NSArray
                let objective = taskInfo["objective"] as! String
                let date = taskInfo["expiration_date"] as! NSString
                for i in 0..<users.count {
                    if users[i]["_id"] as! String == user {
                        self.alertNewTask(objective, expiration: date)
                    }
                }
                let room = self.prefs.stringForKey("currentRoom")!
                self.getTasksForRoom(room)
                self.tableView.reloadData()
                self.scrollToBottom()
            })
        }
        
        SocketIOManager.sharedInstance.getTaskAlertAndScheduleNotification { (taskInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let objective = taskInfo["objective"] as! String
                let date = taskInfo["date"] as! String
                let dateString = date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateFromString = dateFormatter.dateFromString(dateString)
                print("scheduling local notification...")
                self.scheduleLocalNotification(dateFromString!, withText: objective)
            })
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTaskSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewTaskViewController
            controller.userArray = roomUsers
            controller.cancelButtonDelegate = self
            //            print(roomUsers)
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
        
        return cell!
    }
    
    func newTaskViewController(controller: NewTaskViewController, didFinishAddingTask task: NSMutableDictionary) {
        dismissViewControllerAnimated(true, completion: nil)
        roomTasks.append(task)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("TaskDetailsSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stringifyResponsibleUsers(users: NSArray) -> String {
        var userString = ""
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
        return userString
    }
    
    func alertNewTask(objective: String, expiration: NSString) {
        let alertController = UIAlertController(title: "New Task for you!", message: objective, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            print("adding alert")
        }
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
        
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
    

    func getTasksForRoom(room:String) {
        TaskModel.getTasksForRoom(room) { data, response, error in
            do {
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    let tasks = roomData["tasks"] as! [NSMutableDictionary]
                    self.roomTasks = tasks
                    let users = roomData["users"] as! [NSMutableDictionary]
                    self.roomUsers = users
                    print(roomData["users"]!)
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
    
    func scheduleLocalNotification(date: NSDate, withText: String) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = fixNotificationDate(date)
        localNotification.alertBody = withText
        localNotification.alertAction = "Dismiss"
        localNotification.category = "taskReminderCategory"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        let dateComponents: NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.NSDayCalendarUnit, NSCalendarUnit.NSMonthCalendarUnit, NSCalendarUnit.NSYearCalendarUnit, NSCalendarUnit.NSHourCalendarUnit, NSCalendarUnit.NSMinuteCalendarUnit], fromDate: dateToFix)
        dateComponents.second = 0
        let fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
        return fixedDate
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge]
            
            // Specify the notification actions.
            var justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "OK, got it"
            justInformAction.activationMode = UIUserNotificationActivationMode.Background
            justInformAction.destructive = false
            justInformAction.authenticationRequired = false
            
            var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "Edit list"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = true
            
            let actionsArray = NSArray(objects: justInformAction, modifyListAction)
            let actionsArrayMinimal = NSArray(objects: modifyListAction)
            
            // Specify the category related to the above actions.
            var taskReminderCategory = UIMutableUserNotificationCategory()
            taskReminderCategory.identifier = "taskReminderCategory"
            taskReminderCategory.setActions(actionsArray as! [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Default)
            taskReminderCategory.setActions(actionsArrayMinimal as! [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Minimal)
            
            let categoriesForSettings = NSSet(objects: taskReminderCategory)
            
            // Register the notification settings.
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as! Set<UIUserNotificationCategory>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
}
