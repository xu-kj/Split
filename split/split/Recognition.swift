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
					
//					let price = fullNameArr[fullNameArr.count - 2]
					var price = ""
					print(line)
					let charArr = Array(line.characters)
					var flag = false
					for i in (0...charArr.count - 1).reversed() {
						let char = charArr[i]
						if (char >= "0" && char <= "9") {
							price = "\(char)" + price
						}
						else if char == "." {
							price = "." + price
							flag = true
						}
						else if char == " " && flag {
							break;
						}
					}
					
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
