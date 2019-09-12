//
//  PourOverViewController.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 24/6/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//
// Timer Reference: http://iosbrain.com/blog/2018/10/31/using-the-swift-4-2-timer-class-in-xcode-10/
// Install Homebrew: http://osxdaily.com/2018/03/07/how-install-homebrew-mac-os/
// guide: Applications/Utilities/Terminal -> /usr/bin/ruby -e "$(curl -fsSL
//        https://raw.githubusercontent.com/Homebrew/install/master/install
// Install Ruby: brew install ruby
// Install Cocoapods: sudo gem install cocoapods
// Chart instruction ********* import Charts under the class **********: https://medium.com/@OsianSmith/creating-a-line-chart-in-swift-3-and-ios-10-2f647c95392e

import UIKit
import Charts
import CoreBluetooth
import Foundation // for modulus
import AudioToolbox

struct detailPour // Struct Created for detail recording
{
    var pourCount: Int
    var pourStartingTime: Double
    var pourEndingTime: Double
    var pourTotalTime: Double
    var pourInfusedWater: Double
    var pourSpeed: Double
    
    var pourTimeStr: String
    var pourInfusedWaterStr: String
    var pourSpeedStr: String
}

var dataStrTemp = ""
var dataStrInVol = ""
var dataStrOutVol = ""

var arrayPour:Array<detailPour> = Array ()
var newPour:detailPour = detailPour(pourCount: 0, pourStartingTime: 0.0, pourEndingTime: 0.0, pourTotalTime: 0.0, pourInfusedWater: 0.0, pourSpeed: 0.0, pourTimeStr: "", pourInfusedWaterStr: "", pourSpeedStr: "")

class PourOverViewController: UIViewController {
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    
    // ********** BLE setting ****************
    
    @IBOutlet weak var imageBLE: UIImageView!
    
    var doubleTemp: Double? {
        //return Double(tempLabel.text!)
        return Double(textField1.text!)
    }
    
    var doubleInVol: Double? {
        return Double(textField2.text!)
    }
    
    var doubleOutVol: Double? {
        return Double(textField3.text!)
    }
    
    var receiveVol1:Bool = false
    var receiveVol2:Bool = false
    var receiveTemp:Bool = false
    
    func checkUpdateAll(){ // Only update when temperature, in-vol and out-vol are received
        if (receiveVol1 && receiveVol2 && receiveTemp){
            tempLabel.text = String(format:"%.1f", temperature)
            //@@@@@ inVolLabel.text = String(format:"%.1f", inVolume) invol -> invol + outvol
            inVolLabel.text = String(format:"%.1f", inVolume + outVolume)
            outVolLabel.text = String(format:"%.1f", outVolume)
            receiveVol1 = false
            receiveVol2 = false
            receiveTemp = false
            updateChart(axisX: round((Double(second + minute * 60) + milisecondForChart)*100)/100 )
        }
    }
    
    func checkUpdateTemperature() { // for blooming mode, only temperature is shown
        if (receiveTemp){
            tempLabel.text = String(format:"%.1f", temperature)
            receiveTemp = false
        }
    }
    
    @IBOutlet weak var lblConnectionStatus: UILabel!
    
    private let Service_UUID: String = "FFE0"
    private let Characteristic_UUID: String = "FFE1"
   
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var arrayPeripheral: Array<CBPeripheral?> = Array()
    private var characteristic: CBCharacteristic?

    //*********** Finish ***********
    // Parameters to be passed to Result Scene
    var initTemp = 0.0
    var initTempForBlooming = 0.0
    var finalTemp = 0.0
    var totalTime = 0.0
    var timeBaseStartingBrew = 0.0
    var avgTemp = 0.0
    var preInVol = 0.0
    
    var coffeeWeight = 0.0
    var waterInfused = 0.0 // For Storing value of water infused
    var waterInfusedBase = 0.0 // For calculation
    var waterInfusedCounting = false // Boolean for activation
    var stopWaterCount = 0
    var stopWaterCountEnabled:Bool = true // Boolean for activation
    var stopWaterEnableCounter = 0
    
