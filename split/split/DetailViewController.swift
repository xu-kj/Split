//
//  DetailViewController.swift
//  split
//
//  Created by Shuo Chen on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

let ThrowingThreshold: CGFloat = 1000
let ThrowingVelocityPadding: CGFloat = 35

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {
	
    @IBOutlet weak var barButton: UIBarButtonItem!
	@IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var scrollView: UIScrollView!
    var containerView = UIView()
	var start = 10
	var width = 50
	var height = 50
	var margin = 10
	var sep = 10
	
	var startingTag = 100
	
    var editedIndex = -1
    
	let addButton = UIButton()
    var array: Array<Dictionary<String, String> > = []
	
//	var totalDict:Dictionary<UIButton, Double> = [:]
	var itemArray: Array<Set<UIButton> > = []
	var buttonArray: Array<UIButton> = []
	var curHighlightButton: UIButton? = nil
    var contactArray: Array<Dictionary<String, String> > = []
	var curSum: Double = 0.0
    var shake: Bool = false;
    
	
	fileprivate var animator: UIDynamicAnimator!
	fileprivate var attachmentBehavior: UIAttachmentBehavior!
	fileprivate var pushBehavior: UIPushBehavior!
	fileprivate var itemBehavior: UIDynamicItemBehavior!
	
	func handleAttachmentGesture(_ sender: UIPanGestureRecognizer) {
		if(shake) {
		let location = sender.location(in: self.view)
		let myButton = sender.view!
		let boxLocation = sender.location(in: myButton)
		
		switch sender.state {
		case .began:
			print("Your touch start position is \(location)")
			print("Start location is \(boxLocation)")
			
			animator.removeAllBehaviors()
			
//			let centerOffset = UIOffset(horizontal: boxLocation.x - myButton.bounds.midX, vertical: boxLocation.y - myButton.bounds.midY)
			
			let centerOffset = UIOffset(horizontal: 0, vertical: boxLocation.y - myButton.bounds.midY)
			attachmentBehavior = UIAttachmentBehavior(item: myButton, offsetFromCenter: centerOffset, attachedToAnchor: location)
			
			
			animator.addBehavior(attachmentBehavior)
			
		case .ended:
			print("Your touch end position is \(location)")
			print("End location in image is \(boxLocation)")
			
			animator.removeAllBehaviors()
			
			// 1
			let velocity = sender.velocity(in: view)
			let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
			
			if magnitude > ThrowingThreshold {
				// 2
				let pushBehavior = UIPushBehavior(items: [myButton], mode: .instantaneous)
				pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
				pushBehavior.magnitude = magnitude / ThrowingVelocityPadding
				
				self.pushBehavior = pushBehavior
				animator.addBehavior(pushBehavior)
				
				// 3
				let angle = Int(arc4random_uniform(20)) - 10
				
				itemBehavior = UIDynamicItemBehavior(items: [myButton])
				itemBehavior.friction = 0.2
				itemBehavior.allowsRotation = true
				itemBehavior.addAngularVelocity(CGFloat(angle), for: myButton)
				animator.addBehavior(itemBehavior)
				
				// 4
				let timeOffset = Int64(0.4 * Double(NSEC_PER_SEC))
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(timeOffset) / Double(NSEC_PER_SEC)) {
					self.resetDemo(myButton as! UIButton)
				}
			} else {
				resetDemo(myButton as! UIButton)
			}
			
		default:
			attachmentBehavior.anchorPoint = sender.location(in: view)
			break
			}
		}
	}
	
	func resetDemo(_ myButton: UIButton) {
		animator.removeAllBehaviors()
		myButton.isHidden = true;
		let index = buttonArray.index(of: myButton)!
		start = start - width - sep
		
		addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
		
		if index + 1 <= buttonArray.count - 1 {
			for i in index + 1...buttonArray.count - 1 {
				var frame:CGRect = buttonArray[i].frame
				frame.origin.x = frame.origin.x - CGFloat(width + sep)
				buttonArray[i].frame = frame
			}
		}
		if myButton == curHighlightButton {
			curHighlightButton = nil
		}
		buttonArray.remove(at: index)
		self.containerView.frame = CGRect(x: 0, y: 0, width: start + width + sep, height: height + 20)
		self.scrollView.contentSize = CGSize(width: start + width + sep, height: height + 20)

		// TODO recalculate
	}
	
	
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Done" && shake {
            for button in buttonArray {
                button.layer.removeAllAnimations()
            }
            sender.title = "Edit"
            addButton.isHidden = false
            shake = false
        }
        else if sender.title == "Edit" {
            sender.title = "Done"
        }
        //TODO
    }
    
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
	
	func deleteContact(_ sender: UIButton) {
		print("contact to be deleted")
	}
	
	func addContact(_ sender: UIButton) {
        print ("button to addcontact clicked")
		self.performSegue(withIdentifier: "ToAddContact", sender: sender)
	}
	
	func changeContact(_ sender: UIButton) {
		print ("Normal tap")
        if shake {
            self.performSegue(withIdentifier: "ToAddContact", sender: sender)
        }
        else {
            curHighlightButton?.layer.backgroundColor = UIColor.gray.cgColor
            sender.layer.backgroundColor = UIColor(red: 39.0/255.0, green: 78.0/255.0, blue: 192.0/255.0, alpha: 1.0).cgColor
            curHighlightButton = sender
            curSum = 0.0
            tableView.reloadData()
        }
	}
	
	func longTap(_ sender : UIGestureRecognizer){
		print("Long tap")
        let frame = CAKeyframeAnimation(keyPath: "transform.rotation")
        let left = CGFloat(-M_PI_2*0.20)
        let right = CGFloat(M_PI_2*0.20)

        
        frame.values = [left, right, left];
        frame.duration = 0.2;
        frame.repeatCount = Float.infinity;
        
        for button in buttonArray {
            button.layer.add(frame, forKey: nil)
        }
        shake = true
        addButton.isHidden = true;
        barButton.title = "Done"
	}
	
	func userDidEnterInformation(name: String, mobile: String, email: String) {
		print(name)
        if shake {
            buttonArray[editedIndex].titleLabel?.text = name;
            contactArray[editedIndex]["name"] = name;
            contactArray[editedIndex]["mobile"] = mobile;
            contactArray[editedIndex]["email"] = email;
            editedIndex = -1
//            barButton.title = "Edit"
//            shake = false
//            addButton.isHidden = false;
        }
        else {
            contactArray.append(["name": name, "mobile": mobile, "email": email])
            let usrButton = UIButton();
			usrButton.tag = startingTag
			startingTag = startingTag + 1
            usrButton.frame = CGRect(x: start, y: margin, width: width, height: height)
            usrButton.layer.cornerRadius = 25
            usrButton.layer.backgroundColor = UIColor.gray.cgColor
            //		usrButton.showsTouchWhenHighlighted = true
            usrButton.addTarget(self, action: #selector(DetailViewController.changeContact(_:)), for: UIControlEvents.touchUpInside)
            
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.longTap(_:)))
            usrButton.addGestureRecognizer(longGesture)
			
			let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DetailViewController.handleAttachmentGesture(_:)))
			usrButton.addGestureRecognizer(panGesture)
			
            usrButton.setTitle(name, for: UIControlState.normal)
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
                UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.curveEaseOut,animations: {
                    self.scrollView.contentOffset.x = self.containerView.frame.width - self.view.frame.width
                    }, completion: nil)
                //			}
            }
        }
	}
    
    func becomeActive(_ notification: NSNotification) {
        shake = false
        barButton.title = "Edit"
        addButton.isHidden = false
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ToAddContact") {
			let svc = segue.destination as! AddContactViewController
			svc.delegate = self
			let button = sender as! UIButton
			if button != addButton {
				editedIndex = buttonArray.index(of: button)!
				let dict: Dictionary<String, String> = contactArray[editedIndex]
				svc.name = dict["name"]
				svc.mobile = dict["mobile"]
				svc.email = dict["email"]
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		animator = UIDynamicAnimator(referenceView: view)
		
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DetailViewController.becomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)

        
		self.title = "Bill Details"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
		
		// Do any additional setup after loading the view.
		// containerView.backgroundColor = UIColor.yellow
		itemArray = Array(repeating: Set<UIButton>(), count: array.count)
		scrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
		
		addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
//		addButton.setTitle("+", for: UIControlState.normal)
		let cameraImage = UIImage(named:"assets/add.png")?.withRenderingMode(.automatic)
		addButton.setImage(cameraImage, for:.normal)
		
		self.containerView.addSubview(addButton)
		addButton.addTarget(self, action: #selector(DetailViewController.addContact(_:)), for: UIControlEvents.touchUpInside)
		
		self.containerView.frame = CGRect(x: 0, y: 0, width: start + width + sep, height: 70)
		self.scrollView.contentSize = CGSize(width: start + width + sep, height: 70)
		self.automaticallyAdjustsScrollViewInsets = false
		scrollView.addSubview(containerView)
	}
    
    override func viewDidAppear(_ animated: Bool) {
        shake = false
        barButton.title = "Edit"
        addButton.isHidden = false
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
