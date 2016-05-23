//
//  NewRoomViewControllerDelegate.swift
//  Roomies
//
//  Created by Alec Barlow, Gabe Ratcliff, Nigel Koh on 5/20/16.
//  Copyright © Alec Barlow, Gabe Ratcliff, Nigel Koh. All rights reserved.
//

import Foundation

protocol NewTaskViewControllerDelegate: class {
    func newTaskViewController(controller: NewTaskViewController, didFinishAddingRoom task: NSMutableDictionary)
}
