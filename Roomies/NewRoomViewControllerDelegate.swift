//
//  NewRoomViewControllerDelegate.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import Foundation

protocol NewRoomViewControllerDelegate: class {
    func newRoomViewController(controller: NewRoomViewController, didFinishAddingRoom room: NSMutableDictionary)
}
