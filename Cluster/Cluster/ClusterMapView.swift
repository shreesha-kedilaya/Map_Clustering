//
//  ClusterMapView.swift
//  Cluster
//
//  Created by Shreesha on 05/07/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import MapKit

class ClusterMapView: MKMapView {
    var cluster: Cluster = Cluster()
    
    func reload() {
        cluster.reload(mapView: self) { toAdd, toRemove in
            removeAnnotations(toRemove)
            addAnnotations(toAdd)
        }
    }
    
    func add(annotation: MKAnnotation) {
        cluster.add(annotation)
    }
    
    func add(annotations: [MKAnnotation]) {
        cluster.add(annotations)
    }
}
