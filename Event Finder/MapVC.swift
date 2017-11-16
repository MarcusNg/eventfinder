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
import SwiftyJSON

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
            if let value = response.result.value {
                let json = JSON(value)
                for i in 0...json.count {
                    let event = json[i]
                    let lat = event["lat"].doubleValue
                    let lon = event["lon"].doubleValue
                    let city = event["city"].stringValue
                    let state = event["state"].stringValue
                    let zip = event["zip"].stringValue
                    let snippet = "\(city), \(state) \(zip)"
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    GMSGeocoder.init().reverseGeocodeCoordinate(coordinate, completionHandler: { (response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        // Add event positionmarker
                        let marker = GMSMarker()
                        marker.position = coordinate
                        marker.title = response?.firstResult()?.thoroughfare
                        marker.snippet = snippet
                        marker.icon = GMSMarker.markerImage(with: .blue)
                        marker.map = self.mapView
                        print("Event Marker Added")
                    })
                }
            }
        })
    }
    
    func findMeetups(url: String) {
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                
                for i in 0...json.count {
                    let meetup = json[i]
                    let lat = meetup["lat"].doubleValue
                    let lon = meetup["lon"].doubleValue
                    let name = meetup["name"].stringValue
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
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
                        print("Meetup Marker Added")
                    })
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
            let key = "APIKEY"
            let lat = coordinate.latitude
            let lon = coordinate.longitude
//            let eventsURL = "https://api.meetup.com/find/locations?&sign=true&photo-host=public&lon=\(lon)&\(lat)&key=\(key)"
            
            // Search for meetups
            let meetupsURL = "https://api.meetup.com/find/groups?&sign=true&photo-host=public&lon=\(lon)&radius=1&lat=\(lat)&key=\(key)"
            
            self.findMeetups(url: meetupsURL)
//            self.findEvents(url: eventsURL)
            
        }
    }
    
}
