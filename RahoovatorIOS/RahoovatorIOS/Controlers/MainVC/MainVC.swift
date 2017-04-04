//
//  MainVC.swift
//  RahoovatorIOS
//
//  Created by Юра on 17.03.17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var SegmentControl: UISegmentedControl!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var textField7: UITextField!
    @IBOutlet weak var textField8: UITextField!
    
    var myArray = [String]()
    var moneyArray = ["USD", "EUR", "RUB", "UAH"]
    var picker = UIPickerView()
    var activTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Rahoovator"
        textField5.isEnabled = false
        textField7.isEnabled = false
        myArray = createDataWithArrayType()

        createCodePicker(array: myArray)
        closeCouesor()
    }

    func closeCouesor() {
        textField2.tintColor = UIColor.clear
        textField4.tintColor = UIColor.clear
        textField6.tintColor = UIColor.clear
        textField8.tintColor = UIColor.clear
        
    }
    func createCodePicker(array:[String]) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor(red:69/255,
                                         green:59/255,
                                         blue:58/255,
                                         alpha:1.0)
        picker.tintColor = UIColor.blue
        
        textField2.inputView = picker
        textField4.inputView = picker
        textField6.inputView = picker
        textField8.inputView = picker

    }

    func createDataWithArrayType() -> [String] {
        if SegmentControl.selectedSegmentIndex == 0{
            myArray = ["мг","г","кг","ц","т"]
        } else {
            myArray = ["мм^3","см^3","л","м^3"]
        }
        return myArray
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        let nextField = textField.superview?.viewWithTag(nextTag)
        if let field = nextField {
            field.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func SegmentAction(_ sender: Any) {
        hideKeyboard()
        myArray = createDataWithArrayType()
        if SegmentControl.selectedSegmentIndex == 1{
            textField2.text = "л"
            textField6.text = "л"
        } else {
            textField2.text = "кг"
            textField6.text = "кг"
        }
    }
    
    //MARK: - Custom methods
    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - PickerView delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return myArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activTextField.text = myArray[row]    }
    
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        activTextField.text = "\(myArray[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = myArray[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia",
                                                                                                    size: 15.0)!,
                                                                         NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    
    //MARK: - text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activTextField = textField
        if activTextField == textField4 || activTextField == textField8{
            myArray = moneyArray
        }
        else
        {
            myArray = createDataWithArrayType()
        }
        for (index, element) in myArray.enumerated(){
            if element == textField.text {
                picker.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }


}
