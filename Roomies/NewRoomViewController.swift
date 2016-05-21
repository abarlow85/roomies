//
//  NewRoomViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

class NewRoomViewController: UITableViewController {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: NewRoomViewControllerDelegate?
    
    @IBOutlet weak var newRoomNameLabel: UITextField!
    @IBOutlet weak var newRoomCatLabel: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        print(sender)
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        //validation
        self.view.endEditing(true)
        if newRoomNameLabel.text!.isEmpty || newRoomCatLabel.text!.isEmpty {
            errorTextLabel.text = "All fields are required"
            errorTextLabel.hidden = false
            return
        }
        let roomData = NSMutableDictionary()
        roomData["name"] = newRoomNameLabel.text!
        roomData["category"] = newRoomCatLabel.text!
        roomData["user"] = prefs.stringForKey("currentUser")
        RoomModel.addRoom(roomData) { data, response, error in
            do {
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    print(jsonResult)
                    if let duplicateRoom = jsonResult["error"] as? String {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.errorTextLabel.text = duplicateRoom
                            self.errorTextLabel.hidden = false
                        })
                    } else {
                        let roomId = jsonResult["_id"]
                        self.prefs.setValue(roomId, forKey: "currentRoom")
                        print("roomId: \(jsonResult["_id"])")
                        self.delegate?.newRoomViewController(self, didFinishAddingRoom: jsonResult)
                    }
                    
                }

                
            } catch {
                print(data)
                print(response)
                print(error)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextLabel.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
