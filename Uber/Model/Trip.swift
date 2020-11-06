//
//  Trip.swift
//  Uber
//
//  Created by PROGRAMAR on 15/10/20.
//

import CoreLocation

struct Trip {
    
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    
    let passengerUid: String
    var driverUid: String?
    var state: TripState!
    
    init(passengerUid: String, diccionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupCoordinates =  diccionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees  else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates =  diccionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees  else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = diccionary["driverUid"] as? String ?? "No asignado "
        
        if let state = diccionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
        
        
    }
    
    
}

enum TripState: Int {
    case requested 
    case accepted
    case driverArrived
    case inProgress
    case completed
}
