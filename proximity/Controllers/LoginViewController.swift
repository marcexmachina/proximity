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
import FirebaseAuth

class LoginViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var loginButton: UIButton!



  // Private properties

  let loginManager = LoginManager()



  // MARK: - Actions

  @IBAction func loginButtonPressed(_ sender: Any) {
    loginManager.logIn(readPermissions: [.publicProfile, .email, .userFriends], viewController: self) { loginResult in
      switch loginResult {
      case .failed(let error):
        print(error)
      case .cancelled:
        print("User cancelled login")
      case .success(grantedPermissions: _,  _, let accessToken):
        print("Logged in!")
        let authCredential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
        Auth.auth().signIn(with: authCredential) { (user, error) in
          guard error == nil else {
            print("Error signing in user: \(String(describing: accessToken.userId)). Error:: \(String(describing: error))")
            return
          }
          self.presentFriendFinderViewController()
        }
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
    guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as?
      UINavigationController else {
      return
    }
    present(navigationController, animated: true, completion: nil)
  }
}
