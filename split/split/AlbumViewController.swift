//
//  AlbumViewController.swift
//  split
//
//  Created by Shuo Chen on 10/8/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import Foundation

import UIKit

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func reSelectButton(_ sender: AnyObject) {
        selectFromAlbum()
    }
    
    func selectFromAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: false, completion: nil)
        }
        else {
            print("can't find album")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("didFinishPickingImage")
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("imagePickerControllerDidCancel")
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        selectFromAlbum()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
