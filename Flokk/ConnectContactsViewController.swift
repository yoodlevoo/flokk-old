//
//  ConnectContacts.swift
//  Flokk
//
//  Created by Jared Heyen on 4/2/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

class ConnectContactsViewController: UIViewController {
    @IBOutlet weak var phoneNumber: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.phoneNumber.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "segueFromConnectContactsToGroups", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromConnectContactsToGroups" {
            // Would i even pass anything here
        }
    }
}
