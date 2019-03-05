//
//  AllowLocationAccessViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCoreLocation

class AllowLocationAccessViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var fakeModalNotificationImage: UIImageView!
    
    @IBOutlet weak var locationServiceLabel: UILabel!
    @IBOutlet weak var locationAccessLabel: UILabel!
    
    var selectedCountry: String = ""
    var bag = DisposeBag()
    var userLocation: CLLocation!
    
    var locationManager = CLLocationManager()

    var descriptionText: String = ""
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "We need to verify that you are in \(selectedCountry) in order to continue"
        updateViewLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewLabels()
    }
    
    private func updateViewLabels() {
        locationManager.rx
            .isEnabled
            .debug("isEnabled")
            .subscribe(onNext: { isEnabled in
                self.locationServiceLabel.text = "\(isEnabled)"
            })
            .disposed(by: bag)
        
        locationManager.rx
            .didChangeAuthorization
            .debug("didChangeAuthorization")
            .subscribe(onNext: {_, status in
                var msg = ""
                switch status {
                case .denied:
                    msg = "Authorization denied"
                case .notDetermined:
                    msg = "Authorization: not determined"
                case .restricted:
                    msg = "Authorization: restricted"
                case .authorizedAlways, .authorizedWhenInUse:
                    msg = "All good fire request"
                }
                
                self.locationAccessLabel.text = msg
            })
            .disposed(by: bag)
        
        locationManager.delegate = self
    }
    
    @IBAction func dontAllowTapped(_ sender: Any) {
        let alert = UIAlertController(title: "We're sorry but...", message: "You have to allow location access to be able to continue so that you can start using your free 2GB.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func failedToGetLocationAlert() {
        let alert = UIAlertController(title: "We're sorry but...", message: "We were unable to get your current location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func okTapped(_ sender: Any) {
        verifyLocation()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        verifyLocation()
    }
    
    private func showLocationServiceDisabled() {
        performSegue(withIdentifier: "showLocationServiceDisabled", sender: self)
    }
    
    private func showLocationAccessDenied() {
        performSegue(withIdentifier: "showLocationAccessDenied", sender: self)
    }
    
    private func showLocationAccessRestricted() {
        performSegue(withIdentifier: "showLocationAccessRestricted", sender: self)
    }
    
    private func handleDenied() {
        
    }
    
    private func verifyLocation() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            
            switch status {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted:
                showLocationAccessRestricted()
            case .denied:
                showLocationAccessDenied()
            case .authorizedAlways, .authorizedWhenInUse:
                userLocation = nil
                print("request location...")
                locationManager.requestLocation()
                /*
                TODO: Did not get the location part to work using RxCoreLocation. the subscription never returned a value thus nothing happened. Could be related to simulator only when faking locations.
                locationManager.rx
                    .placemark
                    .subscribe(onNext: { placemark in
                        if let country = placemark.country {
                            if self.selectedCountry == country {
                                // Location verified
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "unwindFromCountry", sender: self)
                                }
                            } else {
                                // Location not in correct country
                                DispatchQueue.main.async {
                                    self.showWrongCountry()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.failedToGetLocationAlert()
                            }
                        }
                    })
            */
            }
        } else {
            showLocationServiceDisabled()
        }
        
        // Alternative code using rxcorelocation
        /*
        // TODO: Is subscription a stream of events or just a single event?
        
        // Show location service disabled view if service is disabled
        locationManager.rx
            .isEnabled
            .debug("isEnabled")
            .filter({ isEnabled in
                return isEnabled == false
            })
            .subscribe(onNext: {_ in
                DispatchQueue.main.async {
                    self.showLocationServiceDisabled()
                }
            })
            .disposed(by: bag)
        
        // Show location access views if service is enabled and authorization is restricted or denied
        locationManager.rx
            .isEnabled
            .debug("isEnabled")
            .filter({ isEnabled in
                return isEnabled == true
            })
            .flatMapLatest{_ in
                self.locationManager.rx
                    .didChangeAuthorization
            }
            .filter({_,status in
                switch status {
                case .denied, .restricted:
                    return true
                default:
                    return false
                }
            })
            .subscribe(onNext: {_,status in
                switch status {
                case .denied:
                    DispatchQueue.main.async {
                        self.showLocationAccessDenied()
                    }
                case .restricted:
                    DispatchQueue.main.async {
                        self.showLocationAccessRestricted()
                    }
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        // Verify location service is enabled and authorization is authorizedAlways or authorizedWhenInUse
        locationManager.rx
            .isEnabled
            .debug("isEnabled")
            .filter({ isEnabled in
                return isEnabled == true
            })
            .flatMapLatest{_ in
                self.locationManager.rx
                    .didChangeAuthorization
            }
            .filter({_,status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    return true
                default:
                    return false
                }
            })
            .flatMapLatest{_ in return self.locationManager.rx.placemark.debug("placemark")}
            .subscribe(onNext: {placemark in
                guard let country = placemark.country else {
                    // TODO: Handle error
                }
                
                print("country: \(country)")
            })
            .disposed(by: bag)
         */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showLocationAccessDenied", "showLocationServiceDisabed", "showLocationAccessRestricted", "showWrongCountry":
            let vc = segue.destination as! WithCountryFieldProtocol
            vc.country = selectedCountry
        default:
            break
        }
    }
    
    private func showWrongCountry() {
        performSegue(withIdentifier: "showWrongCountry", sender: self)
    }
}

extension AllowLocationAccessViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if userLocation == nil {
            if let location = locations.first {
                userLocation = location
                print("Location: \(location)")
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    if let error = error {
                        print("Unable to Reverse Geocode Location (\(error))")
                        // locationLabel.text = "Unable to Find Address for Location"
                        self.failedToGetLocationAlert()
                        
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first, let country = placemark.country, let isoCountryCode = placemark.isoCountryCode {
                            print("country: \(country)")
                            if self.selectedCountry == country {
                                // Location verified
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "unwindFromCountry", sender: self)
                                }
                            } else {
                                // Location not in correct country
                                DispatchQueue.main.async {
                                    self.showWrongCountry()
                                }
                            }
                        } else {
                            print("No Matching Addresses Found")
                            self.failedToGetLocationAlert()
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        failedToGetLocationAlert()
    }
}

class DismissSegue: UIStoryboardSegue {
    
    override func perform() {
        if let p = source.presentingViewController {
            p.dismiss(animated: true, completion: nil)
        }
    }
    
}

protocol WithCountryFieldProtocol: AnyObject {
    var country: String { get set }
}