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
class CutPoint
{
    var arrayCoords:[CLLocationCoordinate2D]
    var polyline:String
    
    init(arrayCoords:[CLLocationCoordinate2D], polyline:String) {
        self.arrayCoords = arrayCoords
        self.polyline = polyline
    }
}
