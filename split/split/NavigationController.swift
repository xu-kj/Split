//
//  NavigationController.swift
//  split
//
//  Created by Shuo Chen on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named:"assets/logo.png")?.withRenderingMode(.automatic)
        imageView.image = image
        self.navigationController?.navigationBar.topItem?.titleView = imageView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
