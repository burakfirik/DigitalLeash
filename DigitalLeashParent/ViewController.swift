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
    
    
    
    if let userName = userNameTextField.text {
      if let radius = radiusTextField.text  {
        if let long = longitudeTextField.text  {
          if let lati = latitudeTextField.text {
            
            do {
              let radDouble =  Double(radius)
              let longDouble = Double(long)
              let latiDouble = Double(lati)
              
              let userDetails: [String: Any] = [
                "username": userName, "latitude": latiDouble, "longitude": longDouble, "radius": radDouble ]
              var jsonObj = JSON(userDetails)
              let baseURL = "https://turntotech.firebaseio.com/digitalleash/\(userName).json"
              let requestUrl = URL(string: baseURL)
              
              Alamofire.request(baseURL, method:.put, parameters:userDetails,encoding: JSONEncoding.default).responseJSON { response in
                switch response.result {
                case .success:
                  print(response)
                case .failure(let error):
                  print(error)
                }
              }

                            
            } catch {
              errorLabel.isHidden = false
              topView.backgroundColor = UIColor(hexString: "F38282")
              errorLabel.text = "Radius, Longitude or Latitude is bad"
            }
    
          } else {
            errorLabel.isHidden = false
            topView.backgroundColor = UIColor(hexString: "F38282")
            errorLabel.text = "Latitude must be digit"
            
          }
        } else {
          errorLabel.isHidden = false
          topView.backgroundColor = UIColor(hexString: "F38282")
          errorLabel.text = "Longitude must be digit"
        }
      } else {
        errorLabel.isHidden = false
        topView.backgroundColor = UIColor(hexString: "F38282")
        errorLabel.text = "Radius is not good"
      }
    } else {
      errorLabel.isHidden = false
      topView.backgroundColor = UIColor(hexString: "F38282")
      errorLabel.text = "Username is not Entered"
    }
    
    
  }
  
  @IBAction func updateButtonTapped(_ sender: Any) {
    statusButtonTapped(sender)
  }
  
  @IBAction func statusButtonTapped(_ sender: Any) {
    
    let baseURL = "https://turntotech.firebaseio.com/digitalleash/\(userNameTextField.text!).json"
    let requestUrl = URL(string: baseURL)
    
    Alamofire.request(baseURL, method:.get, parameters:nil,encoding: JSONEncoding.default).responseJSON { response in
      switch response.result {
      case .success:
        print(response)
        let locationJSON:JSON = JSON(response.result.value!)
        var childLat = CLLocationDegrees(locationJSON["current_latitude"].stringValue)
        var childLon = CLLocationDegrees(locationJSON["current_longitude"].stringValue)
        
        var parentLat = CLLocationDegrees(locationJSON["latitude"].stringValue)
        var parentLon = CLLocationDegrees(locationJSON["longitude"].stringValue)
        var childLoc = CLLocation(latitude: childLat!, longitude: childLon!)
        var parentLoc = CLLocation(latitude: parentLat!, longitude: parentLon!)
        var radi  = locationJSON["radius"].double as! Double
        
        var distance: Double  = childLoc.distance(from: parentLoc)
        
        if (distance < radi) {
          self.performSegue(withIdentifier: "good", sender: nil)
        } else {
          self.performSegue(withIdentifier: "bad", sender: nil)
        }
        
      case .failure(let error):
        print(error)
      }
    }
    
    
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let coordinate = manager.location?.coordinate {
      var locDict = ["lat": coordinate.latitude, "lon": coordinate.longitude]
      
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

