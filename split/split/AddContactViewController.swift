//
//  AddContactViewController.swift
//  split
//
//  Created by James on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController,  UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButtonClicked(_ sender: AnyObject) {
        print("save button clicked")
        // check email/mobile filled
        // save
        self.dismiss(animated: true, completion:nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardCancelButtonTapped() {
        mobileTextField.text = ""
        mobileTextField.resignFirstResponder()
    }
    
    func keyboardDoneButtonTapped() {
        mobileTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Person"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        saveButton.layer.cornerRadius = 8
        nameTextField.keyboardType = UIKeyboardType.namePhonePad
        mobileTextField.keyboardType = UIKeyboardType.numberPad
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(self.keyboardCancelButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(self.keyboardDoneButtonTapped))]
        toolBar.sizeToFit()
        mobileTextField.inputAccessoryView = toolBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
