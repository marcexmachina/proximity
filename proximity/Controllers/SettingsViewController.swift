//
//  SettingsViewController.swift
//  proximity
//
//  Created by Marc O'Neill on 14/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

  lazy var locationUtils = LocationUtils()

  @IBAction func allowLocationSwitchedPressed(_ sender: Any) {
    let locationSwitch = sender as! UISwitch
    if locationSwitch.isOn {
      locationUtils.trackLocation()
    }
  }
}
