//
//  HomeVC.swift
//  IgniteGreenhouse
//
//  Created by Doruk Gezici on 18/07/2017.
//  Copyright © 2017 ARDIC. All rights reserved.
//

import UIKit
import IgniteAPI
import NVActivityIndicatorView

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var sensorData = [IGSensorData]()
    var startDate: TimeInterval?
    var endDate: TimeInterval?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeVC.refreshData(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        collectionView.addSubview(refreshControl)
        IgniteAPI.refreshToken { (user) in
            IgniteAPI.currentUser = user
            self.refreshData(self.refreshControl)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            refreshData(self.refreshControl)
        } else {
            print("Portrait")
        }
    }
    
    func registerNibs() {
        let nib = UINib(nibName: "GraphCell", bundle: nil)
        let nib2 = UINib(nibName: "TableCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "graphCell")
        collectionView.register(nib2, forCellWithReuseIdentifier: "tableCell")
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) { }
    
    @IBAction func optionsPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toOptions", sender: nil)
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        viewDeckController?.open(.left, animated: true)
    }
    
    @objc func refreshData(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        if let device = IgniteAPI.currentDevice, let node = IgniteAPI.currrentNode, let sensor = IgniteAPI.currentSensor {
            //refreshControl.beginRefreshing()
            startAnimating(message: "Loading...", type: NVActivityIndicatorType.ballTrianglePath)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.stopAnimating()
                if self.sensorData.count == 0 {
                    let label = UILabel(frame: self.collectionView.frame)
                    label.text = "Select Devices from menu (top left corner)."
                    label.textAlignment = .center
                    self.collectionView.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor).isActive = true
                    label.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor).isActive = true
                }
            }
            IgniteAPI.getSensorDataHistory(deviceId: device.deviceId, nodeId: node.nodeId, sensorId: sensor.sensorId, startDate: startDate, endDate: endDate, pageSize: 10) { (sensorData) in
                self.sensorData = sensorData
                self.collectionView.reloadData()
                self.stopAnimating()
                //refreshControl.endRefreshing()
            }
        } else {
            print("Select Device, Node and Sensor first!.")
            self.startAnimating(message: "Select/Add Device first")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.stopAnimating()
                //refreshControl.endRefreshing()
                self.performSegue(withIdentifier: "toDevices", sender: nil)
            }
        }
    }
    
    // MARK: - Collection View Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sensorData.count == 0 { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as! GraphCell
            cell.isHidden = true
            cell.configureCell(title: IgniteAPI.currentSensor?.sensorId, sensorData: sensorData)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tableCell", for: indexPath) as! TableCell
            cell.isHidden = true
            cell.configureCell(sensorData: sensorData)
            return cell
        default:
            break
        }; return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 220)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: 340)
        default:
            return collectionViewLayout.collectionViewContentSize
        }
    }
    
}
