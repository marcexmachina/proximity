//
//  DatabaseManager.swift
//  proximity
//
//  Created by Marc O'Neill on 14/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FacebookCore

class DatabaseManager {

  let ref: DatabaseReference!
  let identifier: String?

  init() {
    ref = Database.database().reference()
    identifier = AccessToken.current?.userId
  }

  func storeLocation(latitude: Double, longitude: Double) {
    guard let identifier = identifier else { return }

    let locationInformation: [AnyHashable: Any] = ["latitude": latitude, "longitude": longitude, "date": ServerValue.timestamp()]
    print("Storing location information:: \(locationInformation) for userID:: \(identifier)")
    ref.child("users/\(identifier)").updateChildValues(locationInformation)
  }

  func retrieveDataForUser(withIdentifier identifier: String, completion: @escaping ([String: AnyObject]) -> Void) {
    ref.child("users/\(identifier)").observe(DataEventType.value, with: { (snapshot) in
      let friendData = snapshot.value as? [String: AnyObject] ?? [:]
      print("Friend data:: \(friendData)")
      completion(friendData)
    })
  }
}
