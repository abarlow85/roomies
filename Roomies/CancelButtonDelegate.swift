//
//  CancelButtonDelegate.swift
//  Roomies
//
//  Created by Alec Barlow on 5/20/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit

protocol CancelButtonDelegate: class {
    func cancelButtonPressedFrom(controller: UIViewController)
}