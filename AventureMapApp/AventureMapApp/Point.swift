//
//  Route.swift
//  AventureMapApp
//
//  Created by TriQuach on 10/6/18.
//  Copyright © 2018 TriQuach. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps
class Point
{
    var point:CLLocationCoordinate2D
    var distance:Double
    
    init(point:CLLocationCoordinate2D, distance: Double) {
       self.point = point
        self.distance = distance
    }
}
