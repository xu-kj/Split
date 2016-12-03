//
//  ReplaceSegue.swift
//  split
//
//  Created by James on 12/3/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        if let navVC = source.navigationController {
            navVC.popToRootViewController(animated: false)
            navVC.pushViewController(destination, animated: true)
        } else {
            super.perform()
        }
    }
}
