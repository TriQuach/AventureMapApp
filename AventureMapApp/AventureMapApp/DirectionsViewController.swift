//
//  DirectionsViewController.swift
//  AventureMapApp
//
//  Created by TriQuach on 9/15/18.
//  Copyright © 2018 TriQuach. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Darwin
import Polyline
import M13Checkbox
import SigmaSwiftStatistics
class DirectionsViewController: UIViewController, UITextFieldDelegate,UISearchBarDelegate, GMSMapViewDelegate {
    
    var arrayNewCoor: [CLLocationCoordinate2D] = []
    var finalPolyline:[String] = []

    let numberChoosenPoint = 50
    let threshold = 3.5
    var countPolyline = 0
    var arrayPolyline:[String] = []
   
    var arrayPoint:[Point] = []

    var loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var source:CLLocationCoordinate2D?
    @IBOutlet weak var mapviewMain: GMSMapView!
    

    @IBOutlet weak var textfieldDestination: UITextField!
    @IBOutlet weak var textfieldYourLocation: UITextField!
    @IBOutlet weak var uiviewSearchDirections: UIView!

    @IBOutlet weak var btnSwitch: UIButton!
    
    var radius:Double = 7000
    var isYourLocation = 0
    var intermediatePoint: CLLocationCoordinate2D?

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    private let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.textfieldDestination.inputView = UIView()
        self.textfieldDestination.inputAccessoryView = UIView()
        
        self.textfieldYourLocation.inputView = UIView()
        self.textfieldYourLocation.inputAccessoryView = UIView()
        
//        self.loading.isHidden = true
        loading.center = view.center
        self.view.addSubview(self.loading)
//        self.mapviewMain.addSubview(self.loading!)
        self.mapviewMain.delegate = self

        self.source = CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
  
        
        
        textfieldDestination.delegate = self
        textfieldYourLocation.delegate = self
        
        textfieldYourLocation.attributedPlaceholder = NSAttributedString(string: "Your location",attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        textfieldDestination.attributedPlaceholder = NSAttributedString(string: "Choose destination...",attributes: [NSAttributedStringKey.foregroundColor: UIColor(cgColor: #colorLiteral(red: 0.8235294118, green: 0.8862745098, blue: 0.9882352941, alpha: 1))])
        GPSFunction()
        mapviewMain.isHidden = true
       
        
        
        var path: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 36.579, longitude: -118.292),
        CLLocationCoordinate2D(latitude: 36.606, longitude: -118.0638),
        
        
        ]

       

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @IBAction func backFunction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textfieldDestination || textField == textfieldYourLocation {
            
//            print("fuckkkk")
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let timkiem = storyboard.instantiateViewController(withIdentifier: "AutoCompleteViewController") as! AutoCompleteViewController
//            self.navigationController?.pushViewController(timkiem, animated: true)
//
//
//
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self as? GMSAutocompleteViewControllerDelegate

            present(autocompleteController, animated: false, completion: nil)
            self.navigationController?.pushViewController(autocompleteController, animated: true)
            if (textField == textfieldYourLocation) {
                self.isYourLocation = 1
            } else {
                self.isYourLocation = 0
            }


        }
    }


    
    func autoCompletePlace() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as! GMSAutocompleteResultsViewControllerDelegate
      
        searchController = UISearchController(searchResultsController: resultsViewController)
        
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        self.view.addSubview((searchController?.searchBar)!)
       
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    func GPSFunction() {

        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        
    }
    func showDirections(source: CLLocationCoordinate2D, destination: GMSPlace) {
        
        
        
        let destination: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        
        let marker = GMSMarker()
                                            marker.position = destination
        
                                            marker.map = self.mapviewMain
        
        self.getOptimalRoute(from: source, to: destination)
      
        
        
        
    }
    
    func getOptimalRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(source.latitude),\(source.longitude)&destinations=\(destination.latitude),\(destination.longitude)&key=AIzaSyAWNdyFYdDR46TXlEEpwf96_AaNeIAE_wI"
        
        print (urlString)
        
        let url = URL(string: urlString)!
        
        let req = URLRequest(url: URL(string: urlString)!)
        let task = URLSession.shared.dataTask(with: req) { (d, u, e) in
            
            do
            {
                
                let json = try JSONSerialization.jsonObject(with: d!, options: .allowFragments) as! AnyObject
                let rows = json["rows"] as! [AnyObject]
                let elements = rows[0]["elements"] as! [AnyObject]
                let distance = elements[0]["distance"] as! AnyObject
                let value = distance["value"] as! Float
                let duration = elements[0]["duration"] as! AnyObject
                let text = duration["text"] as! String
                let value_time = duration["value"] as! Float
                DispatchQueue.main.async {
                    
                    self.showAlert(duration: text, optimalDistance: value,value_time: value_time, from: source, to: destination )
                    
                    
                    
                }
                
                
            }catch{}
        }
        task.resume()
    }

