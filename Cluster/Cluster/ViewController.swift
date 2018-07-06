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

    @IBOutlet weak var mkMapView: ClusterMapView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 10000
    let locationManager = CLLocationManager()
    let annotation = MKAnnotationView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        mkMapView.delegate = self
        
        let center = CLLocationCoordinate2D(latitude: 12.971, longitude: 77.59)
        let delta = 1.1
        
        let annotations: [Annotation] = (0..<100).map { _ in
            let annotation = Annotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: center.latitude + drand48() * delta - delta / 2, longitude: center.longitude + drand48() * delta - delta / 2)
            let color = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
            annotation.style = .simple(color: color, radius: 25)
            // or
            // annotation.style = .image(UIImage(named: "pin")?.filled(with: color)) // custom image
            return annotation
        }
        
        
//        mkMapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
        
        mkMapView.add(annotations: annotations)
        mkMapView.setRegion(MKCoordinateRegionMakeWithDistance(center,
                                                               regionRadius, regionRadius), animated: true)
        
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Map view annotation count \(mapView.annotations.count)")
        mkMapView.reload()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? ClusterAnnotationView {
                view.annotation = annotation
            } else {
                view = ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        } else {
            guard let annotation = annotation as? Annotation else { return nil }
            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if let view = view {
                view.annotation = annotation
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            view?.pinTintColor = .green
            return view
        }
        
    }
}
