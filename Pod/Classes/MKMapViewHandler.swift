//
//  MKMapViewHandler.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import MapKit
import UIKit

var kDistanceKey: UInt8 = 2

extension MKMapView {
    
    public var distance : CLLocationDistance {
        get {
            var dis: AnyObject! = objc_getAssociatedObject(self, &kDistanceKey)
            
            if dis == nil {
               dis = 100.0
            }
            
            return dis as! CLLocationDistance
        }
        set (value) {
            objc_setAssociatedObject(self, &kDistanceKey, value, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    public func setLocationWithCoordinates(coordinate: CLLocationCoordinate2D, distance:CLLocationDistance, animated: Bool) {
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance)
        
        self.setRegion(region, animated: animated)
    }
    
    public func setLocation(location: CLLocation, distance:CLLocationDistance, animated: Bool) {
        self.setLocationWithCoordinates(location.coordinate, distance: distance, animated: animated)
    }
}

class MKMapViewHandler : NSObject, HandlerProtocol {
    
    var type : AnyObject.Type? = nil
    
    func setValue(value: AnyObject?, onView: UIView) {
        
        if value == nil { return }
        
        let mapView = onView as! MKMapView
        
        if let location = value as? CLLocation {
            println(mapView.distance)
            mapView.setLocation(location, distance: mapView.distance, animated: true)
        } else if let location = value as? CLLocationCoordinate2D {
            mapView.setLocationWithCoordinates(location, distance: mapView.distance, animated: true)
        }
        
    }
    
}


