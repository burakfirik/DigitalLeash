//
//  ChildDangerViewController.swift
//  DigitalLeashParent
//
//  Created by Burak Firik on 1/2/18.
//  Copyright © 2018 Burak Firik. All rights reserved.
//

import UIKit

class ChildDangerViewController: UIViewController {

  @IBOutlet weak var goBack: UIButton!
  override func viewDidLoad() {
        super.viewDidLoad()
        roundCornerButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func goBackTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  func roundCornerButton() {
    goBack.layer.cornerRadius = 10
    goBack.clipsToBounds = true
  }


}
