//
//  ViewController.swift
//  split
//
//  Created by Elaine Guo on 9/30/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var array: Array<Dictionary<String, String>> = []
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
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
    
    @IBAction func albumButtonPressed(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
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
        array = Recognition().parse(image: image)
        picker.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "ToTable", sender: self)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        let cameraImage = UIImage(named:"assets/camera.png")?.withRenderingMode(.automatic)
        cameraButton.setImage(cameraImage, for:.normal)
        let albumImage = UIImage(named:"assets/album.png")?.withRenderingMode(.automatic)
        albumButton.setImage(albumImage, for:.normal)
        let editImage = UIImage(named:"assets/edit.png")?.withRenderingMode(.automatic)
        editButton.setImage(editImage, for:.normal)
	}
    
    override func viewDidAppear(_ animated: Bool) {
        let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: self.view.frame.width, height: 35))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named:"assets/logo.png")?.withRenderingMode(.automatic)
        imageView.image = image
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 15, width: self.view.frame.width, height: 50)
        self.navigationController?.navigationBar.topItem?.titleView = imageView
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToTable") {
            let svc = segue.destination as! DetailViewController;
            svc.array = self.array
        }
    }
}

