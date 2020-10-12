//
//  DriverAnnotation.swift
//  Uber
//
//  Created by PROGRAMAR on 12/10/20.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String , coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    
}