    var numOfPourCount = 0
    var numOfPourCountEnabled:Bool = true // Boolean for activation
    var numOfPourEnableCounter = 0
    
    // var for being passed from other scene
    var useRef = false
    //var refDataStr = ""
    //var lineChtEntryT = [ChartDataEntry]()
    //var lineChtEntryI = [ChartDataEntry]()
    //var lineChtEntryO = [ChartDataEntry]()
    var reflineT = LineChartDataSet()
    var reflineI = LineChartDataSet()
    var reflineO = LineChartDataSet()
    
    @IBOutlet weak var lblStopWater: UILabel!
    
    
    //var waterinfused = 0.0
    var initTempForBrewingStr:String = ""
    var initTempForBloomingStr:String = ""
    var avgTempStr:String = ""
    var finalTempStr:String = ""
    var totalTimeStr:String = ""
    var numberOfPourStr:String = ""
    //var coffeeWeightStr:String = "? ? ?"
    var waterinfusedStr:String = ""
    var coffeeProducedStr:String = ""
    
    
    @IBOutlet weak var btnFinish: UIButton!
    
    @IBAction func finishBtn(_ sender: Any) { // go to next page
    }
    
    //*********** Switch *********** // switching between blooming mode and brewing mode, buy clicking button
    // exact switch is not shown (hidden). Just for implementation
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var stateLabel: UILabel!
    var updateEnabled = false
    
    
    @IBOutlet weak var btnState: UIButton!
    var btnStateBrew = false
    
    @IBAction func btnStateChange(_ sender: Any) {
        if (btnStateBrew == false){
            btnStateBrew = true
            stateSwitch.setOn(true, animated: true)
            btnState.setImage(UIImage(named: "noun_Coffee Brewing_1675782 (1)"), for: .normal)
        }
        else if btnStateBrew == true {
            btnStateBrew = false
            stateSwitch.setOn(false, animated: false)
            btnState.setImage(UIImage(named: "noun_Coffee Brewing_1675782-1"), for: .normal)
        }
        
        switchFunc()
        print("button state change clicked")
        
    }
    
    func switchFunc() {
        timerLabel.textColor = NSUIColor.init(red: 229/255.0, green: 152/255.0, blue: 107/255.0, alpha: 1.0)
        if stateSwitch.isOn {
            stateLabel.text = "Brewing"
            progress = Progress(totalUnitCount: Int64(brewRemind))
            if (timeBaseStartingBrew == 0)
            {
                timeBaseStartingBrew = Double(second + minute * 60)
            }
            updateEnabled = true
            
        } else {
            stateLabel.text = "Blooming"
            progress = Progress(totalUnitCount: Int64(bloomRemind))
            updateEnabled = false
            initializeChart()
        }
    }
    
    @objc func stateChanged(stateSwitch: UISwitch) {
        switchFunc()
    }
    
    //*********** Data *************
    var temperature = 0.0
    var inVolume = 0.0
    var outVolume = 0.0
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var inVolLabel: UILabel!
    
    @IBOutlet weak var outVolLabel: UILabel!
    
    var genFakeInVolCounter = 0 // Count for stop In vol (fake)
    var genFakeInVolForStopping = false
    
    func genFakeTemp(){ // fake value functions for testing
        if temperature < 50 {
            temperature = 95
        }
        temperature = temperature - 0.03
        temperature = round(temperature*100)/100
        
        //avgTemp += temperature
        tempLabel.text = String(format:"%.1f", temperature)
        print("Fake temp generated")
    }
    
