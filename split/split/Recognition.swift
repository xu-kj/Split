//
//  Recognition.swift
//  split
//
//  Created by Elaine Guo on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit
import TesseractOCR

class Recognition: NSObject, G8TesseractDelegate {
	func parse(image: UIImage)->Array<Dictionary<String, String>> {
		let tesseract:G8Tesseract = G8Tesseract(language:"eng")
		tesseract.delegate = self
		tesseract.image = image
		tesseract.recognize();
		
		var retval = Array<Dictionary<String, String>>()
		tesseract.recognizedText.enumerateLines {
			line, stop in
			if line != "" {
				var fullNameArr  = line.components(separatedBy: " ")
				if fullNameArr[fullNameArr.count - 1] == "T" || fullNameArr[fullNameArr.count - 1] == "F" {
					let price = fullNameArr[fullNameArr.count - 2]
					fullNameArr.remove(at: fullNameArr.count - 1)
					fullNameArr.remove(at: fullNameArr.count - 1)
					let name =  fullNameArr.joined(separator: " ")
					let dict:[String:String] = [
						"name": name,
						"price": price
					]
					retval.append(dict)
				}
			}
		}
		return retval
	}
}
