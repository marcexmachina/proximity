//
//  LocationUtils.swift
//  proximity
//
//  Created by Marc O'Neill on 14/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import CoreLocation

class LocationUtils: NSObject, CLLocationManagerDelegate {

  let locationManager = CLLocationManager()
  let databaseManager = DatabaseManager()
  var currentLocation: CLLocation?

  func trackLocation() {
    let authorizationStatus = CLLocationManager.authorizationStatus()
    if authorizationStatus != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }
    if !CLLocationManager.locationServicesEnabled() {
      locationManager.requestAlwaysAuthorization()
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.distanceFilter = 5 // 10 meters before an update is sent
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Sending CLLocation to Firebase:: \(locations)")
    guard let lastLocation = locations.last else {
      print("Error storing location:: No last location found")
      return
    }
    currentLocation = lastLocation
    databaseManager.storeLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
  }

//  func currentLocation() {
//    locationManager.
//  }
}
