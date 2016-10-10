//
//  AddContactViewController.swift
//  split
//
//  Created by James on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath as IndexPath)
        let label : UILabel = self.view.viewWithTag(1) as! UILabel
        let textField : UITextField = self.view.viewWithTag(2) as! UITextField
        if indexPath.row == 0 {
            label.text = "Name"
            textField.keyboardType = UIKeyboardType.namePhonePad
        } else if indexPath.row == 1 {
            label.text = "Mobile"
            textField.keyboardType = UIKeyboardType.numberPad
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
            toolBar.barStyle = UIBarStyle.default
            toolBar.items = [
                UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.keyboardCancelButtonTapped(_:))),
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.keyboardDoneButtonTapped(_:)))]
            toolBar.sizeToFit()
            textField.inputAccessoryView = toolBar
        } else if indexPath.row == 2 {
            label.text = "Email"
            textField.keyboardType = UIKeyboardType.emailAddress
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func saveContact(_ sender: UIButton) {
        print("click")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardCancelButtonTapped(_ textField: UITextField) {
        textField.text = ""
    }
    
    func keyboardDoneButtonTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Person"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
