//
//  AddContactViewController.swift
//  split
//
//  Created by James on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

protocol DataEnteredDelegate: class {
    func userDidEnterInformation(name: String, mobile: String, email: String)
}

class AddContactViewController: UIViewController,  UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
	weak var delegate: DataEnteredDelegate? = nil
    
    var name:String!
    var mobile:String!
    var email:String!
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
	
    @IBAction func saveButtonClicked(_ sender: AnyObject) {
        print("save button clicked")
        // check email/mobile filled
        // save
		
        delegate?.userDidEnterInformation(name: nameTextField.text!, mobile: mobileTextField.text!, email: emailTextField.text!)
        self.dismiss(animated: true, completion:nil)//TODO:check
        _ = self.navigationController?.popViewController(animated: true)
    }
	
	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func keyboardCancelButtonTapped() {
//        mobileTextField.text = ""
//        mobileTextField.resignFirstResponder()
//    }
    
    func keyboardDoneButtonTapped() {
        mobileTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Contact"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        saveButton.layer.cornerRadius = 8
        nameTextField.keyboardType = UIKeyboardType.namePhonePad
        mobileTextField.keyboardType = UIKeyboardType.numberPad
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
//            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(self.keyboardCancelButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(self.keyboardDoneButtonTapped))]
        toolBar.sizeToFit()
        mobileTextField.inputAccessoryView = toolBar
        
        nameTextField.text = name
        mobileTextField.text = mobile
        emailTextField.text = email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
