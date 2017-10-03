//
//  CafeDetailViewController.swift
//  KenticoCloud
//
//  Created by Martin Makarsky on 17/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MapKit
import KenticoCloud

class CafeDetailViewController: UIViewController {

    // MARK: Properties
    
    var cafe: Cafe?
    var image: UIImage?
    
    @IBOutlet var name: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var map: MKMapView?
    @IBOutlet var backButton: UIButton!
    
    // MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.stylePinkButton()
        
        if let cafe = cafe {
            setCafeInfo(cafe: cafe)
            setMap(cafe: cafe)
        }
        
        setImages()
        
        if let city = cafe?.city {
            let trackingClient = TrackingClient.init(projectId: AppConstants.trackingProjectId, enableDebugLogging: true)
            trackingClient.trackActivity(activityName: "Cafe detail view: \(city)", completionHandler: {
                (isSuccess, error) in
                if !isSuccess {
                    // custom retry policy
                }
            })
            trackingClient.addContact(email: "panacik@kentico.com")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Outlet actions
    
    @IBAction func navigateBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: Set content
    
    private func setCafeInfo(cafe: Cafe) {
        name.text = cafe.name
        city.text = cafe.city
        address.text = "\(cafe.street ?? "") \(cafe.city ?? "")"
        phone.text = cafe.phone
        email.text = cafe.email
    }
    
    private func setMap(cafe: Cafe) {
        let address = "\(cafe.street ?? "")  \(cafe.state ?? "") \(cafe.country ?? "")  \(cafe.zip ?? "")"
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            
            let pinPoint = MKPointAnnotation()
            pinPoint.coordinate = location.coordinate
            pinPoint.title = cafe.name
            self.map?.addAnnotation(pinPoint)

            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.map?.setRegion(region, animated: true)
        }
    }
    
    private func setImages() {
        if (photo) != nil {
            self.photo.image = image
        }
    }

}
