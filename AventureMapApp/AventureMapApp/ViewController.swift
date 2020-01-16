//
//  ViewController.swift
//  AventureMapApp
//
//  Created by TriQuach on 9/9/18.
//  Copyright © 2018 TriQuach. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class ViewController: UIViewController, UISearchBarDelegate {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultsFromViewController: GMSAutocompleteResultsViewController?
    var fromController: UISearchController?
    var resultsToViewController: GMSAutocompleteResultsViewController?
    var toController: UISearchController?
    
    var resultView: UITextView?
    
    private let locationManager = CLLocationManager()
    @IBOutlet weak var mapViewMain: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GPSFunction()
        autoCompletePlace()
    }
    
    @IBAction func routesFunction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let directions = storyboard.instantiateViewController(withIdentifier: "Directions") as! DirectionsViewController
//        self.navigationController?.pushViewController(directions, animated: true)
        present(directions, animated: true, completion: nil)

//        self.navigationController?.pushViewController(directions, animated: true)
    }
    func GPSFunction() {
//        let camera = GMSCameraPosition.camera(withLatitude: 43.252416, longitude: -79.925414, zoom: 15.0)
//        mapViewMain.camera = camera
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
    }
    func directionsUI() {
        
    }
    func autoCompletePlace() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
        //        searchController?.searchBar.showsCancelButton = false
        
        
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
}
extension ViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        mapViewMain.isMyLocationEnabled = true
        mapViewMain.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7
        mapViewMain.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
    }
}

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        self.searchController?.searchBar.text = place.formattedAddress
        markerFromSelectedPlace(place: place)
        
    }
    func markerFromSelectedPlace(place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        mapViewMain.camera = camera
        mapViewMain.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = mapViewMain
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}