    func genFakeInVol(){ // fake value functions for testing
        //preInVol = inVolume
        if genFakeInVolForStopping == false {
            inVolume = inVolume + 0.7
            inVolLabel.text = String(format:"%.2f",inVolume)
            genFakeInVolCounter += 1
            if genFakeInVolCounter >= 140 {
                genFakeInVolForStopping = true
                genFakeInVolCounter = 0
            }
        }
        else if genFakeInVolForStopping == true {
            inVolume = inVolume - 0.4
            inVolLabel.text = String(format:"%.2f",inVolume)
            genFakeInVolCounter += 1
            if genFakeInVolCounter >=  80 {
                genFakeInVolForStopping = false
                genFakeInVolCounter = 0
            }
        }
        
        if (inVolume < preInVol && stopWaterCountEnabled == true) { // when start low line
           // stopWaterCount += 1
            waterInfused += inVolume - waterInfusedBase
            print(String(waterInfused))
            print(String(waterInfusedBase))
            newPour.pourEndingTime = Double(second + minute * 60)
            newPour.pourTotalTime = newPour.pourEndingTime - newPour.pourStartingTime
            newPour.pourInfusedWater = newPour.pourInfusedWater + inVolume - waterInfusedBase
            newPour.pourSpeed = newPour.pourInfusedWater / Double(newPour.pourTotalTime)
            
            let m = (newPour.pourTotalTime/60).rounded(.down)
            let s = newPour.pourTotalTime - m*60
            newPour.pourTimeStr = String("\(Int(m)) min \(Int(s)) sec")
            
            newPour.pourInfusedWaterStr = String("\(round(newPour.pourInfusedWater * 100)/100) mL")
            
             newPour.pourSpeedStr = String("\(round(newPour.pourSpeed * 100)/100) mL/s")
            
            arrayPour.append(newPour)
    
            newPour = detailPour(pourCount: 0, pourStartingTime: 0.0, pourEndingTime: 0.0, pourTotalTime: 0.0, pourInfusedWater: 0.0, pourSpeed: 0.0, pourTimeStr: "", pourInfusedWaterStr: "", pourSpeedStr: "")
            
            stopWaterCount += 1
          //  lblStopWater.text = String(stopWaterCount)
            stopWaterCountEnabled = false
        }
        
        if (inVolume > preInVol && numOfPourCountEnabled == true) { // when start up line
            
            print(numOfPourCount)
            newPour.pourCount = numOfPourCount
            newPour.pourStartingTime = Double(second + minute * 60)
            
            numOfPourCount += 1
            waterInfusedBase = inVolume
            lblStopWater.text = String(numOfPourCount)
            numOfPourCountEnabled = false
        }
        
        
        
    }
    
    func genFakeOutVol(){ /// fake value functions for testing
        outVolume = outVolume + 0.45
        outVolLabel.text = String(format:"%.2f",outVolume)
    }
    
    //*********** Chart ************
    //@IBOutlet weak var chtChart: LineChartView!
    
    @IBOutlet weak var chtChart: LineChartView!
    var lineChtEntryT = [ChartDataEntry]()
    var lineChtEntryI = [ChartDataEntry]()
    var lineChtEntryO = [ChartDataEntry]()
    var lineT = LineChartDataSet()
    var lineI = LineChartDataSet()
    var lineO = LineChartDataSet()
    var data = LineChartData()
    
    var chtDataCount = 0
    var chtSlower = false
    
    func initializeChart(){ // Clean Chart and Setup
        chtChart.clear()
        lineChtEntryT.removeAll()
        lineChtEntryI.removeAll()
        lineChtEntryO.removeAll()
        
    }
   
