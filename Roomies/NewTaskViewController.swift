//
//  NewTaskViewController.swift
//  Roomies
//
//  Created by Alec Barlow, Gabe Ratcliff, Nigel Koh on 5/23/16.
//  Copyright © 2016 Alec Barlow, Gabe Ratcliff, Nigel Koh. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: NewTaskViewControllerDelegate?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var userArray: NSArray?
    var responsibleUsers = [String]()
    
    
    @IBOutlet weak var newTaskText: UITextField!
    
    @IBOutlet weak var newTaskDate: UIDatePicker!
    
    @IBOutlet weak var userTableView: UITableView!
    
    @IBOutlet weak var errorLabelText: UILabel!
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
        print("Back")
        self.newTaskText.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTableView.allowsMultipleSelection = true
//        let room = prefs.stringForKey("currentRoom")
        userTableView.dataSource = self
        userTableView.delegate = self
        
        errorLabelText.hidden = true
        
    }
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if newTaskText.text!.isEmpty {
            errorLabelText.text = "Task field is blank"
            return
        }
        if newTaskDate.date.timeIntervalSinceDate(NSDate()) <= 0 {
            errorLabelText.text = "Due date cannot be in the past"
            return
        }
        if responsibleUsers.count == 0 {
            errorLabelText.text = "No roomie was selected"
            return
        }
        
        let taskData = NSMutableDictionary()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = dateFormatter.stringFromDate(newTaskDate.date)
        
        taskData["objective"] = newTaskText.text!
        taskData["expiration_date"] = fromDate
        taskData["users"] = responsibleUsers
        taskData["_room"] = prefs.stringForKey("currentRoom")!
        print ("TASK DATA \n")
        print(taskData)
        TaskModel.addTask(taskData) {
            data, response, error in
            do {
                //                print(response)
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    print("TASK RETURNED")
                    print(jsonResult)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate?.newTaskViewController(self, didFinishAddingRoom: jsonResult)
                    })
                    
                }
                
            }catch {
                print(data)
                print(response)
                print(error)
            }
        }

        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = userTableView.dequeueReusableCellWithIdentifier("userChoiceCell")!
        cell.textLabel?.text =  userArray![indexPath.row]["name"] as? String
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor(red:197/255.0, green:224/255.0, blue:216/255.0, alpha: 1.0)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let userId = userArray![indexPath.row]["_id"] as! String
        responsibleUsers.append(userId)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        userTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let userId = userArray![indexPath.row]["_id"] as! String
        let userIndex = responsibleUsers.indexOf(userId)
        responsibleUsers.removeAtIndex(userIndex!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    
}
