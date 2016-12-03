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
    let spinner_width:CGFloat = 60.0
    let top_margin:CGFloat = 130.0
    var spinner:UIActivityIndicatorView! = nil
    var messageFrame:UIView! = nil
    
    var array: Array<Dictionary<String, String>> = []
    
    let pintch =  UIPinchGestureRecognizer()
    let pan =  UIPanGestureRecognizer()
    
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
        
        /*
        // Create rectangle from middle of current image
        CGRect cropRect = CGRectMake(image.size.width / 4, image.size.height / 4 ,
                                     (image.size.width / 2), (image.size.height / 2));
        
        // Draw new image in current graphics context
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croprect);
        
        // Create new cropped UIImage
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        */
        
        DispatchQueue.global().async {
            self.array = Recognition().parse(image: self.image)
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.performSegue(withIdentifier: "ToTable", sender: self)
            }
        }
    }
    
    func pinchedView(_ sender:UIPinchGestureRecognizer){
        print("pinch")
        //self.view.bringSubview(toFront: imageView)
        imageView.transform = (imageView.transform).scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
    }
    
    func pannedView(_ sender:UIPanGestureRecognizer){
        print("pan")
        //self.view.bringSubview(toFront: imageView)
        let translation = sender.translation(in: self.view)
        imageView?.center = CGPoint(x: (imageView?.center.x)! + translation.x, y: (imageView?.center.y)! + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToTable" {
            let svc = segue.destination as! DetailViewController
            svc.array.append(contentsOf: self.array)
            
            // TODO: 
            // reload TableView data after adding the new items
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        imageView.image = image
        
        pintch.addTarget(self, action: #selector(pinchedView(_:)))
        pan.addTarget(self, action: #selector(pannedView(_:)))
        self.view.addGestureRecognizer(pintch)
        self.view.addGestureRecognizer(pan)
        
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
        broderLayer.path = UIBezierPath(rect: CGRect(x: 0, y: top_margin, width: blackView.frame.width, height: blackView.frame.height - 2*top_margin)).cgPath
        broderLayer.strokeColor = UIColor.white.cgColor
        broderLayer.lineWidth = 1.0
        broderLayer.fillColor = UIColor.clear.cgColor
        
        blackView.alpha = 0.5
        blackView.backgroundColor = UIColor.black
        blackView.tintColor = UIColor.white
        
        self.view.layer.addSublayer(broderLayer)
        self.view.addSubview(blackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