    // 1 second generate 1 new data -> time equals to X axis
    func updateChart(axisX:Double){
        lineChtEntryT.append(ChartDataEntry(x: Double(axisX), y: temperature))
        //@@@@@ lineChtEntryI.append(ChartDataEntry(x: Double(axisX), y: inVolume))
         lineChtEntryI.append(ChartDataEntry(x: Double(axisX), y: inVolume + outVolume))
        lineChtEntryO.append(ChartDataEntry(x: Double(axisX), y: outVolume))
        // put data into String. For Database replot the graph
        if dataStrTemp == "" {
            dataStrTemp.append(String(Double(axisX)) + "," + String(temperature))
        }
        else {
            dataStrTemp.append(";" + String(Double(axisX)) + "," + String(temperature))
        }
        
        if dataStrInVol == "" {
           //@@@@@ dataStrInVol.append(String(Double(axisX)) + "," + String(inVolume))
            dataStrInVol.append(String(Double(axisX)) + "," + String(inVolume + outVolume))
        }
        else {
            //@@@@@ dataStrInVol.append(";" + String(Double(axisX)) + "," + String(inVolume))
             dataStrInVol.append(";" + String(Double(axisX)) + "," + String(inVolume + outVolume))
        }
        
        if dataStrOutVol == "" {
            dataStrOutVol.append(String(Double(axisX)) + "," + String(outVolume))
        }
        else {
            dataStrOutVol.append(";" + String(Double(axisX)) + "," + String(outVolume))
        }
        
        print(dataStrTemp)
        
        if chtSlower {
           chtDataCount += 1
        }
        
        if (!chtSlower || chtDataCount >= 3) {
            lineT = LineChartDataSet(entries: lineChtEntryT, label: "Temp")
            lineI = LineChartDataSet(entries: lineChtEntryI, label: "InVol")
            lineO = LineChartDataSet(entries: lineChtEntryO, label: "OutVol")
            
            lineT.colors = [NSUIColor.red]
            lineT.circleRadius = 2
            lineT.circleColors = [NSUIColor.red]
            lineI.colors = [NSUIColor.purple]
            lineI.circleRadius = 2
            lineI.circleColors = [NSUIColor.purple]
            lineO.colors = [NSUIColor.blue]
            lineO.circleRadius = 2
            lineO.circleColors = [NSUIColor.blue]
            
            data = LineChartData()
            
            if useRef { // get reference from database. 3 extra lines will be plotted
                data.addDataSet(reflineT)
                data.addDataSet(reflineI)
                data.addDataSet(reflineO)
            }
            
            data.addDataSet(lineT)
            data.addDataSet(lineI)
            data.addDataSet(lineO)
            
            chtChart.gridBackgroundColor = NSUIColor.lightGray
            chtChart.data = data
            chtChart.setVisibleXRangeMinimum(15)
            //chtChart.setVisibleXRangeMaximum(60)
            //chtChart.chartDescription?.text = "My awesome chart"
            chtDataCount = 0
        }
        
    }
    
    //*********** Timer ************
    // now 0.2 tick rate!
    var brewRemind = 600
    var bloomRemind = 150 // 30 to 300 for 0.1 second timer tick rate
    
    @IBOutlet weak var timerProgress: UIProgressView!
    var progress = Progress()
    
    @IBOutlet weak var timerLabel: UILabel!
    var countingTimer: Timer?
    // Declare an Int to keep track of each time Timer fires/ticks.
    var milisecond = 0
    var milisecondForChart:Double = 0.0
    var second = 0
    var secondStr = ""
    var minute = 0
    var minuteStr = ""
    // Declare Double to specify seconds between Timer ticks.
    let tickRate = 0.2
    // Declare Int to specify total timer ticks possible.
    //let totalSecond = 210
    let totalSecond = 600
    var isPaused = false
    var timerStarted = false
    
    func detectRemind() {
        print("detectRemind test")
        if stateSwitch.isOn {
            //if second + minute * 60 > brewRemind {
            if progress.isFinished {
                timerFlickering()
            }
        }
        else {
            if progress.isFinished {
            //if second + minute * 60 > bloomRemind {
             //   print("timer flickering test")
                timerFlickering()
            }
        }
    }
    
