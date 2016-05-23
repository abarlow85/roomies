//
//  NewTaskViewControllerDelegate.swift
//  Roomies
//
//  Created by Alec Barlow on 5/23/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import Foundation

protocol NewTaskViewControllerDelegate: class {
    func newTaskViewController(controller: NewTaskViewController, didFinishAddingTask task: NSMutableDictionary)
}