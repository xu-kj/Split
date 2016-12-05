//
//  CropViewController.swift
//  split
//
//  Created by Shuo Chen on 11/30/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {
	
	var image: UIImage!
	//	var imageViewInitFrame: CGRect!
	var whiteRect: CGRect!
	let spinner_width:CGFloat = 60.0
	let top_margin:CGFloat = 130.0
	var spinner:UIActivityIndicatorView! = nil
	var messageFrame:UIView! = nil
	
	var array: Array<Dictionary<String, String>> = []
	
	let pintch =  UIPinchGestureRecognizer()
	let pan =  UIPanGestureRecognizer()
	var croppedImage = UIImage()
	
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var toolBar: UIToolbar!
	
	@IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func chooseButtonTapped(_ sender: AnyObject) {
		messageFrame = UIView(frame: CGRect(x: self.view.frame.midX - spinner_width/2, y: self.view.frame.midY - spinner_width/2, width: spinner_width, height: spinner_width))
		messageFrame.layer.cornerRadius = 15
		messageFrame.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
		
		spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
		spinner.frame = CGRect(x: 0, y: 0, width: spinner_width, height: spinner_width)
		self.view.addSubview(messageFrame)
		messageFrame.addSubview(spinner)
		
		spinner.startAnimating()
		
		print(image.size)
		print(imageView.frame)
		print(whiteRect)
		var imageRect: CGRect!
		if image.size.height / image.size.width > imageView.frame.height / imageView.frame.width {
			imageRect = CGRect(x:imageView.frame.origin.x + (imageView.frame.width - image.size.width				* imageView.frame.height/image.size.height)/2,
			                   y: imageView.frame.origin.y,
			                   width: image.size.width * imageView.frame.height/image.size.height,
			                   height: imageView.frame.height)
		}
		else {
			imageRect = CGRect(x: imageView.frame.origin.x,
			                   y: imageView.frame.origin.y + (imageView.frame.height - image.size.height * imageView.frame.width/image.size.width)/2,
			                   width: imageView.frame.width,
			                   height: image.size.height * imageView.frame.width/image.size.width)
		}
		print(imageRect)
		let upperLeftX = max(whiteRect.origin.x, imageRect.origin.x)
		let upperLeftY = max(whiteRect.origin.y, imageRect.origin.y)
		let bottomRightX = min(imageRect.origin.x + imageRect.width, whiteRect.origin.x + whiteRect.width)
		let bottomRightY = min(imageRect.origin.y + imageRect.height, whiteRect.origin.y + whiteRect.height)
		
		var cropRect = CGRect(x: upperLeftX,
		                      y: upperLeftY,
		                      width: bottomRightX - upperLeftX,
		                      height: bottomRightY - upperLeftY)
		
		cropRect.origin.x = cropRect.origin.x - imageRect.origin.x
		cropRect.origin.y = cropRect.origin.y - imageRect.origin.y
		print(cropRect)
		
		//		let cropScale = self.imageView.frame.size.height / imageViewInitFrame.height
		
		// crop image
		let widthScale:CGFloat = imageRect.size.width / self.image.size.width;
		let heightScale:CGFloat = imageRect.size.height / self.image.size.height;
		
		// Calculate the right crop rectangle
		cropRect.origin.x = cropRect.origin.x * (1 / widthScale)
		cropRect.origin.y = cropRect.origin.y * (1 / heightScale)
		cropRect.size.width = cropRect.size.width * (1 / widthScale)
		cropRect.size.height = cropRect.size.height * (1 / heightScale)
		print(cropRect)
		if image.imageOrientation != UIImageOrientation.up {
			let temp1 = image.size.width - cropRect.origin.x - cropRect.size.width
			cropRect.origin.x = cropRect.origin.y
			cropRect.origin.y = temp1
			let temp2 = cropRect.size.width
			cropRect.size.width = cropRect.size.height
			cropRect.size.height = temp2
		}
		
		
		croppedImage = cropImage(image: image, toRect: cropRect)
		
		
		
		DispatchQueue.global().async {
			self.array = Recognition().parse(image: self.croppedImage)
			DispatchQueue.main.async {
				self.spinner.stopAnimating()
		//			_ = self.navigationController?.popViewController(animated: false)
				self.performSegue(withIdentifier: "ToTable", sender: self)
			}
		}
	}
	
	func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
		print(rect)
		let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
		
		let croppedimage:UIImage = UIImage(cgImage:imageRef, scale: image.scale, orientation: image.imageOrientation)
		print(croppedimage.size)
		return croppedimage
	}
	
	func pinchedView(_ sender:UIPinchGestureRecognizer){
		//self.view.bringSubview(toFront: imageView)
		imageView.transform = (imageView.transform).scaledBy(x: sender.scale, y: sender.scale)
		
		sender.scale = 1.0
	}
	
	func pannedView(_ sender:UIPanGestureRecognizer){
		//self.view.bringSubview(toFront: imageView)
		let translation = sender.translation(in: self.view)
		imageView?.center = CGPoint(x: (imageView?.center.x)! + translation.x, y: (imageView?.center.y)! + translation.y)
		sender.setTranslation(CGPoint.zero, in: self.view)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.layoutIfNeeded()
		imageView.image = image
		//		imageViewInitFrame = imageView.frame
		
		pintch.addTarget(self, action: #selector(pinchedView(_:)))
		pan.addTarget(self, action: #selector(pannedView(_:)))
		self.view.addGestureRecognizer(pintch)
		self.view.addGestureRecognizer(pan)
		//UIApplication.shared.statusBarFrame.height
		let blackView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 50))
		let maskLayer = CAShapeLayer() //create the mask layer
		
		let path = UIBezierPath(rect: blackView.frame)
		
		path.append(UIBezierPath(rect: CGRect(x: 0, y: top_margin, width: blackView.frame.width, height: blackView.frame.height - 2*top_margin)))
		
		// Give the mask layer the path you just draw
		maskLayer.path = path.cgPath
		// Fill rule set to exclude intersected paths
		maskLayer.fillRule = kCAFillRuleEvenOdd
		
		// By now the mask is a rectangle with a circle cut out of it. Set the mask to the view and clip.
		blackView.layer.mask = maskLayer
		blackView.clipsToBounds = true
		
		let broderLayer = CAShapeLayer()
		print("black frame")
		print(blackView.frame)
		broderLayer.path = UIBezierPath(rect: CGRect(x: 0, y: top_margin, width: blackView.frame.width, height: blackView.frame.height - 2*top_margin)).cgPath
		broderLayer.strokeColor = UIColor.white.cgColor
		broderLayer.lineWidth = 1.0
		broderLayer.fillColor = UIColor.clear.cgColor
		
		blackView.alpha = 0.5
		blackView.backgroundColor = UIColor.black
		blackView.tintColor = UIColor.white
		
		self.view.layer.addSublayer(broderLayer)
		self.view.addSubview(blackView)
		
		whiteRect = CGRect(x: 0, y: top_margin, width: blackView.frame.width, height: blackView.frame.height - 2*top_margin)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ToTable") {
			let svc = segue.destination as! DetailViewController;
			svc.array = self.array
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		UIApplication.shared.isStatusBarHidden = true
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		UIApplication.shared.isStatusBarHidden = false
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
