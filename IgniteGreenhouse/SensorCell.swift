//
//  SensorCell.swift
//  IgniteGreenhouse
//
//  Created by Doruk Gezici on 1.11.2017.
//  Copyright © 2017 ARDIC. All rights reserved.
//

import UIKit
import IgniteAPI
import NVActivityIndicatorView

class SensorCell: UICollectionViewCell {

    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var windowView: UIView!
    var sensor: IGSensor!
    var vc: SensorsVC!
    
    func configureCell(sensor: IGSensor, vc: SensorsVC) {
        vc.startAnimating(message: "Loading...", type: NVActivityIndicatorType.ballTrianglePath)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            vc.stopAnimating()
        }
        dataLabel.text = ""
        dateLabel.text = ""
        clipsToBounds = false
        layer.cornerRadius = 6
        let maskPath = UIBezierPath(roundedRect: windowView.bounds, byRoundingCorners: UIRectCorner.topLeft.union(.topRight), cornerRadii: CGSize(width: 6, height: 6))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path  = maskPath.cgPath
        windowView.layer.mask = maskLayer
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3
        windowView.layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 1, height: 1)
        self.sensor = sensor
        self.vc = vc
        nodeLabel.text = sensor.nodeId
        nameLabel.text = sensor.sensorId
        switch sensor.sensorType {
        case "GHT-Temperature":
            deviceImage.image = UIImage(named: "thermometer")
        case "GHT-Humidity":
            deviceImage.image = UIImage(named: "humidity")
        default:
            break
        }
        IgniteAPI.getSensorData(deviceId: IgniteAPI.currentDevice!.deviceId, nodeId: MAIN_NODE, sensorId: sensor.sensorId) { (data) in
            vc.stopAnimating()
            self.dataLabel.text = data.data
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let date = Date(timeIntervalSince1970: TimeInterval(data.cloudDate))
            if abs(date.timeIntervalSinceNow) < 300 { // Less than 5 minutes
                self.statusImage.image = UIImage(named: "online")
            } else {
                self.statusImage.image = UIImage(named: "offline")
            }
            self.dateLabel.text = dateFormatter.string(from: date)
            switch sensor.sensorType {
            case "GHT-Temperature":
                self.dataLabel.text! += " °C"
            case "GHT-Humidity":
                self.dataLabel.text! += " %"
            default:
                break
            }
        }
    }
    
    @IBAction func infoPressed(sender: UIButton) {
        vc.selectedSensor = sensor
        let maskView = UIView(frame: vc.view.frame)
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        vc.view.addSubview(maskView)
        vc.performSegue(withIdentifier: "toSensor", sender: maskView)
    }

}
