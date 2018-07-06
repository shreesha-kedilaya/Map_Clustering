//
//  Annotation.swift
//  Cluster
//
//  Created by Shreesha on 21/06/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import MapKit

class Annotation: MKPointAnnotation {
    var style: AnnotationStyle!
}

class ClusterAnnotation: Annotation {
    var members: [MKAnnotation]?
}

enum AnnotationStyle {
    case simple(color: UIColor, radius: CGFloat)
    case image(image: UIImage)
}
