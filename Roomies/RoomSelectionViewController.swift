//
//  RoomSelectionViewController.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

extension RoomSelectionViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class RoomSelectionViewController: UITableViewController, CancelButtonDelegate {
    
    @IBOutlet weak var RoomSearchBar: UISearchBar!
    
    var filteredRooms = [NSMutableDictionary]()
    let prefs = NSUserDefaults.standardUserDefaults()
    var rooms = [NSMutableDictionary]()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    override func viewDidLoad() {
        print("you are at select room page")
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        showAllRooms()
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredRooms.count
        }
        return rooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomSearchCell", forIndexPath: indexPath)
        let room: NSMutableDictionary
        if searchController.active && searchController.searchBar.text != "" {
            room = filteredRooms[indexPath.row]
        } else {
            room = rooms[indexPath.row]
        }
        cell.textLabel?.text = "\(room["name"]!) at \(room["category"]!)"
        cell.detailTextLabel?.text = room["category"] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let room: NSMutableDictionary
        if searchController.active && searchController.searchBar.text != "" {
            room = filteredRooms[indexPath.row]
        } else {
            room = rooms[indexPath.row]
        }
        prefs.setValue(room["_id"], forKey: "currentRoom")
        let roomId = prefs.valueForKey("currentRoom")! as! String
        let user = prefs.valueForKey("currentUser")! as! String
        let roomData = NSMutableDictionary()
        roomData["_id"] = roomId
        roomData["user"] = user
        addToRoom(roomData)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredRooms = rooms.filter { room in
            return room["name"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
        if segue.identifier !=
            "RoomSelectedSegue" {
            print("notSelectedSegue")
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewRoomViewController
            controller.cancelButtonDelegate = self
//            controller.delegate = self
        } else {
            print("else")
            let tabBarController = segue.destinationViewController as! UITabBarController
            let navController = tabBarController.viewControllers![0] as! UINavigationController
            let controller = navController.topViewController as! TaskViewController
//            controller.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Room Selection", style: .Plain, target: controller, action: Selector(controller.backToRoomSelection()))
        }
    }
    
    func showAllRooms(){
        RoomModel.getRooms(){
            data, response, error in
            do{
                if(data != nil){
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSMutableDictionary] {
                        self.rooms = jsonResult
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                }
                
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func addToRoom(roomData: NSMutableDictionary){
        RoomModel.selectRoom(roomData){
            data, response, error in
            do{
                if(data != nil){
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableArray {
                        print(jsonResult)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("RoomSelectedSegue", sender: jsonResult)
                        })
                    }
                }
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        print(controller)
        dismissViewControllerAnimated(true, completion: showAllRooms)
    }
    
//    func newRoomViewController(controller: NewRoomViewController, didFinishAddingRoom room: NSMutableDictionary) {
//        dismissViewControllerAnimated(false, completion: nil)
//        performSegueWithIdentifier("NewRoomAddedSegue", sender: room)
//        
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
