//
//  ViewController.swift
//  split
//
//  Created by Elaine Guo on 9/30/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        let iconImage = UIImage(named:"assets/camera.png")?.withRenderingMode(.automatic)
        cameraButton.setImage(iconImage, for:.normal)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

