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

  // MARK: - Private properties

  private var friends: [Friend] = []



  // Properties

 var delegate: FriendFinderDelegate?



  // MARK: - Lifecycle

  override func viewDidLoad() {
    FacebookUtils.friends() { friends in
      self.friends = friends
      self.tableView.reloadData()
    }
  }


  // MARK: - UITableView

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.updateFriendToFind(withFriend: friends[indexPath.row])
    self.navigationController?.popViewController(animated: true)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return friends.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = "NAME:: \(friends[indexPath.row].name)"
    return cell
  }

  

}
