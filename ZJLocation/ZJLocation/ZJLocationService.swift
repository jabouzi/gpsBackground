//
//  LocationService.swift
//  ZJBatterySaveLocation
//
//  Created by ZeroJianMBP on 16/4/19.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

class ZJLocationService: NSObject,CLLocationManagerDelegate {
  
  static let sharedManager = ZJLocationService()

  
  private var backgroundTask = BackgroundTask()
  private var timeInterval: Double = 179
  private var timer: Timer?
  
  class var time: TimeInterval! {
    get {
      return self.sharedManager.timeInterval
    }
    set(second) {
      if second > 0 && second < 180 {
        self.sharedManager.timeInterval = second
      }
    }
  }
  
  private var backgroundLocations = [CLLocation]() {
    didSet{
      if backgroundLocations.count == 10 {
        begionBackgroundTask(time: self.timeInterval)
      }
    }
  }
  
  var didUpdateLocation: ((CLLocation) -> Void)?
  
  class func startLocation() {
    if (CLLocationManager.locationServicesEnabled()) {
      self.sharedManager.locationManager.startUpdatingLocation()
      print("begin updating location")
    }
  }
  
  class func stopLocation() {
    self.sharedManager.locationManager.stopUpdatingLocation()
    print("did stop location")
  }
  
  lazy var locationManager: CLLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.distanceFilter = kCLDistanceFilterNone
    if #available(iOS 9.0, *) {
      locationManager.allowsBackgroundLocationUpdates = true
    }
    if #available(iOS 8.0, *) {
    locationManager.requestAlwaysAuthorization()
    }
    return locationManager
  }()
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations)
    guard let newLocation = locations.last else { return }
    
    didUpdateLocation?(newLocation)
    
    if UIApplication.shared.applicationState != .active {
      print("background location : \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
      backgroundLocations.append(newLocation)
    } else {
      print("active status location:  \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
      
      initialBackgroundTask()
      
      if backgroundLocations.count > 0 {
        backgroundLocations.removeAll()
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)  {
    print(status)
    switch status {
    case .denied:
      showAlert()
      print("AuthorizationStatus -- Denied")
    default:
      break
    }
  }
  
  private func showAlert() {
    if #available(iOS 8.0, *) {
      let alertController = UIAlertController(title: "Confirm", message: "This App does not have access to Location Services,Please enable in Settings", preferredStyle: .alert)
      let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
      alertController.addAction(action)
      
     currentViewController()?.present(alertController, animated: true, completion: nil)

    } else {
      
      let alertView = UIAlertView(title: "Confirm", message: "This App does not have access to Location Services,Please enable in Settings", delegate: nil, cancelButtonTitle: "OK")
      alertView.show()
    }
    

  }
  
  func currentViewController() -> UIViewController? {
    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
      return nil
    }
    if let presentedViewController = rootViewController.presentedViewController{
      return presentedViewController
    }else{
      return rootViewController
    }
  }
  
//  func applicationStatues() -> UIApplicationState {
//    return UIApplication.sharedApplication().applicationState
//  }
  
  var lastBackgroundLocation: ((CLLocation) -> Void)?
  
  private func begionBackgroundTask(time: TimeInterval){
    initialBackgroundTask()
    
    lastBackgroundLocation?(backgroundLocations.last!)
    backgroundLocations.removeAll()
    
    //    self.performSelector(#selector(againStartLocation), withObject: nil, afterDelay: time)
    timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(againStartLocation), userInfo: nil, repeats: false)
    
    backgroundTask.registerBackgroundTask()
    
    print(" stop location :\(time) seconds")
  }
  
  private func initialBackgroundTask() {
    if backgroundTask.tasking {
      backgroundTask.endBackgroundTask()
    }
    if let timer = timer {
      timer.invalidate()
    }
  }
  
  func againStartLocation(){
    
    ZJLocationService.startLocation()
  }

  
}
