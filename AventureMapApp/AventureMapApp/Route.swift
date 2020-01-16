//
//  Route.swift
//  AventureMapApp
//
//  Created by TriQuach on 10/6/18.
//  Copyright © 2018 TriQuach. All rights reserved.
//

import Foundation
class Route
{
    var points:String
    var elevations:[Double]
    var isPaved: [Int]
    init(points:String, elevations:[Double], isPaved: [Int]) {
        self.points = points
        self.elevations = elevations
        self.isPaved = isPaved
    }
}
