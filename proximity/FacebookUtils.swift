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

  static func friends() {
    let params = ["fields": "id, first_name, last_name, name, email, picture"]
    let request = GraphRequest(graphPath: "/me/friends", parameters: params)
    let connection = GraphRequestConnection()
    connection.add(request) { (response, result) in
      switch result {
      case .success:
        print("RESULT:: \(result)")
     default:
        print("Oops, something went wrong")
      }
    }
    connection.start()
  }
}
