//
//  Extensions.swift
//  Cluster
//
//  Created by Shreesha on 06/07/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import MapKit

let CLLocationCoordinate2DMax = CLLocationCoordinate2D(latitude: 90, longitude: 180)
let MKMapPointMax = MKMapPointForCoordinate(CLLocationCoordinate2DMax)

extension Array where Element: MKAnnotation {
    func subtracted(_ other: [Element]) -> [Element] {
        return filter { item in !other.contains { $0.isEqual(item) } }
    }
    mutating func subtract(_ other: [Element]) {
        self = self.subtracted(other)
    }
    mutating func add(_ other: [Element]) {
        self.append(contentsOf: other)
    }
    @discardableResult
    mutating func remove(_ item: Element) -> Element? {
        return index { $0.isEqual(item) }.map { remove(at: $0) }
    }
}

extension Double {
    var cellSize: Double {
        switch self {
        case 13...15:
            return 64
        case 16...18:
            return 32
        case 19...:
            return 16
        default: // Less than 13
            return 88
        }
    }
}