    func getDistanceFromLatLonInKm(lat1: Double,lon1: Double,lat2: Double,lon2: Double) -> Double {
        var R:Double = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
    sin(dLat/2) * sin(dLat/2) +
    cos(deg2rad(lat1)) * cos(deg2rad(lat2)) *
    sin(dLon/2) * sin(dLon/2)
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
    }
    
    func deg2rad(deg: Double) -> Double {
    return deg * (3.14/180)
    }
    
    func showAlert(duration: String, optimalDistance: Float,value_time: Float, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let blurEffect = UIBlurEffect(style: .light)
        // Add effect to an effect view
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.frame
        
        
        let velocity: Float = optimalDistance / value_time
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Time of Optimal Route:" + duration, message: "how much more time are you willing to waste for a more exciting route (in hours, e.g. 0.5)", preferredStyle: .alert)
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            visualEffectView.removeFromSuperview()
            let new_time = value_time + Float((textField?.text)!)! * 3600
            let new_distance = velocity * new_time
            let distance2Points = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: destination.latitude
                , lon2: destination.longitude) * 1000
            let newRadius = sqrt(pow((Double(new_distance)/2),2.0) - pow((distance2Points/2),2.0))
           self.radius = newRadius
            var middlePoint = self.calculateMiddlePoint(x: source, y: destination)
            let newPoint = self.randomWaypoints(place: middlePoint)
           
            let marker2 = GMSMarker()
            marker2.position = newPoint
            
