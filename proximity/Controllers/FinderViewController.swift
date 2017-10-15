//
//  ViewController.swift
//  proximity
//
//  Created by Marc O'Neill on 13/10/2017.
//  Copyright © 2017 marcexmachina. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

protocol FriendFinderDelegate {
  func updateFriendToFind(withFriend friend: Friend)
}

class FinderViewController: UIViewController, ARSCNViewDelegate, FriendFinderDelegate {

  // MARK: - Outlets

  @IBOutlet var sceneView: ARSCNView!



  // MARK: - Private properties
  let locationUtils: LocationUtils
  let databaseManager: DatabaseManager



  // MARK: - Lifecycle

  required init?(coder aDecoder: NSCoder) {
    databaseManager = DatabaseManager()
    locationUtils = LocationUtils()
    locationUtils.trackLocation()
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // Set the scene to the view
    sceneView.scene = scene
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: false)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: false)
    // Pause the view's session
    sceneView.session.pause()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Release any cached data, images, etc that aren't in use.
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToFriendListViewController" {
      if let destinationViewController = segue.destination as? FriendListViewController {
        destinationViewController.delegate = self
      }
    }
  }



  // MARK: - Private methods

  private func updateLocation(forFriend friend: Friend) {
    databaseManager.retrieveDataForUser(withIdentifier: friend.id) { data in
      guard let currentLocation = self.locationUtils.currentLocation,
        let latitude = data["latitude"] as? Double,
        let longitude = data["longitude"] as? Double else {
        print("Error creating latitude and longitude for friends location")
        return
      }
      
      let friendLocation = CLLocation(latitude: latitude, longitude: longitude)
      let distanceToFriend = currentLocation.distance(from: friendLocation)
      let bearingToFriend = self.locationUtils.bearing(toLocation: friendLocation)
      print("Friend location:: \(friendLocation)")
      print("Current location:: \(currentLocation)")
      print("Distance to friend:: \(distanceToFriend)")
      print("Bearing to friend:: \(bearingToFriend)")
      
      self.addFriendSphere(atLocation: friendLocation, atDistance: distanceToFriend)
    }
  }

  private func addFriendSphere(atLocation location: CLLocation, atDistance distance: Double) {
    // Create anchor using the camera’s current position
    if let currentFrame = sceneView.session.currentFrame {
      // Create a transform with a translation of X meters in front
      // of the camera

      let newDistance = 2.0
      let transform = locationUtils.transform(toLocation: location, distanceInMeters: newDistance)
//      let transform = locationUtils.transform(originTransform: currentFrame.camera.transform, toLocation: location, distanceInMeters: 1.0)
      // Add a new anchor to the session
      let anchor = ARAnchor(transform: transform)
      sceneView.session.add(anchor: anchor)
    }
  }



  // MARK: - FriendFinderDelegate

  func updateFriendToFind(withFriend friend: Friend) {
    updateLocation(forFriend: friend)
  }

  

  // MARK: - ARSCNViewDelegate

  // Override to create and configure nodes for anchors added to the view's session.
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let sphere = SCNSphere(radius: 0.02)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    sphere.firstMaterial?.lightingModel = .constant
    sphere.firstMaterial?.isDoubleSided = true
    let sphereNode = SCNNode(geometry: sphere)

    return sphereNode
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
      // Present an error message to the user

  }

  func sessionWasInterrupted(_ session: ARSession) {
      // Inform the user that the session has been interrupted, for example, by presenting an overlay

  }

  func sessionInterruptionEnded(_ session: ARSession) {
      // Reset tracking and/or remove existing anchors if consistent tracking is required

  }
}
