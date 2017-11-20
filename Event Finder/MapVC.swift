//
//  MapVC.swift
//  Event Finder
//
//  Created by Marcus Ng on 11/14/17.
//  Copyright © 2017 Marcus Ng. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
//import SwiftyJSON

class MapVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        let sanLat = 37.758760
        let sanLon = -122.444800
        let nyLat = 40.7182
        let nyLon = -74.0060
        let camera = GMSCameraPosition.camera(withLatitude: nyLat, longitude: nyLon, zoom: 13)
        self.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: nyLat, longitude: nyLon)
        marker.title = "New York"
        marker.snippet = "NY"
        marker.map = self.mapView
    }
    
    func findEvents(url: String) {
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            if let JSON = response.result.value as? [String:Any] {
                print(JSON)
                if let events = JSON["results"] as? [[String:Any]] {
                    print(events)
                    for event in events {
                        if let venue = event["venue"] as? [String:Any] {
                            let lat = venue["lat"] as! Double
                            let lon = venue["lon"] as! Double
                            let name = event["name"] as! String
                            let timestamp = event["time"] as! Double
                            
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            print(coordinate)
                            GMSGeocoder.init().reverseGeocodeCoordinate(coordinate, completionHandler: { (response, error) in
                                if error != nil {
                                    print(error)
                                    return
                                }
                                // Add event positionmarker
                                let marker = GMSMarker()
                                marker.position = coordinate
                                marker.title = name
                                marker.snippet = response?.firstResult()?.thoroughfare
                                marker.icon = GMSMarker.markerImage(with: .green)
                                marker.map = self.mapView
                                print("Event Marker Added")
                            })
                        }
                    }
                }
            }
        })
    }
}

extension MapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        GMSGeocoder.init().reverseGeocodeCoordinate(coordinate) { (response, error) in
            if error != nil {
                print(error)
                return
            }
            mapView.clear()
            // Add your position marker
            let marker = GMSMarker()
            marker.position = coordinate
            marker.title = "Your Position"
            marker.snippet = response?.firstResult()?.thoroughfare
            marker.map = self.mapView
            print("Position Changed")
            
            // Search for locations
            let key = "API_KEY"
            let lat = coordinate.latitude
            let lon = coordinate.longitude

            // Search for events
            let eventsURL = "https://api.meetup.com/2/open_events?&sign=true&photo-host=public&lat=\(lat)&lon=\(lon)&radius=1&page=20&key=\(key)"
            self.findEvents(url: eventsURL)
        }
    }
    
}