            marker2.map = self.mapviewMain
            self.intermediatePoint = newPoint
            self.getRawDataOverpass(source: source, destination: destination, interPoint: self.intermediatePoint!
                , typeSurface: "unpaved")
//            self.pickSurface.isHidden = false
        }))
        
        // 4. Present the alert.
        view.addSubview(visualEffectView)
        self.present(alert, animated: true, completion: nil)
    }
    func getRawDataOverpass(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, interPoint: CLLocationCoordinate2D, typeSurface: String) {
//        http://overpass-api.de/api/interpreter?data=%5Bout%3Ajson%5D%5Btimeout%3A90%5D%3B%0Away%5B%22surface%22%3D%22unpaved%22%5D%0A%5B%22highway%22%20%21%3D%20%22footway%22%5D%20%0A%5B%22highway%22%20%21%3D%20%22cycleway%22%5D%0A%5B%22highway%22%20%21%3D%20%22steps%22%5D%0A%5B%22highway%22%20%21%3D%20%22path%22%5D%0A%5B%22highway%22%20%21%3D%20%22service%22%5D%0A%5B%22access%22%20%21%3D%20%22private%22%5D%0A%20%20%28poly%3A%2243.252362%20-79.925017%2043.6262798814317%20-79.4792834001596%2044.501193%20-80.215331%22%29%3B%0Aout%20geom%3B
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let urlString = "http://overpass-api.de/api/interpreter?data=%5Bout%3Ajson%5D%5Btimeout%3A90%5D%3B%0Away%5B%22surface%22%3D%22\(typeSurface)%22%5D%0A%5B%22highway%22%20%21%3D%20%22footway%22%5D%20%0A%5B%22highway%22%20%21%3D%20%22cycleway%22%5D%0A%5B%22highway%22%20%21%3D%20%22steps%22%5D%0A%5B%22highway%22%20%21%3D%20%22path%22%5D%0A%5B%22highway%22%20%21%3D%20%22service%22%5D%0A%5B%22access%22%20%21%3D%20%22private%22%5D%0A%20%20%28poly%3A%22\(source.latitude)%20\(source.longitude)%20\(interPoint.latitude)%20\(interPoint.longitude)%20\(destination.latitude)%20\(destination.longitude)%22%29%3B%0Aout%20geom%3B"
        
        print ("overpass:" + urlString)
        
        
        let url = URL(string: urlString)
        
        let req = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: req) { (d, u, e) in
            
            do
            {
                
                let json = try JSONSerialization.jsonObject(with: d!, options: .allowFragments) as! AnyObject
                let elements = json["elements"] as! [AnyObject]
                var step = 0
                var track_step = 1
                let step2: Int = elements.count / self.numberChoosenPoint
                for i in 0..<self.numberChoosenPoint {
                    if (step < elements.count) {
                        let geometry = elements[step]["geometry"] as! [AnyObject]
                        let lat = geometry[geometry.count-1]["lat"] as! Double
                        let long = geometry[geometry.count-1]["lon"] as! Double
                        let point:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let distance = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: point.latitude, lon2: point.longitude)
                        let temp:Point = Point(point: point, distance: distance)
                        if (i == 0) {
                            self.arrayPoint.append(temp)
                        } else {
                            if (self.checkBeforeAppend(x: temp)) {
                                self.arrayPoint.append(temp)
                            } else {
                                var temp2:Point?
                                repeat {
                                    step += 1
                                    let geometry2 = elements[step]["geometry"] as! [AnyObject]
                                    let lat2 = geometry2[geometry2.count-1]["lat"] as! Double
                                    let long2 = geometry2[geometry2.count-1]["lon"] as! Double
                                    let point2:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat2, longitude: long2)
                                    let distance2 = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: point2.latitude, lon2: point2.longitude)
                                    temp2 = Point(point: point2, distance: distance2)
                                } while (!self.checkBeforeAppend(x: temp2!) && step<elements.count-1)
                                if (self.checkBeforeAppend(x: temp2!)) {
                                     self.arrayPoint.append(temp2!)
                                }
                               
                            }
                        }
                    }
                    else {
                        step = track_step
                        let geometry = elements[step]["geometry"] as! [AnyObject]
                        let lat = geometry[geometry.count/2]["lat"] as! Double
                        let long = geometry[geometry.count/2]["lon"] as! Double
                        let point:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let distance = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: point.latitude, lon2: point.longitude)
                        let temp:Point = Point(point: point, distance: distance)
                        if (i == 0) {
                            self.arrayPoint.append(temp)
                        } else {
                            if (self.checkBeforeAppend(x: temp)) {
                                self.arrayPoint.append(temp)
                            } else {
                                var temp2:Point?
                                repeat {
                                    step += 1
                                    let geometry2 = elements[step]["geometry"] as! [AnyObject]
                                    let lat2 = geometry2[geometry2.count-1]["lat"] as! Double
                                    let long2 = geometry2[geometry2.count-1]["lon"] as! Double
                                    let point2:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat2, longitude: long2)
                                    let distance2 = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: point2.latitude, lon2: point2.longitude)
                                    temp2 = Point(point: point2, distance: distance2)
                                } while (!self.checkBeforeAppend(x: temp2!) && step<elements.count-1)
                                if (self.checkBeforeAppend(x: temp2!)) {
                                    self.arrayPoint.append(temp2!)
                                }
                            }
                        }
                        track_step += 1
                    }
                    
                    
                    step += step2
                }
                    DispatchQueue.main.async {

                        let sortedArrayPoint = self.quicksort(self.arrayPoint)
                        self.getAllPolyline(x: sortedArrayPoint)

                    }
                
                
                
                
            }catch{}
        }
        task.resume()
    }
    
    func checkBeforeAppend(x: Point) -> Bool {
        for point in self.arrayPoint {
            if (abs(x.distance - point.distance) < self.threshold) {
                return false
            }
        }
        return true
    }
    
    
    
    
    
    func getAllPolyline(x: [Point]) {
        self.arrayPolyline = Array(repeating: "", count: x.count-1)

        for i in 0..<x.count - 1{
            self.newGetPolylineRouteToDestinationGoogle(from: x[i].point, to: x[i+1].point, index: i)
        }
    }
    
    func newGetPolylineRouteToDestinationGoogle(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, index: Int) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
