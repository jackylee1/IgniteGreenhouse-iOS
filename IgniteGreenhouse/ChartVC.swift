//
//  ChartVC.swift
//  IgniteGreenhouse
//
//  Created by Doruk Gezici on 27.11.2017.
//  Copyright © 2017 ARDIC. All rights reserved.
//

import UIKit
import Charts
import IgniteAPI

class ChartVC: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    weak var rootVC: SensorsVC!
    var sensor: IGSensor!
    var lastData: IGSensorData!
    var set_a: LineChartDataSet!
    var i = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.delegate = self
        closeButton.layer.cornerRadius = 40
        homeButton.layer.cornerRadius = 40
        bgView.layer.cornerRadius = 15
        
        lineChartView.noDataText = "Sensor doesn't have live data."
        lineChartView.tintColor = UIColor.flatWhite
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.labelTextColor = UIColor.flatWhite
        lineChartView.chartDescription?.textColor = UIColor.flatWhite
        lineChartView.chartDescription?.text = "Live Data"
        lineChartView.autoScaleMinMaxEnabled = false
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.addData()
        }
    }
    
    func configureView(sensor: IGSensor, lastData: [IGSensorData]) {
        self.sensor = sensor
        lineChartView.chartDescription?.text = "Live Data: \(sensor.sensorId!)"
        var entries = [ChartDataEntry]()
        for last in lastData {
            entries.append(ChartDataEntry(x: 0.0, y: Double(last.data)!))
        }
        set_a = LineChartDataSet(values: entries, label: sensor.sensorType)
        set_a.setColor(UIColor.flatWhite)
        set_a.valueTextColor = UIColor.flatWhite
        let data = LineChartData(dataSet: set_a)
        lineChartView.data = data
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        rootVC.changeVC(withIdentifier: "HomeVC")
    }
    
    @objc func addData() {
        guard let device = IgniteAPI.currentDevice, let node = IgniteAPI.currrentNode else { return }
        if node.nodeId != MAIN_NODE { return }
        IgniteAPI.getSensorData(deviceId: device.deviceId, nodeId: node.nodeId, sensorId: sensor.sensorId) { (sensorData) in
            guard let data = Double(sensorData.data) else { return }
            let entry = ChartDataEntry(x: Double(self.i), y: data)
            self.lineChartView.lineData?.addEntry(entry, dataSetIndex: 0)
            self.lineChartView.centerViewToAnimated(xValue: Double(self.i), yValue: data, axis: YAxis.AxisDependency.left, duration: 1)
            self.lineChartView.setVisibleXRange(minXRange: 0.0, maxXRange: 2.0)
            self.lineChartView.notifyDataSetChanged()
            self.i = self.i + 1
        }
    }

}
