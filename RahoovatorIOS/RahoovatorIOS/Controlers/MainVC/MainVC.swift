//
//  MainVC.swift
//  RahoovatorIOS
//
//  Created by Юра on 17.03.17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var textField7: UITextField!
    @IBOutlet weak var textField8: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Rahoovator"
        textField5.isEnabled = false
        textField7.isEnabled = false
    }



}