    // MARK: - Timer tick handler; called every time timer fires.
    @objc func onTimerTick(timer: Timer) -> Void {
        
        // BOUNDARY: tick for 210 seconds.
        if second + minute * 60 >= totalSecond {
            countingTimer?.invalidate() // Destroy timer.
            //timerLabel.text = "DONE"
        }
            // We haven't hit the boundary, so count the current tick and display.
        else {
            milisecond += 200
            milisecondForChart += 0.2
            if (milisecond >= 1000)
            {
                milisecond -= 1000
                milisecondForChart -= 1
                second += 1
                secondStr = String(format: "%02d", second)
                if second >= 60 {
                    if chtSlower == false {
                        chtSlower = true
                    }
                    second -= 60
                    secondStr = String(format: "%02d", second)
                    minute += 1
                    minuteStr = String(format: "%02d", minute)
                }
                
                if (updateEnabled) {
                    avgTemp += temperature
                }
                
                if (numOfPourCountEnabled == false) { // Condition for activate 5 second
                    numOfPourEnableCounter += 1
                    if (numOfPourEnableCounter >= 5 && inVolume < preInVol)
                    {
                        numOfPourCountEnabled = true
                        numOfPourEnableCounter = 0
                        //waterInfusedBase = inVolume
                    }
                }
                
                if (stopWaterCountEnabled == false) { // Condition for activate 5 second
                    stopWaterEnableCounter += 1
                    if (stopWaterEnableCounter >= 5 && inVolume > preInVol)
                    {
                        stopWaterCountEnabled = true
                        stopWaterEnableCounter = 0
                       // waterInfusedBase = inVolume
                    }
                }
                
                
                
            }
            timerLabel.text = "\(minuteStr) : \(secondStr)"
            self.progress.completedUnitCount += 1
            self.timerProgress.setProgress(Float(self.progress.fractionCompleted), animated: true)
            detectRemind()
            if updateEnabled {  //*************** Code here to switch fake and real
                preInVol = inVolume
                
                //***genFakeTemp()
                // checkUpdateAll() // Use this code for real case!
              /***  if temperature > initTemp // find out initial temperature by comparison
                {
                    initTemp = temperature
                    initTempForBrewingStr = String("\(initTemp) °C")
                }
                genFakeInVol()
                genFakeOutVol()
                ***/
                checkUpdateAll() // Use this code for real case!
                updateChart(axisX: round((Double(second + minute * 60) + milisecondForChart)*100)/100 )
            }
            else { // update not Enable, no Chart (Blooming mode) -> Shows temperature only
               // genFakeTemp()
                  checkUpdateTemperature() // Use this code for real case!
                /*** if temperature > initTempForBlooming // find out initial temperature by comparison
                {
                    initTempForBlooming = temperature
                    initTempForBloomingStr = String("\(initTempForBlooming) °C")
                } */
            }
            //receiveVol1 = false
            //receiveVol2 = false
        }
        
    } // end func onTimerTick
    
