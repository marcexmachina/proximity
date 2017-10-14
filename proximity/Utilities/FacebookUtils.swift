//
//  FacebookUtils.swift
//  proximity
//
//  Created by Marc O'Neill on 13/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import FacebookCore

struct FacebookUtils {

  private struct Constants {
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let name = "name"
    static let picture = "picture"

    static func keys() -> [String] {
      return [Constants.firstName, Constants.lastName, Constants.name, Constants.picture]
    }
  }

  static func friends(completion: @escaping ([Friend]) -> Void) {
    let params = ["fields": "id, first_name, last_name, name, email, picture"]
    let request = GraphRequest(graphPath: "/me/friends", parameters: params)
    let connection = GraphRequestConnection()
    connection.add(request) { (response, result) in
      switch result {
      case .success(let response):
        guard let dictionary = response.dictionaryValue, let data = dictionary["data"] as? [[String: Any]] else { return }
        let friends = FriendMapping.friends(fromArray: data)
        completion(friends)
     default:
        print("Oops, something went wrong")
      }
    }
    connection.start()
  }
}
