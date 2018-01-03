//
//  ViewController.swift
//  DigitalLeashParent
//
//  Created by Burak Firik on 1/2/18.
//  Copyright © 2018 Burak Firik. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  var manager = CLLocationManager()
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var createButton: UIButton!
  @IBOutlet weak var statusButton: UIButton!
  @IBOutlet weak var updateButton: UIButton!
  
  @IBOutlet weak var latitudeTextField: UITextField!
  @IBOutlet weak var longitudeTextField: UITextField!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var userNameTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    errorLabel.isHidden = true
    roundCornerButton()
    
    
    manager.delegate = self
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      manager.startUpdatingLocation()
    } else {
      manager.requestWhenInUseAuthorization()
    }
    
  }
  
  func roundCornerButton() {
    createButton.layer.cornerRadius = 10
    createButton.clipsToBounds = true
    
    statusButton.layer.cornerRadius = 10
    statusButton.clipsToBounds = true
    
    updateButton.layer.cornerRadius = 10
    updateButton.clipsToBounds = true
  }
  
  @IBAction func createButtonTapped(_ sender: Any) {
    
    guard let userName = userNameTextField.text else {
      errorLabel.isHidden = false
      topView.backgroundColor = UIColor(hexString: "F38282")
      errorLabel.text = "Username is not entered"
      return
    }
    
    guard let radius = radiusTextField.text else {
      errorLabel.isHidden = false
      topView.backgroundColor = UIColor(hexString: "F38282")
      errorLabel.text = "Radius is not entered"
      return
    }
    
    guard let long = longitudeTextField.text else {
      errorLabel.isHidden = false
      topView.backgroundColor = UIColor(hexString: "F38282")
      errorLabel.text = "long is not entered"
      return
    }
    
    guard let lati = latitudeTextField.text else {
      errorLabel.isHidden = false
      topView.backgroundColor = UIColor(hexString: "F38282")
      errorLabel.text = "lati is not entered"
      return
    }
    let radDouble =  Double(radius)
    let longDouble = Double(long)
    let latiDouble = Double(lati)
    
    let userDetails: [String: Any] = [
      "username": userName, "latitude": latiDouble ?? 0, "longitude": longDouble ?? 0, "radius": radDouble ?? 0 ]
    let baseURL = "https://turntotech.firebaseio.com/digitalleash/\(userName).json"
    Alamofire.request(baseURL, method:.put, parameters:userDetails,encoding: JSONEncoding.default).responseJSON { response in
      switch response.result {
      case .success:
        print(response)
      case .failure(let error):
        print(error)
      }
    }
  }
  
  @IBAction func updateButtonTapped(_ sender: Any) {
    createButtonTapped(sender)
  }
  
  @IBAction func statusButtonTapped(_ sender: Any) {
    
    let baseURL = "https://turntotech.firebaseio.com/digitalleash/\(userNameTextField.text!).json"
    
    Alamofire.request(baseURL, method:.get, parameters:nil,encoding: JSONEncoding.default).responseJSON { response in
      switch response.result {
      case .success:
        print(response)
        let locationJSON:JSON = JSON(response.result.value!)
        
        guard let childLat = CLLocationDegrees(locationJSON["current_latitude"].stringValue) else {
          self.errorLabel.isHidden = false
          self.topView.backgroundColor = UIColor(hexString: "F38282")
          self.errorLabel.text = "child lat is not available"
          return
        }
        
        guard let childLon = CLLocationDegrees(locationJSON["current_longitude"].stringValue) else {
          self.errorLabel.isHidden = false
          self.topView.backgroundColor = UIColor(hexString: "F38282")
          self.errorLabel.text = "child lon is not available"
          return
        }
        
        guard let parentLat = CLLocationDegrees(locationJSON["latitude"].stringValue) else {
          self.errorLabel.isHidden = false
          self.topView.backgroundColor = UIColor(hexString: "F38282")
          self.errorLabel.text = "child lat is not available"
          return
        }
        
        guard let parentLon = CLLocationDegrees(locationJSON["longitude"].stringValue) else {
          self.errorLabel.isHidden = false
          self.topView.backgroundColor = UIColor(hexString: "F38282")
          self.errorLabel.text = "child lon is not available"
          return
        }
        let childLoc = CLLocation(latitude: childLat, longitude: childLon)
        let parentLoc = CLLocation(latitude: parentLat, longitude: parentLon)
        if let radi  = locationJSON["radius"].double {
          let distance: Double  = childLoc.distance(from: parentLoc)
          
          if (distance < radi) {
            self.performSegue(withIdentifier: "good", sender: nil)
          } else {
            self.performSegue(withIdentifier: "bad", sender: nil)
          }
        }
      case .failure(let error):
        print(error)
        
      }
    }
  }
}

extension UIColor {
  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.characters.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

