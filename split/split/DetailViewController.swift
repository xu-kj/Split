//
//  DetailViewController.swift
//  split
//
//  Created by Shuo Chen on 10/9/16.
//  Copyright © 2016 panaroma. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {

    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var scrollView: UIScrollView!
    var containerView = UIView()
	var start = 20
	var width = 80
	
    var array: Array<Dictionary<String, String>> = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath as IndexPath)
        let item : UILabel = self.view.viewWithTag(1) as! UILabel;
        let price : UILabel = self.view.viewWithTag(2) as! UILabel;
        item.text = array[indexPath.row]["name"]
        price.text = "$" + array[indexPath.row]["price"]!
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Bill Details"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
		
        // Do any additional setup after loading the view.
		//containerView.backgroundColor = UIColor.yellow
		scrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
		
		let addButton = UIButton()
		//addButton.backgroundColor   = UIColor.green
		addButton.frame = CGRect(x: start, y: 10, width: 50, height: 50)
		addButton.setTitle("+", for: UIControlState.normal)
		let cameraImage = UIImage(named:"assets/add.png")?.withRenderingMode(.automatic)
		addButton.setImage(cameraImage, for:.normal)

		self.containerView.addSubview(addButton)
		start = start + width
		addButton.addTarget(self, action: #selector(DetailViewController.addContact(_:)), for: UIControlEvents.touchUpInside)
		//Button.addTarget(self, action: "Action:", forControlEvents: UIControlEvents.TouchUpInside)
		//}
		
		//self.scrollView.delegate = self
		self.containerView.frame = CGRect(x: 0, y: 0, width: start, height: 70)
		self.scrollView.contentSize = CGSize(width: start, height: 70)
		self.automaticallyAdjustsScrollViewInsets = false
		scrollView.addSubview(containerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	
	func userDidEnterInformation(info: String) {
		//label.text = info
		print(info)
		let usrButton = UIButton();
		usrButton.frame = CGRect(x: start, y: 10, width: 50, height: 50)
		start = start + width
		usrButton.setTitle(info, for: UIControlState.normal)
		
		self.containerView.addSubview(usrButton)
		self.containerView.frame = CGRect(x: 0, y: 0, width: start, height: 70)
		self.scrollView.contentSize = CGSize(width: start, height: 70)
	}

}
