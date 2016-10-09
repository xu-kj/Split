//
//  CameraViewController.swift
//  split
//
//  Created by Shuo Chen on 10/8/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit
import TesseractOCR

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func confirmButton(_ sender: AnyObject) {
        let tesseract:G8Tesseract = G8Tesseract(language:"eng");
        tesseract.delegate = self;
        // tesseract.charWhitelist = "01234567890";
        tesseract.image = self.imageView.image
//            UIImage(named: "assets/IMG_3727.jpg");
        tesseract.recognize();
        
        NSLog("%@", tesseract.recognizedText);
        
    }
    
    func useCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: false, completion: nil)
        }
        else {
            print("can't find camera")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("didFinishPickingImage")
        self.imageView.image = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        useCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
