//
//  SummaryViewController.swift
//  split
//
//  Created by Shuo Chen on 11/15/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit
import MessageUI

class SummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var messageBarButtonItem: UIBarButtonItem!
    
    var itemDict:Dictionary<String, Array<String>> = [:]
    var priceDict:Dictionary<String, Array<String>> = [:]
    var totalDict:Dictionary<String, Double> = [:]
    var contactArray: Array<Dictionary<String, String> > = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(contactArray.count)
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactArray[section]["name"]
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
        // headerView.backgroundColor = UIColor.lightGray
        let label = UILabel()
        headerView.backgroundColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
        label.frame = CGRect(x:10, y:0, width:tableView.frame.size.width, height:30)
        label.font = UIFont(name: "TrebuchetMS-Bold", size:20)
        // label.textColor = UIColor.white
        label.text = contactArray[section]["name"]!
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30;
    }
    
    /*
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //add gesture to fold
        return String(format: "Subtotal: $%.2f", totalDict[contactArray[section]["name"]!]!)
    }
    */
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
        // headerView.backgroundColor = UIColor.lightGray
        let label = UILabel()
        headerView.backgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
        label.frame = CGRect(x:0, y:0, width:tableView.frame.size.width - 12, height:30)
        label.font = UIFont(name: "TrebuchetMS-Bold", size:18)
        label.textAlignment = NSTextAlignment.right
        // label.textColor = UIColor.white
        label.text = String(format: "Subtotal: $%.2f", totalDict[contactArray[section]["name"]!]!)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemDict)
        print(itemDict[contactArray[section]["name"]!])
        return itemDict[contactArray[section]["name"]!]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let item:UILabel = self.view.viewWithTag(1) as! UILabel;
        let price:UILabel = self.view.viewWithTag(2) as! UILabel;
        item.text = itemDict[contactArray[section]["name"]!]?[row]
        price.text = priceDict[contactArray[section]["name"]!]?[row]
        return cell
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Summary"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        emailBarButtonItem.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "TrebuchetMS", size:18)!,
            NSForegroundColorAttributeName: UIColor(red: 39/255.0, green: 78/255.0, blue: 192/255.0, alpha: 0.9),NSBackgroundColorAttributeName:UIColor.black],
                                                  for: UIControlState.normal)
        messageBarButtonItem.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "TrebuchetMS", size:18)!,
            NSForegroundColorAttributeName: UIColor(red: 39/255.0, green: 78/255.0, blue: 192/255.0, alpha: 0.9), NSBackgroundColorAttributeName:UIColor.black],
                                                    for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
