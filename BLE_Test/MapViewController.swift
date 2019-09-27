//
//  MapViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, BottomSheetDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var container: UIView!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    let regionRadius: CLLocationDistance = 1500
    var selectedDevice: String = ""
    var annotationArray = [String]()

    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.title = self.title
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        let currentLocation = app.locationManager.location
        centerMapOnLocation(location: currentLocation!)
        addTestAnnotation(current_location: currentLocation!)
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BottomSheetViewController{
            vc.bottomSheetDelegate = self
            vc.parentView = container
        }
    }
    
    func updateBottomSheet(frame: CGRect) {
        container.frame = frame
        //        backView.frame = self.view.frame.offsetBy(dx: 0, dy: 15 + container.frame.minY - self.view.frame.height)
        //        backView.backgroundColor = UIColor.black.withAlphaComponent(1 - (frame.minY)/200)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addTestAnnotation(current_location: CLLocation) {
        let ann1 = MKPointAnnotation()
        ann1.coordinate = CLLocationCoordinate2D(latitude: current_location.coordinate.latitude + 0.003, longitude: current_location.coordinate.longitude + 0.003)
        ann1.title = "device001"
        ann1.subtitle = "Temperature Sensor"
        self.annotationArray.append(ann1.title!)
        
        self.mapView.addAnnotation(ann1)

        let ann2 = MKPointAnnotation()
        ann2.coordinate = CLLocationCoordinate2D(latitude: current_location.coordinate.latitude + 0.003, longitude: current_location.coordinate.longitude - 0.003)
        ann2.title = "device003"
        ann2.subtitle = "Vibration Sensor"
        self.annotationArray.append(ann2.title!)
        
        self.mapView.addAnnotation(ann2)

        let ann3 = MKPointAnnotation()
        ann3.coordinate = CLLocationCoordinate2D(latitude: current_location.coordinate.latitude - 0.003, longitude: current_location.coordinate.longitude + 0.003)
        ann3.title = "device005"
        ann3.subtitle = "Temperature Sensor"
        self.annotationArray.append(ann3.title!)
        
        self.mapView.addAnnotation(ann3)

        let ann4 = MKPointAnnotation()
        ann4.coordinate = CLLocationCoordinate2D(latitude: current_location.coordinate.latitude - 0.003, longitude: current_location.coordinate.longitude - 0.003)
        ann4.title = "device007"
        ann4.subtitle = "Vibration Sensor"
        self.annotationArray.append(ann4.title!)
        
        self.mapView.addAnnotation(ann4)
    }
    
    @objc func buttonPress(_ sender: UIButton) {
        //if sender.tag == 100 {
            /*
            let alertVC = UIAlertController(title: "Detail Annotation Information", message: "Annotation should display gateway/device detail information here", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)*/

            NotificationCenter.default.post(
                name: NSNotification.Name("BottomSheetQueryDetail"),
                object: String(self.annotationArray[sender.tag])
            )
        //}
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annView == nil {
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        if (annotation.title)! == "device001" || (annotation.title)! == "device005" {
            let imageView = UIImageView(image: UIImage(named: "temperature2.png"))
            annView?.leftCalloutAccessoryView = imageView
            let label = UILabel()
            label.numberOfLines = 2
            if (annotation.title)! == "device001" {
                label.text = "gateway001\nsite01"
            } else {
                label.text = "gateway003\nsite03"
            }
            annView?.detailCalloutAccessoryView = label
            let button = UIButton(type: .detailDisclosure)
            //button.tag = 100
            if (annotation.title)! == "device001" {
                button.tag = 0
            } else {
                button.tag = 2
            }
            button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
            annView?.rightCalloutAccessoryView = button
        }
        
        if (annotation.title)! == "device003" || (annotation.title)! == "device007" {
            let imageView = UIImageView(image: UIImage(named: "vibration2.png"))
            annView?.leftCalloutAccessoryView = imageView
            let label = UILabel()
            label.numberOfLines = 2
            if (annotation.title)! == "device003" {
                label.text = "gateway002\nsite02"
            } else {
                label.text = "gateway004\nsite04"
            }
            annView?.detailCalloutAccessoryView = label
            let button = UIButton(type: .detailDisclosure)
            //button.tag = 100
            if (annotation.title)! == "device003" {
                button.tag = 1
            } else {
                button.tag = 3
            }
            button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
            annView?.rightCalloutAccessoryView = button
        }

        annView?.canShowCallout = true
        return annView
    }
}
