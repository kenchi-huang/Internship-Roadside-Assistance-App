//
//  MapViewController.swift
//  Roadside Assistance Application
//
//  Created by Ken-Chi Huang on 02/03/2020.
//  Copyright © 2020 Ken-Chi Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openCallViewButton: UIButton!
    
    // Variables
    let locationManager = CLLocationManager()
    let generalValueForZoom: Double = 500
    var alertController: UIAlertController?
    var currentLocation: CLLocation?
    var previousLocation: CLLocation?
    var locationPopup: LocationPopup?
    
    // View Controller start up
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfLocationIsEnabled()
        
        // Set the delegate for the map to this class
        mapView.delegate = self
        // Set delegate for location manager to this class
        locationManager.delegate = self
    }
    
    // Starts the location manager and sets location accuracy & enables the user's location to be seen on the map
    func startLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
    }
    
    // Method to centre the map on the user's current location
    func centreOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: generalValueForZoom, longitudinalMeters: generalValueForZoom)
            mapView.setRegion(region, animated: true)
            currentLocation = locationManager.location
        }
    }
    
    // Method to check if the user's location services (on the device itself - not on an app to app basis) is enabled or disabled. If enabled then the app will check the user's authorisation for the app to use user location. If disabled then the app will display a pop up alert telling the user to change their settings regarding location services.
    func checkIfLocationIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            startLocationManager()
            checkAuthorisation()
        } else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.createAlert(titleText: "Turn on Location Services to allow Roadside Assistance to determine your location", messageText: "")
            }
        }
    }
    
    // Checks authorisation status upon app start
    func checkAuthorisation(){
        switch CLLocationManager.authorizationStatus(){
        // If the app is authorised to use the user's location then the user's location is shown on the map and the map is centred around the user's current location
        case .authorizedWhenInUse:
            turnOnTracking()
        // If the app is not authorised to see the user's location, then a pop up alert is displayed on the device to let the user know that permission is required for the app to function as intended.
        case .denied, .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                self.createAlert(titleText: "Location Services disabled", messageText: "Please authorise Roadside Assistance to find your location while using the app.")
            }
            break
        // If permission cannot be immediately determined, then authorisation will be requested by the app, if this is denied then a pop up alert will be displayed on the screen like in the case where the app isn't authorised to see the user's location, if allowed then the map will move to centre around the user's location.
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                if(CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted){
                    self.createAlert(titleText: "Location Services disabled", messageText: "Please authorise Roadside Assistance to find your location while using the app.")
                }
            }
            self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true);
        // We are not requesting permission for always on location (even in the background), so in this event nothing will happen.
        case .authorizedAlways:
            break
        // Future proofing requires all future possible permissions to do nothing.
        @unknown default:
            break
        }
    }
    
    // Method to show user location, centre the map around the user's location and update the variable currentLocation
    func turnOnTracking(){
        mapView.showsUserLocation = true
        centreOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    // Method to create a pop up alert on the user's screen that has 2 options - ok (sending the user to settings) and cancel (closing the pop up alert)
    func createAlert(titleText: String, messageText: String){
        // Adds the alert to the dispatch queue
        DispatchQueue.main.async{
            let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
            // Action to allow user to go to settings with a response to the alert
            let settingAction = UIAlertAction( title: "Ok", style: .default, handler: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) { UIApplication.shared.open(settingsUrl, completionHandler: { (success) in }) } })
            // Action to allow user to close alert pop up
            let cancelAction = UIAlertAction( title: "Cancel", style: .cancel, handler: { _ in } )
            
            // Adds both actions to the alert pane
            alert.addAction(cancelAction)
            alert.addAction(settingAction)
            
            // Enables the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Updates the pin location of the pop up annotation pane that displays the user's location in address form
    func updatePopupLocation(){
        locationPopup?.updatePinLocation(location: locationManager.location!)
    }
    
    // Checking the user's current location and updating the location of the popup if it changes
    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Sets first location and centres around user location when app is first launched
        if(currentLocation == nil){
            currentLocation = locations.last!
            //let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: currentLocation!.coordinate, latitudinalMeters: generalValueForZoom, longitudinalMeters: generalValueForZoom)
            // Centres map around the user's location
            mapView.setRegion(region, animated: true)
        } else{
            // After initial launch, the app then just overwrites the CLLocation variable: currentLocation
            currentLocation = locations.last!
        }
        
        // If the pop up has already been created then the pop up label's information is updated with current information
        if(locationPopup != nil){
            updatePopupLocation()
        }
    }

    // Checking authorisation status again after authorisation status has been changed (ie when the pop up appears upon app start)
    func locationManager( _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorisation()
    }
    
    // Setting up annotation pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            let informationPin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "locationInfo")
            
            // Creates custom view pop up to display information - user's current address
            locationPopup = LocationPopup(frame: CGRect(x: 0, y: 0, width: 245, height: 195))
            informationPin.addSubview(locationPopup!)
            
            // Update the address information the user needs to use when calling for a recovery vehicle
            updatePopupLocation()
            // Returns the annotation pin if there's an annotation pin
            return informationPin
        } else{
            // Otherwise nothing is returned.
            return nil
        }
    }
    
}
