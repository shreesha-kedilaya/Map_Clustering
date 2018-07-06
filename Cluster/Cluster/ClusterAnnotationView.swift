//
//  AnnotationView.swift
//  Cluster
//
//  Created by Shreesha on 21/06/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import Foundation
import MapKit

class ClusterAnnotationView: MKAnnotationView {
    var countLabel: UILabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.red
        frame = CGRect(origin: frame.origin, size: CGSize(width: 40, height: 40))
        countLabel.text = "20"
        countLabel.textAlignment = .center
        addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20
        countLabel.frame = bounds
        let annotationClass = annotation as? ClusterAnnotation
        let count = annotationClass?.members?.count ?? 0
        
        countLabel.text = "\(count)"
    }
}
