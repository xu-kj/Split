//
//  DetailViewController.swift
//  split
//
//  Created by Shuo Chen on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {
	
	@IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var scrollView: UIScrollView!
    var containerView = UIView()
	var start = 10
	var width = 50
	var height = 50
	var margin = 10
	var sep = 10
	
	let addButton = UIButton()
    var array: Array<Dictionary<String, String>> = []
	
//	var totalDict:Dictionary<UIButton, Double> = [:]
	var itemArray: Array<Set<UIButton> > = []
	var buttonArray: Array<UIButton> = []
	var curHighlightButton: UIButton? = nil
	var curSum: Double = 0.0
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath as IndexPath)
        let item : UILabel = self.view.viewWithTag(1) as! UILabel;
        let price : UILabel = self.view.viewWithTag(2) as! UILabel;
        item.text = array[row]["name"]
        price.text = "$" + array[row]["price"]!
		if (curHighlightButton != nil && itemArray[indexPath.row].contains(curHighlightButton!)) {
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
			curSum += (array[row]["price"]! as NSString).doubleValue / Double(itemArray[row].count)
		}
		if (curSum < 0) {
			totalLabel.text = String(format:"Total: $0.00")
		}
		else {
			totalLabel.text = String(format:"Total: $%.2f", curSum)
		}

        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		if (curHighlightButton != nil) {
			itemArray[row].insert(curHighlightButton!)
			curSum += (array[row]["price"]! as NSString).doubleValue / Double(itemArray[row].count)
		}
		else {
			curSum += (array[row]["price"]! as NSString).doubleValue
		}
		if (curSum < 0) {
			totalLabel.text = String(format:"Total: $0.00")
		}
		else {
			totalLabel.text = String(format:"Total: $%.2f", curSum)
		}
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		if (curHighlightButton != nil) {
			curSum -= (array[row]["price"]! as NSString).doubleValue / Double(itemArray[row].count)
			itemArray[row].remove(curHighlightButton!)
		}
		else {
			curSum -= (array[row]["price"]! as NSString).doubleValue
		}
		if (curSum < 0) {
			totalLabel.text = String(format:"Total: $0.00")
		}
		else {
			totalLabel.text = String(format:"Total: $%.2f", curSum)
		}
	}
	
	func addContact(_ sender: UIButton) {
        print ("button to addcontact clicked")
		self.performSegue(withIdentifier: "ToAddContact", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ToAddContact") {
			let svc = segue.destination as! AddContactViewController
			svc.delegate = self
		}
	}
	
	func changeContact(_ sender: UIButton) {
		print ("Normal tap")
		curHighlightButton?.layer.backgroundColor = UIColor.gray.cgColor
		sender.layer.backgroundColor = UIColor(red: 39.0/255.0, green: 78.0/255.0, blue: 192.0/255.0, alpha: 1.0).cgColor
		curHighlightButton = sender
		curSum = 0.0
		tableView.reloadData()
	}
	
	func longTap(_ sender : UIGestureRecognizer){
		print("Long tap")
		if sender.state == .ended {
			print("UIGestureRecognizerStateEnded")
			//Do Whatever You want on End of Gesture
		}
		else if sender.state == .began {
			print("UIGestureRecognizerStateBegan.")
			//Do Whatever You want on Began of Gesture
		}
	}
	
	func userDidEnterInformation(info: String) {
		//label.text = info
		print(info)
		let usrButton = UIButton();
		//usrButton.setTitleColor(UIColor.black, for: UIControlState.normal)
		usrButton.frame = CGRect(x: start, y: margin, width: width, height: height)
		usrButton.layer.cornerRadius = 25
		usrButton.layer.backgroundColor = UIColor.gray.cgColor
//		usrButton.showsTouchWhenHighlighted = true
		usrButton.addTarget(self, action: #selector(DetailViewController.changeContact(_:)), for: UIControlEvents.touchUpInside)
		
//		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.changeContact(_:)))
//		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.longTap(_:)))
//		usrButton.addGestureRecognizer(tapGesture)
//		usrButton.addGestureRecognizer(longGesture)
		
		
		usrButton.setTitle(info, for: UIControlState.normal)
		start += width + sep
		
		addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
		
		buttonArray.append(usrButton)
		if (buttonArray.count == 1) {
			changeContact(usrButton)
		}
		
		self.containerView.addSubview(usrButton)
		self.containerView.frame = CGRect(x: 0, y: 0, width: start + width + sep, height: 70)
		self.scrollView.contentSize = CGSize(width: start + width + sep, height: 70)
		if (self.containerView.frame.width > self.view.frame.width) {
//			DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut,animations: {
					self.scrollView.contentOffset.x = self.containerView.frame.width - self.view.frame.width
				}, completion: nil)
//			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Bill Details"
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
		
		// Do any additional setup after loading the view.
		// containerView.backgroundColor = UIColor.yellow
		itemArray = Array(repeating: Set<UIButton>(), count: array.count)
		scrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
		
		addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
		addButton.setTitle("+", for: UIControlState.normal)
		let cameraImage = UIImage(named:"assets/add.png")?.withRenderingMode(.automatic)
		addButton.setImage(cameraImage, for:.normal)
		
		self.containerView.addSubview(addButton)
		addButton.addTarget(self, action: #selector(DetailViewController.addContact(_:)), for: UIControlEvents.touchUpInside)
		
		self.containerView.frame = CGRect(x: 0, y: 0, width: start + width + sep, height: 70)
		self.scrollView.contentSize = CGSize(width: start + width + sep, height: 70)
		self.automaticallyAdjustsScrollViewInsets = false
		scrollView.addSubview(containerView)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
