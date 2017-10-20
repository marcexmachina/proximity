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
  func updateStatusLabel(locationFound: Bool)
}

class FinderViewController: UIViewController, ARSCNViewDelegate, FriendFinderDelegate {

  // MARK: - Outlets

  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!



  // MARK: - Private properties
  let locationUtils = LocationUtils()
  let databaseManager = DatabaseManager()
  let configuration = ARWorldTrackingConfiguration()
  var anchors = [UUID: String]()
  var friendToFind: Friend?



  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    statusLabel.text = "Location not found"
    statusLabel.textColor = .red

    sceneView.delegate = self
    locationUtils.delegate = self
    locationUtils.trackLocation()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: false)
    configuration.planeDetection = .horizontal
    configuration.worldAlignment = .gravityAndHeading
    // Run the view's session
    sceneView.session.run(configuration)
    addNorthBox()
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
        sceneView.session.pause()
      }
    }
  }



  // MARK: - Private methods

  private func updateLocationForFriend() {
    guard let friend = friendToFind else { return }
    databaseManager.retrieveDataForUser(withIdentifier: friend.id) { data in
      guard let latitude = data["latitude"] as? Double,
        let longitude = data["longitude"] as? Double else {
          print("Error creating latitude and longitude for friends location")
          return
      }
      
      let friendLocation = CLLocation(latitude: latitude, longitude: longitude)

//      self.addFriendSphere(atLocation: friendLocation, atDistance: distanceToFriend.divided(by: 2.0))
//      self.addFriendSphere(atLocation: friendLocation, atDistance: distanceToFriend)
      self.addFriendSphere(atLocation: friendLocation, atDistance: 4)
    }
  }

  private func addNorthBox() {
    guard let transform = locationUtils.transform(rotationY: GLKMathDegreesToRadians(0), distance: 4) else { return }
    let anchor = ARAnchor(transform: SCNMatrix4ToMat4(transform))
    anchors[anchor.identifier] = "north"
    sceneView.session.add(anchor: anchor)
  }

  private func addFriendSphere(atLocation location: CLLocation, atDistance distance: Double) {
    // Create a transform with a translation of X meters in front
    // of the camera
    let newDistance = 2.0
    guard let transform = locationUtils.transform(toLocation: location, distance: newDistance) else { return }

    statusLabel.text = "Location found"
    statusLabel.textColor = .green
    // Add a new anchor to the session
    let anchor = ARAnchor(transform: SCNMatrix4ToMat4(transform))
    anchors[anchor.identifier] = "friend"
    sceneView.session.add(anchor: anchor)
  }

  func resetARSession() {
    sceneView.session.pause()
    sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
      node.removeFromParentNode()
    }
    setupARSession()
    setupSceneView()
  }

  func setupARSession() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .gravityAndHeading
    sceneView.session.run(configuration, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
  }

  func setupSceneView() {
    addNorthBox()
    updateLocationForFriend()
  }


  // MARK: - FriendFinderDelegate

  func updateFriendToFind(withFriend friend: Friend) {
    resetARSession()
    friendToFind = friend
    updateLocationForFriend()
  }

  func updateStatusLabel(locationFound: Bool) {
    var labelText = "Location not found"
    var labelColor = UIColor.red
    if locationFound {
      labelText = "Location found"
      labelColor = .green
    }
    statusLabel.textColor = labelColor
    statusLabel.text = labelText
  }

  

  // MARK: - ARSCNViewDelegate

  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if anchors[anchor.identifier] == "north" {
      let box = SCNBox(width: 0.4, height: 0.4, length: 0.4, chamferRadius: 0)
      box.firstMaterial?.diffuse.contents = UIColor.blue
      box.firstMaterial?.lightingModel = .constant
      box.firstMaterial?.isDoubleSided = true
      node.geometry = box
    } else if anchors[anchor.identifier] == "friend" {
      let sphere = SCNSphere(radius: 0.2)
      sphere.firstMaterial?.diffuse.contents = UIColor.red
      sphere.firstMaterial?.lightingModel = .constant
      sphere.firstMaterial?.isDoubleSided = true
      node.geometry = sphere
    }
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user

  }

  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay

  }

  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    resetARSession()

  }
}
