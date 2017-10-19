//
//  LocationUtils.swift
//  proximity
//
//  Created by Marc O'Neill on 14/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit
import GLKit

class LocationUtils: NSObject, CLLocationManagerDelegate {

  let locationManager = CLLocationManager()
  let databaseManager = DatabaseManager()
  var currentLocation: CLLocation?
  var delegate: FriendFinderDelegate?

  func trackLocation() {
    let authorizationStatus = CLLocationManager.authorizationStatus()
    if authorizationStatus != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }
    if !CLLocationManager.locationServicesEnabled() {
      locationManager.requestAlwaysAuthorization()
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.distanceFilter = 10 // 10 meters before an update is sent
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation = locations.last else {
      print("Error storing location:: No last location found")
      return
    }

    guard lastLocation.horizontalAccuracy < 15.0 else {
      print("Not sending to Firebase:: Location inaccurate")
      return
    }

    print("Sending CLLocation to Firebase:: \(locations)")
    currentLocation = lastLocation
    databaseManager.storeLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
    delegate?.updateStatusLabel(locationFound: true)
  }

  func bearing(toLocation destination: CLLocation) -> Float {
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

    return Float(radiansToDegrees(radians: radiansBearing))
  }

//  func transform(toLocation location: CLLocation, distanceInMeters distance: Double) -> matrix_float4x4 {
//    let bearing = self.bearing(toLocation: location)
//    let originTransform = matrix_identity_float4x4
//    var translationMatrix = matrix_identity_float4x4
//    translationMatrix.columns.3.z = -1 * Float(distance)
//
//    // Rotation matrix theta degrees
//    let rotationMatrix = GLKMatrix4RotateY(GLKMatrix4Identity, -1 * Float(bearing))
//
//    let transformMatrix = simd_mul(convertGLKMatrix4Tosimd_float4x4(matrix: rotationMatrix), translationMatrix)
//
//    return simd_mul(originTransform, transformMatrix)
//  }

  func transform(toLocation location: CLLocation, distance: Double) -> SCNMatrix4? {
    guard let currentLocation = currentLocation else {
      print("Current Location:: Not found")
      return nil
    }

    let bearing = self.bearing(toLocation: location)
    let distanceToFriend = currentLocation.distance(from: location)
    print("Current location:: \(currentLocation)")
    print("Distance to friend:: \(distanceToFriend)")
    print("Bearing to friend:: \(bearing)")

    let rotationY = GLKMathDegreesToRadians(bearing)
    // Translate first on -z direction (North = -Z)
    let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
    // Rotate (yaw) around y axis
    let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)

    // Final transformation: TxR
    let transform = SCNMatrix4Mult(translation, rotation)

    return transform
  }

  func transform(rotationY: Float, distance: Double) -> SCNMatrix4? {

    // Translate first on -z direction
    let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
    // Rotate (yaw) around y axis
    let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)

    // Final transformation: TxR
    let transform = SCNMatrix4Mult(translation, rotation)

    return transform
  }



  // MARK: - Private methods

  private func degreesToRadians(degrees: Double) -> Double {
    return degrees * .pi / 180.0
  }

  private func radiansToDegrees(radians: Double) -> Double {
    return radians * 180.0 / .pi
  }

  private func convertGLKMatrix4Tosimd_float4x4(matrix: GLKMatrix4) -> float4x4{
    return float4x4(float4(matrix.m00,matrix.m01,matrix.m02,matrix.m03),
                    float4( matrix.m10,matrix.m11,matrix.m12,matrix.m13 ),
                    float4( matrix.m20,matrix.m21,matrix.m22,matrix.m23 ),
                    float4( matrix.m30,matrix.m31,matrix.m32,matrix.m33 ))
  }

}
