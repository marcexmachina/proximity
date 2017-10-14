//
//  FriendMapping.swift
//  proximity
//
//  Created by Marc O'Neill on 13/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation

struct FriendMapping {

  static func friends(fromArray array: [[String: Any]]) -> [Friend] {
    let friends: [Friend] = array.map { dict in
      return self.friend(fromDictionary: dict)
    }
    return friends
  }

  private static func friend(fromDictionary dictionary: [String: Any]) -> Friend {
    return Friend(firstName: dictionary["first_name"] as! String,
                  lastName: dictionary["last_name"] as! String,
                  name: dictionary["name"] as! String)
  }

}
