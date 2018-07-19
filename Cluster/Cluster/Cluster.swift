//
//  Cluster.swift
//  Cluster
//
//  Created by Shreesha on 05/07/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import MapKit

class Cluster {
    
    private var tree = MapQuadTree(rect: MKMapRectWorld)
    var gridSize: Double = 88
    var displayedAnnotations = [MKAnnotation]()
    
    func add(_ annotation: MKAnnotation) {
        // TODO: Add error cases.
        _ = tree.add(annotation: annotation)
    }
    
    func add(_ annotations: [MKAnnotation]) {
        for annotation in annotations {
            // TODO: Add error cases.
            _ = tree.add(annotation: annotation)
        }
    }
    
    var allAnnotations: [MKAnnotation] {
        return tree.annotations(in: MKMapRectWorld)
    }
    
    func reload(mapView: MKMapView, completion: (_ annotationsToAdd: [MKAnnotation], _ annotationsToRemove: [MKAnnotation]) -> Void) {
        let mapBounds = mapView.bounds
        let visibleMapRect = mapView.visibleMapRect
        let visibleMapRectWidth = visibleMapRect.size.width
        let zoomScale = Double(mapBounds.width) / visibleMapRectWidth
        
        let (toAdd, toRemove) = clusteredAnnotations(scale: zoomScale, visibleRect: visibleMapRect)
        
        completion(toAdd, toRemove)
    }
    
    func clusteredAnnotations(scale: Double, visibleRect: MKMapRect) -> (annotationsToAdd: [MKAnnotation], annotationsToRemove: [MKAnnotation]) {
        
        // Dividing is necessary because we have to divide the entire screen width by gridSize to get the right intervals for 'for loop'
        let scaleFactor = scale / scale.cellSize
        let minX = Int(floor(visibleRect.minX * scaleFactor))
        let maxX = Int(floor(visibleRect.maxX * scaleFactor))
        let minY = Int(floor(visibleRect.minY * scaleFactor))
        let maxY = Int(floor(visibleRect.maxY * scaleFactor))
        
        var allAnnotations = [MKAnnotation]()
        for x in minX...maxX {
            for y in minY...maxY {
                var mapRect = MKMapRect(x: Double(x) / scaleFactor, y: Double(y) / scaleFactor, width: 1 / scaleFactor, height: 1 / scaleFactor)
                
                if mapRect.origin.x > MKMapPointMax.x {
                    mapRect.origin.x -= MKMapPointMax.x
                }
                
                var annotations = [MKAnnotation]()
                var totalLatitude: Double = 0
                var totalLongitude: Double = 0
                
                for annotation in tree.annotations(in: mapRect) {
                    totalLatitude += annotation.coordinate.latitude
                    totalLongitude += annotation.coordinate.longitude
                    annotations.append(annotation)
                }
                
                let count = annotations.count
                if count >= 2 {
                    let cluster = ClusterAnnotation()
                    cluster.coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(totalLatitude) / CLLocationDegrees(count),
                        longitude: CLLocationDegrees(totalLongitude) / CLLocationDegrees(count)
                    )
                    
                    cluster.members = annotations
                    allAnnotations += [cluster]
                } else {
                    allAnnotations += annotations
                }
            }
        }
        
        let before = displayedAnnotations
        let after = allAnnotations
        
        var toRemove = before.subtracted(after)
        let toAdd = after.subtracted(before)
        
        print(toAdd)
        
        let nonRemoving = toRemove.filter { !visibleRect.contains($0.coordinate) }
        toRemove.subtract(nonRemoving)
        
        displayedAnnotations.subtract(toRemove)
        displayedAnnotations.add(toAdd)
        
        return (toAdd, toRemove)
    }
}
