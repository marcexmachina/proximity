//
//  LoginViewController.swift
//  proximity
//
//  Created by Marc O'Neill on 13/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import UIKit

import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var loginButton: UIButton!


  // MARK: - Actions

  @IBAction func loginButtonPressed(_ sender: Any) {
    let loginManager = LoginManager()
    loginManager.logIn([ .publicProfile, .email, .userFriends], viewController: self) { loginResult in
      switch loginResult {
      case .failed(let error):
        print(error)
      case .cancelled:
        print("User cancelled login")
      case .success(grantedPermissions: let grantedPermissions, let declinedPermissions, let accessToken):
        print("Logged in!")
        self.presentFriendFinderViewController()
      }
    }
  }

  // MARK: - Lifecycle Methods

  override func viewDidLoad() {
    if let _ = AccessToken.current {
      presentFriendFinderViewController()
    }
  }

  // MARK: - Private methods

  private func presentFriendFinderViewController() {
    guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {
      return
    }

    present(navigationController, animated: true, completion: nil)
  }
}
