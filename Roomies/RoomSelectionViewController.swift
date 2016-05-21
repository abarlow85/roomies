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

class RoomSelectionViewController: UITableViewController, CancelButtonDelegate, NewRoomViewControllerDelegate {
    
    @IBOutlet weak var RoomSearchBar: UISearchBar!
    
    var filteredRooms = [NSMutableDictionary]()
    let prefs = NSUserDefaults.standardUserDefaults()
    var rooms = [NSMutableDictionary]()
    let searchController = UISearchController(searchResultsController: nil)
    
//    var rooms = [
//            Room(category: "UC Berkeley", name: "123"),
//            Room(category: "UC Berkeley", name: "321"),
//            Room(category: "UC Berkeley", name: "541"),
//            Room(category: "UC Berkeley", name: "875"),
//            Room(category: "UC Berkeley", name: "122"),
//            Room(category: "UC Davis", name: "1"),
//            Room(category: "UC Davis", name: "2"),
//            Room(category: "Coding Dojo", name: "iOS")
//        ]
    
    
    
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
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredRooms = rooms.filter { room in
            return room["name"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "RoomSelectedSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewRoomViewController
            controller.cancelButtonDelegate = self
            controller.delegate = self
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
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        print(controller)
        dismissViewControllerAnimated(true, completion: showAllRooms)
    }
    
    func newRoomViewController(controller: NewRoomViewController, didFinishAddingRoom room: NSMutableDictionary) {
        print(controller)
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("RoomSelectedSegue", sender: room)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
