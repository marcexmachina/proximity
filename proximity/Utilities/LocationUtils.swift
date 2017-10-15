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

  func bearing(toLocation destination: CLLocation) -> Double {
    guard let currentLatitude = currentLocation?.coordinate.latitude,
      let currentLongitude = currentLocation?.coordinate.longitude else {
      return 0.0
    }

    let destinationLatitude = destination.coordinate.latitude
    let destinationLongitude = destination.coordinate.longitude

    let deltaLongitude = currentLongitude - destinationLongitude

    let x = cos(destinationLatitude) * sin(deltaLongitude)
    let y = cos(currentLatitude) * sin(destinationLatitude) - sin(currentLatitude) * cos(destinationLatitude) * cos(deltaLongitude)
    var radiansBearing = atan2(x, y)

    if radiansBearing < 0.0 {
      radiansBearing += 2 * .pi
    }

    return radiansToDegrees(radians: radiansBearing)
  }



  // MARK: - Private methods

  private func degreesToRadians(degrees: Double) -> Double {
    return degrees * .pi / 180.0
  }

  private func radiansToDegrees(radians: Double) -> Double {
    return radians * 180.0 / .pi
  }

}
