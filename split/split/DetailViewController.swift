//
//  DetailViewController.swift
//  split
//
//  Created by Shuo Chen on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import ContactsUI

let ThrowingThreshold: CGFloat = 1000
let ThrowingVelocityPadding: CGFloat = 35

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DataEnteredDelegate, RecognitionEndedDelegate, MGSwipeTableCellDelegate, CNContactPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
	
	let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DetailViewController.handleAttachmentGesture(_:)))
//	let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.longTap(_:)))
	
    var containerView = UIView()
	var start  = 10
	var width  = 50
	var height = 50
	var margin = 10
	var sep    = 10
	
	var startingTag = 100
    var editedIndex = -1
    
    enum newContactSource {
        case blank, contacts, social
    }
    var newContactType = newContactSource.blank
    
	let addButton = UIButton()
    var array: Array<Dictionary<String, String> > = []
    var newContact: Dictionary<String, String> = [:]
	
	var itemArray: Array<Set<UIButton> > = []
	var buttonArray: Array<UIButton> = []
	var curHighlightButton: UIButton? = nil
	var contactArray: Array<Dictionary<String, String> > = []
	var selectedDict: Dictionary<UIButton, Set<Int>> = [:]
	
    var image: UIImage!
	
	fileprivate var animator: UIDynamicAnimator!
	fileprivate var attachmentBehavior: UIAttachmentBehavior!
	fileprivate var pushBehavior: UIPushBehavior!
	fileprivate var itemBehavior: UIDynamicItemBehavior!
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
	
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Done" {
            for button in buttonArray {
                button.layer.removeAllAnimations()
            }
            sender.title = "Edit"
            addButton.isHidden = false
			panGesture.isEnabled = false
        }
        else {
            shakeButton()
			sender.title = "Done"
		}

        tableView.reloadData()
		calculateTotal()
    }
	
    @IBAction func selectAllItems(_ sender: UIButton) {
        for i in 0..<array.count {
            let indexPath = NSIndexPath(row:i, section:0)
            tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            self.tableView(tableView, didSelectRowAt: indexPath as IndexPath)
        }
    }
    
    @IBAction func clearAllItems(_ sender: UIButton) {
        for i in 0..<array.count {
            let indexPath = NSIndexPath(row:i, section:0)
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
            self.tableView(tableView, didDeselectRowAt: indexPath as IndexPath)
        }
    }
    
    @IBAction func proceedToSummary(_ sender: UIButton) {
        var count: Int = 0
        for btnSet in itemArray {
            if btnSet.count > 0 {
                count += 1
            }
        }
        if count == array.count {
            self.performSegue(withIdentifier: "ToSummary", sender: sender)
        }
        else {
            self.showMessage(title: "Error", message: "There's at least one item not assigned to any user.")
        }
    }
    
    func calculateTotal() {
		if curHighlightButton != nil {
			var sum:Double = 0.0
			for item in selectedDict[curHighlightButton!]! {
				sum = sum + (array[item]["price"]! as NSString).doubleValue / Double(itemArray[item].count)
			}
			if sum < 0 {
				totalLabel.text = String(format:"Total: $0.00")
			} else {
				totalLabel.text = String(format:"Total: $%.2f", sum)
			}
		}
	}
	
    func textFieldDidEndEditing(_ textField: UITextField) {
        let i = textField.tag
        if i % 2 == 1 {
            array[i / 2]["name"] = textField.text!
        }
        else {
            var str:String = textField.text!
            if str == "" {
                str = "0.00"
            }
            array[i / 2 - 1]["price"] = str
        }
    }
    
    func handleAttachmentGesture(_ sender: UIPanGestureRecognizer) {
        if (editBarButtonItem.title == "Done") {
            let location = sender.location(in: self.view)
            let myButton = sender.view!
            let boxLocation = sender.location(in: myButton)
            
            switch sender.state {
            case .began:
                animator.removeAllBehaviors()
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
            for i in (index + 1)..<buttonArray.count {
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
		
		cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.red, callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			print("Convenience callback for swipe buttons!")
			let row = tableView.indexPath(for: sender)!.row
			self.array.remove(at: row)
            self.itemArray.remove(at: row)
			tableView.deleteRows(at: [tableView.indexPath(for: sender)!], with: .left)
			for (key, val) in self.selectedDict {
				if val.contains(row) {
					self.selectedDict[key]!.remove(row)
				}
				var temp:Array<Int> = []
				for num in val {
					if num > row {
						self.selectedDict[key]!.remove(num)
						temp.append(num - 1)
					}
				}
				for i in temp {
					self.selectedDict[key]!.insert(i)
				}
			}
            tableView.reloadData()
			self.calculateTotal()
			return true
		})]
		
        // TODO:
        // 1. add toolbar with "Done" button for the decimal Pad
        
		cell.rightSwipeSettings.transition = MGSwipeTransition.border
		
        let item : UITextField = cell.itemTextField
		item.autocorrectionType = .no
        let price : UITextField = cell.priceTextField
        item.tag  = 2 * row + 1
        price.tag = 2 * row + 2
        price.keyboardType = UIKeyboardType.decimalPad
		price.inputAccessoryView = UIToolbar()
        
        if editBarButtonItem.title == "Edit" {
            item.isUserInteractionEnabled = false
            price.isUserInteractionEnabled = false
            item.borderStyle = UITextBorderStyle.none
            price.borderStyle = UITextBorderStyle.none
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
        else {
            item.isUserInteractionEnabled = true
            price.isUserInteractionEnabled = true
            item.borderStyle = UITextBorderStyle.roundedRect
            price.borderStyle = UITextBorderStyle.roundedRect
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
		
		if buttonArray.isEmpty {
			cell.selectionStyle = UITableViewCellSelectionStyle.none
		}
		
        item.text = array[row]["name"]
        if (editBarButtonItem.title == "Edit") {
            price.text = "$" + array[row]["price"]!
        }
        else {
            price.text = array[row]["price"]!
        }
		if curHighlightButton != nil && itemArray[indexPath.row].contains(curHighlightButton!) {
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
		}
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if buttonArray.isEmpty {
			showMessage(title: nil, message: "You have to add a contact first")
			return
		}
        if editBarButtonItem.title == "Edit" {
            let row = indexPath.row
            if (curHighlightButton != nil) {
                itemArray[row].insert(curHighlightButton!)
				selectedDict[curHighlightButton!]!.insert(indexPath.row)
				
				var sum:Double = 0.0
				for item in selectedDict[curHighlightButton!]! {
					sum = sum + (array[item]["price"]! as NSString).doubleValue / Double(itemArray[item].count)
				}
				if sum < 0 {
					totalLabel.text = String(format:"Total: $0.00")
				} else {
					totalLabel.text = String(format:"Total: $%.2f", sum)
				}
            }
        }
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if buttonArray.isEmpty {
			showMessage(title: nil, message: "You have to add a contact first")
			return
		}
        if editBarButtonItem.title == "Edit" {
            let row = indexPath.row
            if (curHighlightButton != nil) {
                itemArray[row].remove(curHighlightButton!)
				selectedDict[curHighlightButton!]!.remove(indexPath.row)
				var sum:Double = 0.0
				for item in selectedDict[curHighlightButton!]! {
					sum = sum + (array[item]["price"]! as NSString).doubleValue / Double(itemArray[item].count)
				}
				if sum < 0 {
					totalLabel.text = String(format:"Total: $0.00")
				} else {
					totalLabel.text = String(format:"Total: $%.2f", sum)
				}
            }
            else {
            }
        }
	}
	
	func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
		if direction == MGSwipeDirection.rightToLeft {
			return true
		}
		return false
	}
	
//	func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
//		
//		swipeSettings.transition = MGSwipeTransition.border;
//		expansionSettings.buttonIndex = 0;
//		
//		
//		let mail = mailForIndexPath(tableView.indexPath(for: cell)!)
//		
//		if direction == MGSwipeDirection.rightToLeft {
//			expansionSettings.fillOnTrigger = true;
//			expansionSettings.threshold = 1.1;
//			let padding = 15;
//			let color1 = UIColor.init(red:1.0, green:59/255.0, blue:50/255.0, alpha:1.0);
//			let color2 = UIColor.init(red:1.0, green:149/255.0, blue:0.05, alpha:1.0);
//			let color3 = UIColor.init(red:200/255.0, green:200/255.0, blue:205/255.0, alpha:1.0);
//			
//			let trash = MGSwipeButton(title: "Trash", backgroundColor: color1, padding: padding, callback: { (cell) -> Bool in
//				self.deleteMail(self.tableView.indexPath(for: cell)!);
//				return false; //don't autohide to improve delete animation
//			});
//			
//			
//			return [trash, flag, more];
//		}
//		
//	}
	
    func shakeButton() {
        let frame = CAKeyframeAnimation(keyPath: "transform.rotation")
        let left = CGFloat(-M_PI_2*0.20)
        let right = CGFloat(M_PI_2*0.20)
		
        frame.values = [left, right, left];
        frame.duration = 0.2;
        frame.repeatCount = Float.infinity;
		
        for button in buttonArray {
            button.layer.add(frame, forKey: nil)
        }
        // panGesture.isEnabled = true
        addButton.isHidden = true
    }
    
    func showMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
//    func requestForContactsAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
//        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
//        
//        switch authorizationStatus {
//        case .authorized:
//            completionHandler(true)
//            
//        case .denied, .notDetermined:
//            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
//                if access {
//                    completionHandler(access)
//                }
//                else {
//                    if authorizationStatus == CNAuthorizationStatus.denied {
//                        DispatchQueue.main.async(execute: { () -> Void in
//                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
//                            self.showMessage(title: "Warning", message: message)
//                        })
//                    }
//                }
//            })
//            
//        default:
//            completionHandler(false)
//        }
//    }
	
	func deleteContact(_ sender: UIButton) {
		print("contact to be deleted")
	}
	
    func addContact(_ sender: UIButton) {
        print ("button to addcontact clicked")
        
        // TODO:
        // 1. change name property to First Name and Last Name
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        let createAction = UIAlertAction(title: "Create new contact", style: .default) { (_) in
            self.newContactType = .blank
            self.performSegue(withIdentifier: "ToAddContact", sender: sender)
        }
        let importAction = UIAlertAction(title: "Import from Contacts", style: .default) { (_) in
            self.newContactType = .contacts
            self.importContact(sender)
        }
        let importRecentAction = UIAlertAction(title: "Recent Contacts", style: .default) { (_) in
            // Save recent contacts...
            self.showMessage(title: "INFO", message: "Functionality under development.")
        }
        let importFacebookAction = UIAlertAction(title: "Import from Facebook", style: .default) { (_) in
            // Exploit Facebook API...
            self.showMessage(title: "INFO", message: "Functionality under development.")
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        alertController.addAction(importRecentAction)
        alertController.addAction(importAction)
        alertController.addAction(importFacebookAction)
        
        self.present(alertController, animated: true) {}
	}
    
    func importContact(_ sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        self.present(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact){
//        let name: String = contact.givenName + " " + contact.familyName
        var name: String = ""
        if !contact.givenName.isEmpty {
            name = String(contact.givenName[contact.givenName.startIndex]).uppercased()
        }
        if !contact.familyName.isEmpty {
            if name != "" {
                name += "."
            }
            name += String(contact.familyName[contact.familyName.startIndex]).uppercased()
        }
        var phone: String = ""
        var email: String = ""
        
//        just get the first email
        if contact.emailAddresses.count > 0 {
            email = contact.emailAddresses[0].value as String
        }
        for number in contact.phoneNumbers {
            if number.label == CNLabelPhoneNumberMobile {
                phone = number.value.stringValue
            }
        }
        
        newContact["name"] = name
        newContact["mobile"] = phone
        newContact["email"] = email
        
        self.performSegue(withIdentifier: "ToAddContact", sender: addButton)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
	
	func changeContact(_ sender: UIButton) {
		print ("Normal tap")
        if (editBarButtonItem.title == "Done") {
            self.performSegue(withIdentifier: "ToAddContact", sender: sender)
        }
        else {
            curHighlightButton?.layer.backgroundColor = UIColor.gray.cgColor
            sender.layer.backgroundColor = UIColor(red: 39.0/255.0, green: 78.0/255.0, blue: 192.0/255.0, alpha: 1.0).cgColor
            curHighlightButton = sender
			
            tableView.reloadData()
			
			calculateTotal()
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
        editBarButtonItem.title = "Done"
		panGesture.isEnabled = true
        addButton.isHidden = true
	}
	
	func userDidEnterInformation(name: String, mobile: String, email: String) {
		print(name)
        if editBarButtonItem.title == "Done" && editedIndex != -1 {
            buttonArray[editedIndex].setTitle(name, for: UIControlState.normal)
            contactArray[editedIndex]["name"]   = name
            contactArray[editedIndex]["mobile"] = mobile
            contactArray[editedIndex]["email"]  = email
            editedIndex = -1
        }
        else {
            contactArray.append(["name": name, "mobile": mobile, "email": email])
            let usrButton = UIButton()
			usrButton.tag = startingTag
			startingTag = startingTag + 1
            usrButton.frame = CGRect(x: start, y: margin, width: width, height: height)
            usrButton.layer.cornerRadius = 25
            usrButton.layer.backgroundColor = UIColor.gray.cgColor
            //		usrButton.showsTouchWhenHighlighted = true
            usrButton.addTarget(self, action: #selector(DetailViewController.changeContact(_:)), for: UIControlEvents.touchUpInside)
			
			// let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.longTap(_:)))
            // usrButton.addGestureRecognizer(longGesture)
			// usrButton.addGestureRecognizer(panGesture)
			panGesture.isEnabled = false
			
            usrButton.setTitle(name, for: UIControlState.normal)
            start += width + sep
            
            addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
			
			selectedDict[usrButton] = Set<Int>()
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
	
	func photoEndedRecognition(myarray: Array<Dictionary<String, String>>) {
		array.append(contentsOf: myarray)
		for _ in 0..<myarray.count {
			itemArray.append(Set<UIButton>())
		}
		tableView.reloadData()
	}
	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        array[textField.tag / 2]["name"] = textField.text
        textField.resignFirstResponder()
        return true
    }
	
    func becomeActive(_ notification: NSNotification) {
        editBarButtonItem.title = "Edit"
        addButton.isHidden      = false
		panGesture.isEnabled    = false
    }
    
    func addItemButtonTapped(_ sender: UIButton) {
        print ("button to add item clicked")
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (action) in }
        let addSingleItemAction = UIAlertAction(title: "Add single item",
                                                style: .default) { (_) in
            self.addSingleItem();
        }
        let addPhotoAction = UIAlertAction(title: "Add receipt from camera",
                                           style: .default) { (_) in
            self.addReceiptFromPhoto();
        }
        let addAlbumAction = UIAlertAction(title: "Add receipt from album",
                                           style: .default) { (_) in
            self.addReceiptFromAlbum();
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addSingleItemAction)
        alertController.addAction(addPhotoAction)
        alertController.addAction(addAlbumAction)
        
        self.present(alertController, animated: true) {}
    }
    
    func addSingleItem() {
        var nameValid: Bool = false
        var priceValid: Bool = false
        
        let alertController = UIAlertController(title: "Add Single Item",
                                                message: nil,
                                                preferredStyle: .alert)
        
        let addItemAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let nameField  = alertController.textFields![0] as UITextField
            let priceField = alertController.textFields![1] as UITextField
            
            self.array.append(["name": nameField.text!,
                               "price": priceField.text!])
            self.itemArray.append(Set<UIButton>())
            self.tableView.reloadData()
        }
        addItemAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Item Name"
            textField.borderStyle = UITextBorderStyle.none
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                nameValid = (textField.text != "")
                addItemAction.isEnabled = nameValid && priceValid
            }
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Item Price"
            textField.borderStyle = UITextBorderStyle.none
//            textField.text = "0.0"
//            if set to 0.0, should clear the text when user start editing
            textField.text = ""
            textField.keyboardType = UIKeyboardType.decimalPad
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                let num = Double(textField.text!)
                priceValid = (textField.text != "") && num != nil
                addItemAction.isEnabled = nameValid && priceValid
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addItemAction)
        
        self.present(alertController, animated: true) {}
    }
    
    func addReceiptFromPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
        else {
            self.showMessage(title: "Sorry!", message: "Cannot access camera.")
        }
    }
    
    func addReceiptFromAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
        else {
            self.showMessage(title: "Sorry!", message: "Cannot access camera.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("didFinishPickingImage")
            if (picker.sourceType == .camera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            self.image = image
        }
        else {
            print("Something went wrong")
        }
        picker.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "ToCrop", sender: self)
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
		
        tableView!.estimatedRowHeight = 50.0
        tableView!.rowHeight = UITableViewAutomaticDimension
		// Do any additional setup after loading the view.
		// containerView.backgroundColor = UIColor.yellow
		itemArray = Array(repeating: Set<UIButton>(), count: array.count)
		scrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        editBarButtonItem.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "TrebuchetMS", size:18)!,
            NSForegroundColorAttributeName : UIColor.white,NSBackgroundColorAttributeName:UIColor.black],
                                                 for: UIControlState.normal)
        
		addButton.frame = CGRect(x: start, y: margin, width: width, height: height)
		let cameraImage = UIImage(named:"assets/add.png")?.withRenderingMode(.automatic)
		addButton.setImage(cameraImage, for:.normal)
		
		self.containerView.addSubview(addButton)
		addButton.addTarget(self, action: #selector(DetailViewController.addContact(_:)), for: UIControlEvents.touchUpInside)
		
		self.containerView.frame = CGRect(x: 0, y: 0, width: start + width + sep, height: 70)
		self.scrollView.contentSize = CGSize(width: start + width + sep, height: 70)
		self.automaticallyAdjustsScrollViewInsets = false
		scrollView.addSubview(containerView)
        
        let footerView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:35))
        let addItemButton = UIButton()
        addItemButton.frame = CGRect(x: self.view.frame.midX - 40, y: 0, width: 80, height: 35)
        // loginButton.addTarget(self, action: "loginAction", forControlEvents: .TouchUpInside)
        addItemButton.setTitle("Add", for: UIControlState.normal)
        addItemButton.setTitleColor(UIColor(red: 39/255.0, green: 78/255.0, blue: 192/255.0, alpha: 0.7), for: UIControlState.normal)
        addItemButton.layer.borderWidth = 2
        addItemButton.layer.borderColor = UIColor(red: 39/255.0, green: 78/255.0, blue: 192/255.0, alpha: 0.7).cgColor
        addItemButton.addTarget(self, action: #selector(DetailViewController.addItemButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        footerView.addSubview(addItemButton)
        tableView.tableFooterView = footerView
	}
    
    override func viewDidAppear(_ animated: Bool) {
        if editBarButtonItem.title == "Done" {
            shakeButton()
        }
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if (identifier == "ToAddContact") {
                let svc = segue.destination as! AddContactViewController
                svc.delegate = self
                let button = sender as! UIButton
				svc.replace = false
                if button != addButton {
                    editedIndex = buttonArray.index(of: button)!
                    let dict: Dictionary<String, String> = contactArray[editedIndex]
                    svc.name    = dict["name"]
                    svc.mobile  = dict["mobile"]
                    svc.email   = dict["email"]
					svc.replace = true
					svc.originalName = dict["name"]
                }
                else if newContactType == .contacts {
                    svc.name   = newContact["name"]
                    svc.mobile = newContact["mobile"]
                    svc.email  = newContact["email"]
                    newContact = [String: String]()
                }
                newContactType = .blank
				svc.contactArray = self.contactArray
				
            }
            else if (identifier == "ToSummary") {
                let svc = segue.destination as! SummaryViewController
                
                var itemDict:Dictionary<String, Array<String>> = [:]
                var priceDict:Dictionary<String, Array<String>> = [:]
                var totalDict:Dictionary<String, Double> = [:]
                for contact in contactArray {
                    // name cannot be the same
                    itemDict[contact["name"]!] = []
                    priceDict[contact["name"]!] = []
                    totalDict[contact["name"]!] = 0
                }
                for i in 0..<itemArray.count {
                    let set = itemArray[i]
                    for button in set {
                        itemDict[button.title(for: UIControlState.normal)!]?.append(array[i]["name"]!)
                        priceDict[button.title(for: UIControlState.normal)!]?.append("$" + array[i]["price"]!)
                        let val = (array[i]["price"]! as NSString).doubleValue / Double(set.count)
                        totalDict[button.title(for: UIControlState.normal)!]? += val
                    }
                }
                svc.itemDict = itemDict
                svc.priceDict = priceDict
                svc.totalDict = totalDict
                svc.contactArray = self.contactArray
            }
            else if (identifier == "ToCrop") {
                let svc = segue.destination as! CropViewController;
				svc.delegate = self
                svc.image = self.image
				svc.fromMainScreen = false
            }
        }
    }
}
