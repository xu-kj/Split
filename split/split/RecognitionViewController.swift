//
//  RecognitionViewController.swift
//  split
//
//  Created by Elaine Guo on 10/8/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit
import TesseractOCR

class RecognitionViewController: UIViewController, G8TesseractDelegate {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let tesseract:G8Tesseract = G8Tesseract(language:"eng");
		tesseract.delegate = self;
		// tesseract.charWhitelist = "01234567890";
		tesseract.image = UIImage(named: "assets/IMG_3727.jpg");
		tesseract.recognize();
		
		NSLog("%@", tesseract.recognizedText);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
