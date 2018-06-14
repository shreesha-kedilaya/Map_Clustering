//
//  ViewController.swift
//  Cluster
//
//  Created by Shreesha on 13/06/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mkMapView: MKMapView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    let locationManager = CLLocationManager()
    let annotation = MKAnnotationView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        mkMapView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func checkLocationAuthorizationStatus() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mkMapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mkMapView.setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mkMapView.setRegion(mkMapView.regionThatFits(region), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
    }
    
    
}
