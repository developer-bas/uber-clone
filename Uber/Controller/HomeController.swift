//
//  HomeController.swift
//  Uber
//
//  Created by PROGRAMAR on 07/10/20.
//

import Firebase
import UIKit
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

class HomeController: UIViewController  {
    //    MARK: -Properties
    
    private let mapview = MKMapView()
    private let locationManager =  LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private  var searchResults = [MKPlacemark]()
    
    private var user: User? {
        didSet{
            locationInputView.user = user
        }
    }
    
   
    
    private final let locationInptViewHeight: CGFloat = 200
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
//signOut()
       
    }
    
    // MARK: - API
    
    func fetchUserData(){
        guard let curretUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: curretUid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers(){
        guard let location = locationManager?.location else {return}
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else{ return}
            let annotation = DriverAnnotation(uid: driver.uid ,coordinate: coordinate)
            
            var driverIsVisible:Bool{
                return self.mapview.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    if driverAnno.uid  == driver.uid{
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    
                    return false
                }
                
            }
            
            if !driverIsVisible{
                self.mapview.addAnnotation(annotation)
            }
           
        }
    }
    
    
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
           configure()
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
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    
    func configureUI(){
       configureMapView()
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64 )
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableview()
        
    }
    

    func configureMapView(){
        view.addSubview(mapview)
        mapview.frame = view.frame
        
        mapview.showsUserLocation  = true
        mapview.userTrackingMode = .follow
        mapview.delegate = self
        
    }
    
    func  configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInptViewHeight)
        
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInptViewHeight
            }
        }

    }
    
    func configureTableview(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInptViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        
        
        view.addSubview(tableView)
    }
}

//MARK: - Map helper function
private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark])-> Void){
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapview.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
        
            guard  let response = response else { return }
            
            response.mapItems.forEach { mapItem in
                results.append(mapItem.placemark)
                
            }
        
            completion(results)
            
        }
        
        
        
    }
}




extension HomeController: MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "car")
//            let size = CGSize(width: 10, height: 10)
//            view.image?.draw(in:  CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            
            return view
        }
        return nil
    }
    
}


extension HomeController {
    

   
    func enableLocationServices(){
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: NOT DETERRMINED")
            locationManager?.requestWhenInUseAuthorization()
            
        case .restricted: break

        case .denied: break
            
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
          print("DEBUG: authorized when in use ")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        
        }
    }
    
    
    
    
}

extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
    
    
}

extension HomeController: LocationInputViewDelegate{
    func executeSearch(query: String) {
       
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
     
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

        
    }
    
    
}

extension HomeController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1{
        
            cell.placemark = searchResults[indexPath.row]
            
        }
        
        return cell
        
    }
    
    
    
}