    func timerFlickering() {
        timerLabel.textColor = NSUIColor.init(red: 229/255.0, green: 152/255.0, blue: 107/255.0, alpha: 1.0)
        if second % 2 == 1 {
            timerLabel.textColor = NSUIColor.red
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        else {
            timerLabel.textColor = NSUIColor.init(red: 229/255.0, green: 152/255.0, blue: 107/255.0, alpha: 1.0)
        }
    }
    
    @IBAction func startbutton(_ sender: Any) {
        // Create and configure the timer for 1.0 second ticks.
        if !timerStarted {
            stateSwitch.isEnabled = false
            btnState.isEnabled = false
            countingTimer = Timer.scheduledTimer(timeInterval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: nil, repeats: true)
            // Make the timer efficient.
            countingTimer?.tolerance = 0.15
            // Helps UI stay responsive even with timer.
            RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
            timerStarted = true
        }
    }
    
    @IBAction func pausebutton(_ sender: Any) {
        if !isPaused {
            stateSwitch.isEnabled = true
            btnState.isEnabled = true
            countingTimer?.invalidate()
            isPaused = true
            
            if stateSwitch.isOn {
                
                if stopWaterCountEnabled == true { // Still up line, waiting for down line, and paused
                    waterInfused += inVolume - waterInfusedBase
                   // newPour.pourInfusedWater = newPour.pourInfusedWater + inVolume - waterInfusedBase
                    
                    newPour.pourEndingTime = Double(second + minute * 60)
                    newPour.pourTotalTime = newPour.pourEndingTime - newPour.pourStartingTime
                    newPour.pourInfusedWater = newPour.pourInfusedWater + inVolume - waterInfusedBase
                    newPour.pourSpeed = newPour.pourInfusedWater / Double(newPour.pourTotalTime)
                    
                    let m = (newPour.pourTotalTime/60).rounded(.down)
                    let s = newPour.pourTotalTime - m*60
                    newPour.pourTimeStr = String("\(Int(m)) min \(Int(s)) sec")
                    
                    newPour.pourInfusedWaterStr = String("\(round(newPour.pourInfusedWater * 100)/100) mL")
                    newPour.pourSpeedStr = String("\(round(newPour.pourSpeed * 100)/100) mL/s")
                    arrayPour.append(newPour)
                    
                    print(String(waterInfused))
                    print(String(waterInfusedBase))
                    waterInfusedBase = inVolume
                    print(waterInfusedBase)
                   
                }
                
                btnFinish.isEnabled = true
            
                totalTime = Double(second + minute * 60) - timeBaseStartingBrew
                let m = (totalTime/60).rounded(.down)
                let s = totalTime - m*60
                totalTimeStr = String("\(Int(m)) min \(Int(s)) sec")
                finalTemp = temperature
                finalTempStr = String("\(round(temperature * 100)/100) °C") // round reduce decimal places
                let avgS = Double(avgTemp/totalTime)
                avgTempStr =  String("\(round(avgS * 100)/100)°C")
                waterinfusedStr = String("\(round(waterInfused * 100)/100) mL")
                coffeeProducedStr = String("\(round(outVolume * 100)/100) mL")
                numberOfPourStr = String("\(numOfPourCount) times")
                
                for eachPour in arrayPour {
                    print(eachPour.pourCount)
                    print(eachPour.pourTimeStr)
                    print(eachPour.pourInfusedWaterStr)
                    print(eachPour.pourSpeedStr)
                }
                
                /*
                print(totalTimeStr)
                print(initTempForBloomingStr)
                print(initTempForBrewingStr)
                print(finalTempStr)
                print(avgTempStr)
                print(waterinfusedStr)
                print(coffeeProducedStr)
                print(numberOfPourStr)
                */
            }
            //avgTemp = (finalTemp - initTemp) / totalTime
        }
        else {
            isPaused = false
            if numOfPourCount != 0 {
                arrayPour.remove(at: newPour.pourCount)
            }
            btnState.isEnabled = false
            stateSwitch.isEnabled = false
            btnFinish.isEnabled = false
            if second + minute * 60 > bloomRemind {
                stateSwitch.setOn(true, animated:true)
                switchFunc()
            //    stateChanged(stateSwitch: <#T##UISwitch#>)
            }
            // Set up timer again
            countingTimer = Timer.scheduledTimer(timeInterval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: nil, repeats: true)
            countingTimer?.tolerance = 0.15
            RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
        }
    }
    
    @IBAction func resetbutton(_ sender: Any) {
        
        countingTimer?.invalidate()
        stopWaterCount = 0
        stopWaterCountEnabled = true
        stopWaterEnableCounter = 0
        numOfPourCount = 0
        numOfPourCountEnabled = true
        numOfPourEnableCounter = 0
        second = 0
        secondStr = String(format: "%02d", second)
        minute = 0
        minuteStr = String(format: "%02d", minute)
        timerLabel.text = "\(minuteStr) : \(secondStr)"
        timerProgress.progress = 0.0
        progress.completedUnitCount = 0
        isPaused = false
        timerStarted = false
        temperature = 0.0
        inVolume = 0.0
        outVolume = 0.0
        
        waterInfusedBase = 0.0
        waterInfused = 0.0
        genFakeInVolForStopping = false
        genFakeInVolCounter = 0
        
        btnFinish.isEnabled = false
        
        tempLabel.text = String(format:"%.1f", temperature)
        //@@@@@@ inVolLabel.text = String(format:"%.1f", inVolume)
        inVolLabel.text = String(format:"%.1f", inVolume + outVolume)
        outVolLabel.text = String(format:"%.1f", outVolume)
        initializeChart()
        chtDataCount = 0
        updateEnabled = false
        stateLabel.text = "Blooming"
        stateSwitch.setOn(false, animated:true)
        switchFunc()
        //stateSwitch.
        stateSwitch.isEnabled = true
        btnState.isEnabled = true
        btnStateBrew = false
    }
    
    //**********************************
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayPour = [detailPour]()
        ////water Stop
        lblStopWater.text = String(stopWaterCount)
        
        //// BLE
        textField1.isHidden = true
        textField2.isHidden = true
        textField3.isHidden = true
        textField4.isHidden = true
        
        //// Save button
        btnFinish.isEnabled = false
        
        
        //*********** Timer ************
        timerProgress.progress = 0.0
        progress.completedUnitCount = 0
        secondStr = String(format: "%02d", second)
        minuteStr = String(format: "%02d", minute)
        timerLabel.text = "\(minuteStr) : \(secondStr)"
        //*********** Data **************
        tempLabel.text = String(format:"%.1f", temperature)
        //@@@@@ inVolLabel.text = String(format:"%.1f", inVolume)
        inVolLabel.text = String(format:"%.1f", inVolume + outVolume)
        outVolLabel.text = String(format:"%.1f", outVolume)
        //*********** Chart *************
        initializeChart()
        //*********** Switch ************
        stateSwitch.isHidden = true
        stateSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        stateSwitch.setOn(false, animated:true)
        switchFunc()
        //stateChanged(stateSwitch: <#T##UISwitch#>)
        stateSwitch.isEnabled = true
        btnState.isEnabled = true
        //btnStateChange(<#T##sender: Any##Any#>)
        // ************* BLE ***************
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //*********** Timer ************
        countingTimer?.invalidate()
        isPaused = true
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // pass data to next page
        guard let resultViewController = segue.destination as? ResultViewController
            else {
                return
        }
        // pour detail, pass to next scene for calculation detail
        resultViewController.arrayPourPassed = arrayPour
        
        // chart details, pass to next scene
        resultViewController.dataStrTempPassed = dataStrTemp
        resultViewController.dataStrInVolPassed = dataStrInVol
        resultViewController.dataStrOutVolPassed = dataStrOutVol
        
        // report details, pass to next scene
        resultViewController.totalTimePassed = totalTimeStr
        resultViewController.initBloomTempPassed = initTempForBloomingStr
        resultViewController.initBrewTempPassed = initTempForBrewingStr
        resultViewController.finalBrewTempPassed = finalTempStr
        resultViewController.avgTempPassed = avgTempStr
        resultViewController.totalWaterInfusedPassed = waterinfusedStr
        resultViewController.coffeeProducedPassed = coffeeProducedStr
        resultViewController.numOfPourPassed = numberOfPourStr
    }
}

