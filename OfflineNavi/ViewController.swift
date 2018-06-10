//
//  ViewController.swift
//  OfflineNavi
//
//  Created by snishimura on 2018/06/06.
//  Copyright © 2018年 snishimura. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {
    
    private var mapView: GMSMapView!
    private var placesClient: GMSPlacesClient!

    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    private let accuracy = kCLLocationAccuracyHundredMeters * 3 // 300m
    private let filterDistance = 100.0
    private let zoomLevel: Float = 15.0
    
    override func loadView() {
        mapView = createMap()
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placesClient = GMSPlacesClient.shared()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = filterDistance
        locationManager.startUpdatingLocation()
    }
    
    func createMap() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        let mv = GMSMapView.map(withFrame: .zero, camera: camera)
        mv.delegate = self
        mv.settings.myLocationButton = true
        mv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mv.isMyLocationEnabled = true
        mv.isHidden = true
        return mv
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
