//
//  LocationPopup.swift
//  Roadside Assistance Application
//
//  Created by Ken-Chi Huang on 11/03/2020.
//  Copyright © 2020 Ken-Chi Huang. All rights reserved.
//

import UIKit
import MapKit

class LocationPopup: UIView {

    // Variables and outlets
    @IBOutlet var popupView: LocationPopup!
    @IBOutlet weak var addressLabel: UILabel!
    
    // Geocoder is used to get the user's location in address form.
    let locDecoder = CLGeocoder()
    
    // Constructor Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        startPopup()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        startPopup()
    }
    
    // Starts the pop up view on the map from a nib file and the project files
    func startPopup(){
        Bundle.main.loadNibNamed("LocationPopup", owner: self, options: nil)
        // Adding pop up to the subview of the main view
        addSubview(popupView)
        
        // Setting bounds for the frame of the pop up
        popupView.frame = self.bounds
        
        // Setting the pop up to resize only dependent on the phone and so that it's centred when first launched.
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        frame.origin.x -= (frame.width) / 2.0
        frame.origin.y -= (frame.height)
    }
    
    // Function to update the pin location using the geocoder's reverseGeocodeLocation method.
    func updatePinLocation(location: CLLocation){
        // Retrieves the exact location (in address form) of the user for them to give to the people on the phone.
        locDecoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) in
            // Checking that placemarks and error are valid (there are placemarks and there aren't any errors)
            
            if(error != nil){ return } else {
                // Getting address information
                
                guard let placemark = placemarks?.first else { return }
                let streetNumber = placemark.subThoroughfare ?? "123"
                let streetName = placemark.thoroughfare ?? "Fake Street"
                let cityName = placemark.locality ?? "Springfield"
                let postcode = placemark.postalCode ?? "USA USA"
                
                let locString = streetNumber + " " + streetName + ", \n" + cityName + ", \n" + postcode
                // Assigning address info to the custom view label
                self.addressLabel.text = locString
            }
        })
    }
}
