//
//  rateViewController.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 30/6/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//
// Reference: https://github.com/evgenyneu/Cosmos

import UIKit
import Cosmos
import iOSDropDown

//final record saving viewController

struct detailCoffeeTaste {
    var coffeeTaste: String
    var coffeeTasteValue: Double
}

var test = 0.0
//var cell:UITableViewCell = UITableViewCell()

class rateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder() 兩種寫法皆可
        self.view.endEditing(true)
        return true
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrayTaste.count)
        return arrayTaste.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasteItem", for: indexPath)
        
        let lblTaste = cell.viewWithTag(5000) as? UILabel
        lblTaste?.text = arrayTaste[indexPath.row].coffeeTaste
        let slider = cell.viewWithTag(5002) as? UISlider
        
        slider?.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func sliderChange(_ sender: UISlider){
        //print(sender.value)
        let sliderPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblDetailTaste)
        let indexPath = self.tblDetailTaste.indexPathForRow(at: sliderPosition)!
        let lblTaste = tblDetailTaste.cellForRow(at: indexPath)?.viewWithTag(5000) as? UILabel
        let lblValue = tblDetailTaste.cellForRow(at: indexPath)?.viewWithTag(5001) as? UILabel
        //print(indexPath.row) // row = for array index use
        lblValue?.text = String(format: "%.2f",sender.value)
      
        for i in 0...(arrayTaste.count - 1) {
            if arrayTaste[i].coffeeTaste == lblTaste?.text {
                arrayTaste[i].coffeeTasteValue = round(Double(sender.value) * 100)/100 // 2 d.p.
               // print(arrayTaste[i].coffeeTaste)
               // print(arrayTaste[i].coffeeTasteValue)
            }
        }
    }
    
    
    //var test:Double = 0.0
    // ********************************* For Database Passed
    var totalTimePassed: String = ""
    var initBloomTempPassed: String = ""
    var initBrewTempPassed: String = ""
    var finalBrewTempPassed: String = ""
    var avgTempPassed: String = ""
    var totalWaterInfusedPassed: String = ""
    var coffeeProducedPassed: String = ""
    var numOfPourPassed: String = ""
    
    //chart data passed (as String)
    var dataStrTempPassed: String = ""
    var dataStrInVolPassed: String = ""
    var dataStrOutVolPassed: String = ""
    
    //pour data passed (as String)
    var dataStrPouringPassed: String = ""
    
    var coffeeTypeSelected: String = ""
    var arrayTaste:Array<detailCoffeeTaste> = [detailCoffeeTaste]()
    
    
    
    @IBOutlet weak var tblDetailTaste: UITableView!
    
    @IBOutlet weak var textfieldName: UITextField!
    var name: String = ""
    
    @IBOutlet weak var overallRateBar: CosmosView!
    
    func rateBarSetting () {
        // Change the cosmos view rating
        // default rate = 0
        overallRateBar.rating = 0.0
        overallRateBar.settings.fillMode = .precise
       
        // Touch Interaction
        overallRateBar.didFinishTouchingCosmos = { rating in }
        overallRateBar.didTouchCosmos = { rating in }
    }
    
    @IBOutlet weak var coffeeList: DropDown!

    func coffeeListSetting() {
        coffeeList.optionArray = ["Baron Goto Red", "Blue Mountain", "Bourbon", "Catimor", "Caracol", "Excelsa", "Emerald Mountain", "Guadalupe", "Icatu", "Wild Coffee"]
        //Its Id Values and its optional // make it be index
        coffeeList.optionIds = [0,1,2,3,4,5,6,7,8,9]
        coffeeList.didSelect{(selectedText, index ,id) in
            self.coffeeTypeSelected = selectedText
        }
    }
    
    
    @IBAction func btnSave(_ sender: Any) { // save passed data and rate data
        //test = overallRateBar.rating
        //name = textfieldName.text!
        
        let coffeeId = RecordEntity.shared.insert(coffeeName: textfieldName.text!,
                                                  coffeeType: coffeeTypeSelected,
                                                  coffeeRating: overallRateBar.rating,
                                                  coffeeDataTemp: dataStrTempPassed,
                                                  coffeeDataInVol: dataStrInVolPassed,
                                                  coffeeDataOutVol: dataStrOutVolPassed,
                                                  coffeeDataPouring: dataStrPouringPassed,
                                                  coffeeTotalTimeSpent: totalTimePassed,
                                                  coffeeInitBloomTemp: initBloomTempPassed,
                                                  coffeeInitBrewTemp: initBrewTempPassed,
                                                  coffeeFinalBrewTemp: finalBrewTempPassed,
                                                  coffeeAvgTemp: avgTempPassed,
                                                   coffeeTotalWaterInfused: totalWaterInfusedPassed,
                                                   coffeeTotalCoffeeProduced: coffeeProducedPassed,
                                                   coffeeNumOfPour: numOfPourPassed)!
        print(coffeeId)
        
        let coffeeTasteId = RecordTasteEntity.shared.insert(TasteFragranceValue: arrayTaste[0].coffeeTasteValue, TasteFlavorValue: arrayTaste[1].coffeeTasteValue, TasteAftertasteValue: arrayTaste[2].coffeeTasteValue, TasteAcidityValue: arrayTaste[3].coffeeTasteValue, TasteBodyValue: arrayTaste[4].coffeeTasteValue, TasteBalanceValue: arrayTaste[5].coffeeTasteValue, TasteSweetnessValue: arrayTaste[6].coffeeTasteValue, TasteCleanCupValue: arrayTaste[7].coffeeTasteValue, TasteUniformityValue: arrayTaste[8].coffeeTasteValue, TasteOverallValue: overallRateBar.rating, coffeeID: coffeeId)
        
       // var test = RecordTasteEntity.shared.getCoffeeId(record: Int(coffeeTasteId))
        //print(test)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rateBarSetting()
        coffeeListSetting()
        self.hideKeyboardWhenTappedAround()
        
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Fragrance", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Flavor", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Aftertaste", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Acidity", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Body", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Balance", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Sweetness", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Clean Cup", coffeeTasteValue: 0.0))
        arrayTaste.append(detailCoffeeTaste(coffeeTaste: "Uniformity", coffeeTasteValue: 0.0))
        
        print(arrayTaste.count)
        
        self.tblDetailTaste.delegate = self
        self.tblDetailTaste.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
