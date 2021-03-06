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
    @IBOutlet weak var cinazaodyn: UITextField!
    @IBOutlet weak var knopka: UIButton!
    @IBOutlet weak var cinaZaOd: UILabel!
    
    var myArray = [String]()
    var moneyArray = ["USD", "EUR", "RUB", "UAH", "PLN"]
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
        
        addHistoryButton()
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
    
    func addHistoryButton() {
        let historyButton = UIBarButtonItem(title: "History",
                                            style: .plain,
                                            target: self,
                                            action: #selector(showHistory))
        navigationItem.rightBarButtonItem = historyButton
    }
    
    func showHistory() {
        let history = HistoryTVC()
        history.delegate = self
        
        navigationController?.pushViewController(history, animated: true)
    }

    func createDataWithArrayType() -> [String] {
        if SegmentControl.selectedSegmentIndex == 0{
            myArray = ["kg","g","k","mg","ft", "oz"]
        } else {
            myArray = ["l","ml","gallon","pint"]
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
            textField2.text = "l"
            textField6.text = "l"
        } else {
            textField2.text = "kg"
            textField6.text = "kg"
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
        picker.reloadAllComponents()
        for (index, element) in myArray.enumerated(){
            if element == textField.text {
                picker.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    
    @IBAction func obrahyvaty() {
        cinaZaOd.text = "Ціна (\(textField8.text!)/\(textField6.text!)):"
        guard let kg = textField2.text,
            let f = textField6.text,
            let sto1 = textField1.text,
            let usd = textField4.text,
            let eur = textField8.text,
            let sto2 = textField3.text,
            sto1.characters.count > 0,
            sto2.characters.count > 0 else {
                let alert = UIAlertController(title: "Помилка",
                                              message: "Помилка сервера",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))
                present(alert, animated: true, completion: nil)
                return
        }
        
        
        
        knopka.isEnabled = false
        
        ServerAPIManager.send(data: "\(kg)_\(f)_\(sto1)_\(usd)_\(eur)_\(sto2)") {
            success, string in
            
            self.knopka.isEnabled = true
            
            if success {
                let newString = string.replacingOccurrences(of: ",", with: ".")
                let vaga = Float(newString.components(separatedBy: " ")[0])
                let kyrs = Float(newString.components(separatedBy: " ")[1])
                let zaOdyn = Float(newString.components(separatedBy: " ")[2])
                
                self.textField5.text = "\(vaga ?? 0)"
                self.textField7.text = "\(kyrs ?? 0)"
                self.cinazaodyn.text = "\(zaOdyn ?? 0)"
                
                
                CoreDataManager.shared.add(param1: sto1,
                                           param2: kg,
                                           param3: sto2,
                                           param4: usd,
                                           param5: "\(vaga ?? 0)",
                                           param6: f,
                                           param7: "\(kyrs ?? 0)",
                                           param8: eur,
                                           param9: "\(zaOdyn ?? 0)")
                
                
                
            } else {
                let alert = UIAlertController(title: "Помилка",
                                              message: "Помилка сервера",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
}

//MARK: - HistoryTVCDelegate
extension MainVC: HistoryTVCDelegate {
    func didSelectHistoryItem(item: History) {
        print("DID SELECTE HISTORY ITEM")
        textField3.text = item.inputValue
        textField4.text = item.inputValueMeasure
        textField1.text = item.inputPrice
        textField2.text = item.inputPriceMeasure
        textField7.text = item.outputValue
        textField8.text = item.outputValueMeasure
        textField5.text = item.outputPrice
        textField6.text = item.outputPriceMeasure
        cinazaodyn.text = item.pricePerUnit
    }
}
