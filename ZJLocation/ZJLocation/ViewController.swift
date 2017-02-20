//
//  ViewController.swift
//  ZJLocation
//
//  Created by ZeroJianMBP on 16/4/20.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var mapView: MKMapView!
//  var zjLocation = ZJLocation()
  

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        return renderer
    }

    
  func startUpdating() {
    ZJLocationService.sharedManager.didUpdateLocation = { [weak self] locations in
        let latitude = locations.last?.coordinate.latitude
        let longitude = locations.last?.coordinate.longitude
        self?.label.text = "Location: \(latitude!)  \(longitude!)"
        for location in locations {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
            var coords = [CLLocationCoordinate2D]()
            coords.append(location.coordinate)
            self?.mapView.setRegion(region, animated: true)
            self?.mapView.add(MKPolyline(coordinates: &coords, count: coords.count))
            ZJLocationService.sharedManager.locations.append(location)
            ZJLocationService.sharedManager.sendLocationsToServer(location: location)
        }
    }
  }

  @IBAction func stop(_ sender: Any) {
    ZJLocationService.stopLocation()
  }
    
  @IBAction func start(_ sender: Any) {
    ZJLocationService.startLocation()
    startUpdating()
    ZJLocationService.time = 120
  }
    
}