//        let urlString = "https://graphhopper.com/api/1/route?point=\(source.latitude),\(source.longitude)&point=\(destination.latitude),\(destination.longitude)&vehicle=car&type=json&key=745048c8-120e-4669-94f7-5e8951931e37"
                let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&avoid=highways&key=AIzaSyAWNdyFYdDR46TXlEEpwf96_AaNeIAE_wI"
        
        print (urlString)
        let url = URL(string: urlString)
        
        let req = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: req) { (d, u, e) in
            
            do
            {
                
                let json = try JSONSerialization.jsonObject(with: d!, options: .allowFragments) as! AnyObject
                let routes = json["routes"] as! [AnyObject]

                
                
                if (routes.count > 0) {
                    var overview_polyline = routes[0]["overview_polyline"] as! AnyObject
                    let points = overview_polyline["points"] as! String

                    
                    
                    self.arrayPolyline[index] = points
                }
                self.countPolyline += 1
                
                DispatchQueue.main.async {
                    
                    if (self.countPolyline == self.arrayPolyline.count){
                        self.finalPath()
                    }

                }
                
           
                
            }catch{}
        }
        task.resume()
    }

    
    func encodeFromArrayCoords(x: [CLLocationCoordinate2D]) -> String {
        let polyline = Polyline(coordinates: x)
        let encodedPolyline: String = polyline.encodedPolyline
        return encodedPolyline
    }

    
    func finalPath() {

        for i in 0..<self.arrayPolyline.count {
            self.showPath(polyStr: self.arrayPolyline[i], color: .blue)
        }
        self.loading.isHidden = true
    }
    
    func quicksort<T: Point>(_ a: [T]) -> [T] {
        guard a.count > 1 else { return a }
        
        let pivot = a[a.count/2].distance
        let less = a.filter { $0.distance < pivot }
        let equal = a.filter { $0.distance == pivot }
        let greater = a.filter { $0.distance > pivot }
        
        return quicksort(less) + equal + quicksort(greater)
    }
    func parseObject(x: AnyObject,source: CLLocationCoordinate2D) {
        let lat = x["lat"] as! Double
        let long = x["lon"] as! Double
        let point:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let distance = self.getDistanceFromLatLonInKm(lat1: source.latitude, lon1: source.longitude, lat2: point.latitude, lon2: point.longitude)
        let temp:Point = Point(point: point, distance: distance)
        self.arrayPoint.append(temp)
    }

    func calculateMiddlePoint(x: CLLocationCoordinate2D, y: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lon1:Double = x.longitude * 3.14 / 180;
        let lon2:Double = y.longitude * 3.14 / 180;
        
        let lat1:Double = x.latitude * 3.14 / 180;
        let lat2:Double = y.latitude * 3.14 / 180;
        
        let dLon:Double = lon2 - lon1;
        
        let x:Double = cos(lat2) * cos(dLon);
        let y:Double = cos(lat2) * sin(dLon);
        
        let lat3:Double = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
        let lon3:Double = lon1 + atan2(y, cos(lat1) + x);
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat3 * 180 / 3.14, longitude: lon3 * 180 / 3.14)
       
        
        return center;
    }







  
    

    
    func showPathOverallRoute(x: [Route],color: UIColor) {
        
        for i in 0..<x.count {
            self.showPath(polyStr: x[i].points, color: color)
        }
//        for i in 0..<self.arrayUnpavedPoints.count {
//                                    let marker2 = GMSMarker()
//                                    marker2.position = self.arrayUnpavedPoints[i]
//
//                                    marker2.map = self.mapviewMain
//
//                                }
        self.loading.isHidden = true
        let camera = GMSCameraPosition.camera(withLatitude: (self.source?.latitude)!, longitude: (self.source?.longitude)!, zoom: 7.0)
        mapviewMain.camera = camera
        self.view.alpha = 1
    }
    func showPath(polyStr :String, color: UIColor){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        
        polyline.strokeWidth = 1.0
        polyline.strokeColor = color
        polyline.map = mapviewMain // Your map view
    }
    
    func cleanPoints(x: [Route]) {
        var temp: [CLLocationCoordinate2D] = []
        for i in 0..<x.count {
            
            let polyline = Polyline(encodedPolyline: x[i].points)
            let decodedCoordinates: [CLLocationCoordinate2D] = polyline.coordinates!
            temp.append(contentsOf: decodedCoordinates)
        }
        
        for i in 0..<temp.count {
            print ("i:" + String(i))
            print (temp[i].latitude)
            print (temp[i].longitude)
            let marker2 = GMSMarker()
            marker2.position = temp[i]
            
            marker2.map = self.mapviewMain
        }
    }

    func decodeFromPointsToCoor(arrayPoints: [String]) -> [CLLocationCoordinate2D] {
        var arrayRandomWayPoints: [CLLocationCoordinate2D] = []
        for i in 0..<arrayPoints.count {
            let polyline = Polyline(encodedPolyline: arrayPoints[i])
            let decodedCoordinates: [CLLocationCoordinate2D] = polyline.coordinates!
            for j in 0..<decodedCoordinates.count {
                arrayRandomWayPoints.append(decodedCoordinates[j])
            }
        }
        
        
        return arrayRandomWayPoints
    }
    
    func decodeFromOnePointToCoor(point: String) -> [CLLocationCoordinate2D] {
        var temp: [CLLocationCoordinate2D] = []
        let polyline = Polyline(encodedPolyline: point)
        let decodedCoordinates: [CLLocationCoordinate2D] = polyline.coordinates!
        return decodedCoordinates
    }

    
    func randomWaypoints(place: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let radiusInDegrees: Double = radius / 111300;
        
//        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
//        srand48(Int(time))
        
        let u = Double(Float(arc4random()) / Float(UINT32_MAX))
        let v = Double(Float(arc4random()) / Float(UINT32_MAX))
        let w: Double = radiusInDegrees * sqrt(u);
        let t: Double = 2 * 3.14 * v;
        let x: Double = w * cos(t);
        let y: Double = w * sin(t);

       var xp = x / cos(place.latitude);
        
        let foundLongitude: Double = xp + (place.longitude)
        let foundLatitude: Double = y + (place.latitude)
        
        var tempRandomWayPoints = CLLocationCoordinate2D(latitude: foundLatitude, longitude: foundLongitude)
        
        
        return tempRandomWayPoints
        
    }
    
    func markerFromSelectedPlace(lat: Double, long: Double) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15.0)
        mapviewMain.camera = camera
        mapviewMain.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        marker.map = mapviewMain
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    

    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print (marker.position.latitude)
        print (marker.position.longitude)
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.mapviewMain.delegate = self
        print (marker.position.latitude)
        print (marker.position.longitude)
        
        return true
    }
   

}
extension DirectionsViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
       
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
       
        dismiss(animated: true, completion: nil)
        
        
        if (self.isYourLocation == 1) {
            self.textfieldYourLocation.text = place.name
            self.source = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else {
            self.textfieldDestination.text = place.name
//            self.view.alpha = 0.5
//            self.loading.isHidden = false
//            self.loading.startAnimating()
        }
        
        
        
        self.textfieldDestination.textColor = UIColor.white
        self.textfieldYourLocation.textColor = UIColor.white
        self.mapviewMain.isHidden = false
        
        if (self.isYourLocation != 1) {
//            self.resetMap()
            self.showDirections(source: self.source!, destination: place)
        }
        
    }
    

    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension DirectionsViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        mapviewMain.isMyLocationEnabled = true
        mapviewMain.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7
        mapviewMain.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
    }
}
extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}

