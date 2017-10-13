//
//  FriendListViewController.swift
//  proximity
//
//  Created by Marc O'Neill on 13/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import UIKit
import Foundation

class FriendListViewController: UITableViewController {

  // MARK: - Lifecycle

  override func viewDidLoad() {
    FacebookUtils.friends()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.detailTextLabel?.text = "Test"
    return cell
  }

  

}
