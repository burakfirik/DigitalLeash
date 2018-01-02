//
//  ChildGoodViewController.swift
//  DigitalLeashParent
//
//  Created by Burak Firik on 1/2/18.
//  Copyright © 2018 Burak Firik. All rights reserved.
//

import UIKit

class ChildGoodViewController: UIViewController {

  @IBOutlet weak var goBackButton: UIButton!
  
  
  @IBAction func goBackTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  override func viewDidLoad() {
        super.viewDidLoad()

         roundCornerButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func roundCornerButton() {
    goBackButton.layer.cornerRadius = 10
    goBackButton.clipsToBounds = true
  }

}
