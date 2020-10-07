//
//  HomeController.swift
//  Uber
//
//  Created by PROGRAMAR on 07/10/20.
//

import Firebase
import UIKit
import MapKit


class HomeController: UIViewController  {
    //    MARK: -Properties
    
    private let mapview = MKMapView()
    private let locationManager =  CLLocationManager()
    
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn(){
        if  Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else{
            configureUI()
        }
        
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    
    //    MARK: - Helper Function
        
    
    func configureUI(){
       configureMapView()
    }
    

    func configureMapView(){
        view.addSubview(mapview)
        mapview.frame = view.frame
        
        mapview.showsUserLocation  = true
        mapview.userTrackingMode = .follow
        
    }
    
}


extension HomeController : CLLocationManagerDelegate{
    

   
    func enableLocationServices(){
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: NOT DETERRMINED")
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted: break

        case .denied: break
            
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
          print("DEBUG: authorized when in use ")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
}
