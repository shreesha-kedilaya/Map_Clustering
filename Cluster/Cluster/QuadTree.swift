//
//  QuadTree.swift
//  Cluster
//
//  Created by Shreesha on 21/06/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

let maxNumberOfPoints = 4

protocol QuadTreeAcceptance {
    func add(annotation: MKAnnotation) -> Bool
    func annotations(in rect: MKMapRect) -> [MKAnnotation]
    func remove(_ annotation: MKAnnotation) -> Bool
}

class QuadTree: QuadTreeAcceptance {
    let root: QuadTreeNode
    
    init(rect: MKMapRect) {
        root = QuadTreeNode(rect: rect)
    }
    
    func add(annotation: MKAnnotation) -> Bool {
        return root.add(annotation: annotation)
    }
    
    func remove(_ annotation: MKAnnotation) -> Bool {
        return root.remove(annotation)
    }
    
    func annotations(in rect: MKMapRect) -> [MKAnnotation] {
        return root.annotations(in: rect)
    }
}

class QuadTreeNode {
    enum TreeType {
        case leaf
        case `internal`(children: Children)
    }
    
    struct Children: Sequence {
        var topLeftNode: QuadTreeNode?
        var topRightNode: QuadTreeNode?
        var bottomLeftNode: QuadTreeNode?
        var bottomRightNode: QuadTreeNode?
        
        init(parentNode: QuadTreeNode) {
            let mapRect = parentNode.positionRect
            topLeftNode = QuadTreeNode(rect: mapRect.topLeftRect)
            topRightNode = QuadTreeNode(rect: mapRect.topRightRect)
            bottomLeftNode = QuadTreeNode(rect: mapRect.bottomLeftRect)
            bottomRightNode = QuadTreeNode(rect: mapRect.bottomRightRect)
        }
        
        struct ChildrenIterator: IteratorProtocol {
            private var index = 0
            private let children: Children
            
            init(children: Children) {
                self.children = children
            }
            
            mutating func next() -> QuadTreeNode? {
                defer { index += 1 }
                switch index {
                case 0: return children.topLeftNode
                case 1: return children.topRightNode
                case 2: return children.bottomLeftNode
                case 3: return children.bottomRightNode
                default: return nil
                }
            }
        }
        
        public func makeIterator() -> ChildrenIterator {
            return ChildrenIterator(children: self)
        }
    }
    
    var positionRect: MKMapRect
    var pointLimit = maxNumberOfPoints
    var points: [MKAnnotation] = []
    
    var type: TreeType = .leaf
    
    init(rect: MKMapRect) {
        positionRect = rect
    }
}

extension QuadTreeNode: QuadTreeAcceptance {
    
    @discardableResult
    func add(annotation: MKAnnotation) -> Bool {
        
        if !positionRect.contains(annotation.coordinate) {
            return false
        }
    
        switch type {
        case .leaf:
            points.append(annotation)
            if points.count > pointLimit {
                scatter()
            }
        case .internal(let children):
            for child in children where child.add(annotation: annotation){
                return true
            }
            
            return false
        }
        
        return true
    }
    
    @discardableResult
    func remove(_ annotation: MKAnnotation) -> Bool {
        guard positionRect.contains(annotation.coordinate) else { return false }
        
        _ = points.index { $0.coordinate == annotation.coordinate }.map { points.remove(at: $0) }

        switch type {
        case .leaf: break
        case .internal(let children):
            for child in children where child.remove(annotation) {
                return true
            }
            
            return false
        }
        
        return true
    }
    
    func annotations(in rect: MKMapRect) -> [MKAnnotation] {
        guard positionRect.intersects(rect) else { return [] }
        
        var result = [MKAnnotation]()
        
        for point in points where positionRect.contains(point.coordinate) {
            result.append(point)
        }
        
        switch type {
        case .leaf: break
        case .internal(let children):
            for childNode in children {
                result.append(contentsOf: childNode.annotations(in: rect))
            }
        }
        
        return result
    }
    
    private func scatter() {
        switch type {
        case .leaf:
            type = .internal(children: Children(parentNode: self))
        case .internal:
            preconditionFailure("Calling subdivide on an internal node")
        }
    }
}

extension MKMapRect {
    func contains(_ point: CLLocationCoordinate2D) -> Bool {
        let userPoint = MKMapPointForCoordinate(point);
        let inside = MKMapRectContainsPoint(self, userPoint)
        
        return inside
    }
    
    func intersects(_ mapRect: MKMapRect) -> Bool {
        return MKMapRectIntersectsRect(self, mapRect)
    }
    
    var minX: Double {
        return MKMapRectGetMinX(self)
    }
    
    var minY: Double {
        return MKMapRectGetMinY(self)
    }
    
    var midX: Double {
        return MKMapRectGetMidX(self)
    }
    
    var midY: Double {
        return MKMapRectGetMidY(self)
    }
    
    var maxX: Double {
        return MKMapRectGetMaxX(self)
    }
    
    var maxY: Double {
        return MKMapRectGetMaxY(self)
    }
    
    var topLeftRect: MKMapRect {
        return MKMapRect(minX: minX, minY: minY, maxX: midX, maxY: midY)
    }
    
    var topRightRect: MKMapRect {
        return MKMapRect(minX: midX, minY: minY, maxX: maxX, maxY: midY)
    }
    
    var bottomLeftRect: MKMapRect {
        return MKMapRect(minX: minX, minY: midY, maxX: midX, maxY: maxY)
    }
    
    var bottomRightRect: MKMapRect {
        return MKMapRect(minX: midX, minY: midY, maxX: maxX, maxY: maxY)
    }
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.init(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: width, height: height))
    }
    
    init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.init(x: minX, y: minY, width: abs(maxX - minX), height: abs(maxY - minY))
    }
}

extension CLLocationCoordinate2D: Equatable {
    
}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
