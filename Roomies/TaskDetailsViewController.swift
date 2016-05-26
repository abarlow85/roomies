//
//  TaskDetailsViewController.swift
//  Roomie
//
//  Created by Nigel Koh on 5/18/16.
//  Copyright © 2016 Nigel Koh. All rights reserved.
//

import UIKit

class TaskDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userTableView: UITableView!
//    weak var cancelButtonDelegate: CancelButtonDelegate?
    var taskdetails: String?
    var users = [NSDictionary]()
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func viewDidLoad() {
        userTableView.dataSource = self
        userTableView.delegate = self
        TaskModel.getSingleTask(taskdetails!) {
            data, response, error in
            do{
                if let task = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    let taskDescription = task["objective"] as! String
                    let taskDue = task["expiration_date"] as! String
                    let newUsers = task["users"] as! NSArray
                    for user in newUsers {
                        let newUser = user as! NSDictionary
                        self.users.append(newUser)
                    }
                    self.prefs.setValue(self.taskdetails, forKey: "currentTaskView")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.taskLabel.text = taskDescription
                        self.dueDateLabel.text = "Due Date: \(taskDue)"
                        self.userTableView.reloadData()
                    })
                    
                }
                
            }catch {
                print("Error")
            }
        }
        
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = userTableView.dequeueReusableCellWithIdentifier("taskUsersCell")!
        cell.textLabel?.text =  users[indexPath.row]["name"] as? String
        cell.textLabel?.font = UIFont(name: "Chalkduster", size: 17.0)
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor(red:77/255.0, green:182/255.0, blue:172/255.0, alpha: 1.0)
        return cell
    }
    
    
}