// BLE implementation, from online source

extension PourOverViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用")
            central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
        }
    }
    
    /** 发现符合要求的外设 */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        // 根据外设名称来过滤
    
        if (peripheral.name?.hasPrefix("Coffe"))! {
            arrayPeripheral.append(peripheral)
        }
        if (arrayPeripheral.count > 1) {
            for peripheral in arrayPeripheral{
                central.connect(peripheral!, options: nil)
                print("connected")
            }
        }
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
        lblConnectionStatus.text = String("Connected")
        lblConnectionStatus.textColor = NSUIColor.green
        imageBLE.image = UIImage(named: "noun_Bluetooth_2718360 (1).png")
        print("连接成功")
       // sendMsg()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("断开连接")
        // 重新连接
        lblConnectionStatus.text = String("Disconnected")
        imageBLE.image = UIImage(named: "noun_Bluetooth_2718360-1.png")
        lblConnectionStatus.textColor = NSUIColor.init(red: 229/255.0, green: 152/255.0, blue: 107/255.0, alpha: 1.0)
        central.connect(peripheral, options: nil)
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service: CBService in peripheral.services! {
            print("外设中的服务有：\(service)")
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        // 根据UUID寻找服务中的特征
        peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
        }
        
        self.characteristic = service.characteristics?.last
        // 读取特征里的数据
        peripheral.readValue(for: self.characteristic!)
        // 订阅
        peripheral.setNotifyValue(true, for: self.characteristic!)
    }
    
    /** 订阅状态 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("订阅失败: \(error)")
            return
        }
        if characteristic.isNotifying {
            print("订阅成功")
            for peripheral in arrayPeripheral{
                peripheral?.writeValue((self.lblConnectionStatus.text?.data(using: .utf8)!)!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
            }
        } else {
            print("取消订阅")
        }
    }
    
    /** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (peripheral.name?.hasSuffix("2"))! { // temp
            let data = characteristic.value
            print("msg from coffee temp: ",(String.init(data: data!, encoding: String.Encoding.utf8)) ?? "")
            self.textField1.text = String.init(data: data!, encoding: String.Encoding.utf8)
            if let doubleTemp = self.doubleTemp {
                temperature = doubleTemp
                print(temperature)
                receiveTemp = true
                //avgTemp += temperature
               /* if temperature > initTemp // find out initial temperature by comparison
                {
                    initTemp = temperature
                    initTempForBrewingStr = String("\(initTemp) °C")
                } */
            }
        }
        else if (peripheral.name?.hasSuffix("3"))! { // volume
                
                let data = characteristic.value
                //var count = 0
                print("msg from coffee volume: ",(String.init(data: data!, encoding: String.Encoding.utf8)) ?? "nth")
                self.textField4.text = String.init(data: data!, encoding: String.Encoding.utf8)
                if (textField4.text == "")
                {
                    textField4.text = "nth"
            }
                let startChar: Character = textField4.text![textField4.text!.startIndex]
                print(startChar)
                let receiveVolStr = textField4.text![textField4.text!.index(after:textField4.text!.startIndex)..<textField4.text!.endIndex]
                
                // if (receiveVol1 == false && receiveVol2 == false) {
                if (startChar == "I") {
                    self.textField2.text = String(receiveVolStr)
                    //self.textField2.text = String.init(data: data!, encoding: String.Encoding.utf8)
                    if let doubleInVol = self.doubleInVol {
                        //preInVol = inVolume
                        inVolume = doubleInVol
                        print(inVolume)
                        
                        if (inVolume < preInVol && stopWaterCountEnabled == true) {
                           // stopWaterCount += 1
                            waterInfused += inVolume - waterInfusedBase
                            print(String(waterInfused))
                           // lblStopWater.text = String(stopWaterCount)
                            newPour.pourEndingTime = Double(second + minute * 60)
                            newPour.pourTotalTime = newPour.pourEndingTime - newPour.pourStartingTime
                            newPour.pourInfusedWater = newPour.pourInfusedWater + inVolume - waterInfusedBase
                            newPour.pourSpeed = newPour.pourInfusedWater / Double(newPour.pourTotalTime)
                            
                            let m = (newPour.pourTotalTime/60).rounded(.down)
                            let s = newPour.pourTotalTime - m*60
                            newPour.pourTimeStr = String("\(Int(m)) min \(Int(s)) sec")
                            
                            newPour.pourInfusedWaterStr = String("\(round(newPour.pourInfusedWater * 100)/100) mL")
                            
                            newPour.pourSpeedStr = String("\(round(newPour.pourSpeed * 100)/100) mL/s")
                            
                            arrayPour.append(newPour)
                            
                            newPour = detailPour(pourCount: 0, pourStartingTime: 0.0, pourEndingTime: 0.0, pourTotalTime: 0.0, pourInfusedWater: 0.0, pourSpeed: 0.0, pourTimeStr: "", pourInfusedWaterStr: "", pourSpeedStr: "")
                            
                            stopWaterCount += 1
                            
                            stopWaterCountEnabled = false
                        }
                        if (inVolume > preInVol && numOfPourCountEnabled == true) {
                           
                            waterInfusedBase = inVolume
                            newPour.pourCount = numOfPourCount
                            newPour.pourStartingTime = Double(second + minute * 60)
                            
                            numOfPourCount += 1
                            // waterInfused += preInVol - waterInfusedBase
                             lblStopWater.text = String(numOfPourCount)
                            numOfPourCountEnabled = false
                        }
                        
                        receiveVol1 = true
                        //    count += 1
                    }
                }
                //else if (receiveVol1 == true && receiveVol2 == false) {
                if (startChar == "O") {
                    self.textField3.text = String(receiveVolStr)
                    if let doubleOutVol = self.doubleOutVol {
                        outVolume = doubleOutVol
                        print(outVolume)
                        receiveVol2 = true
                        //  count += 1
                    }
                }
        }
    }
    
    /** 写入数据 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("写入数据")
    }
}


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    //}



