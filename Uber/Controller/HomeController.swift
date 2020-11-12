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

private enum ActionButtonConfiguration{
    case showManu
    case dismissActionView
    
    init() {
        self = .showManu
    }
}

private enum AnnotationType:  String{
    case pickup
    case destination
}

class HomeController: UIViewController  {
    //    MARK: -Properties
    
    private let mapview = MKMapView()
    private let locationManager =  LocationHandler.shared.locationManager
    
    
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private final let locationInptViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    
    
    
    private  var searchResults = [MKPlacemark]()
    
    private var user: User? {
        didSet{
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            }else{
                observeTrips()
            }
        }
    }
    
    private var trip : Trip? {
        didSet{
            guard let user = user else {return}
            if user.accountType == .driver{
                guard let trip = trip else { return }
                let controller = PickupController(trip: trip)
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }else{
                print("DEBUG: Show ride action view for accepted ")
            }
        }
    }
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "hamburguer").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        
//        signOut()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else{return}
        print("DEBUG: the state is  \(trip.state)")
    }
    
//    MARK: - Selectors
    
    @objc func actionButtonPressed(){
        switch actionButtonConfig {
        case .showManu:
           print("")
            
        case .dismissActionView:
            
            removeAnnotationAndOverlays()
            mapview.showAnnotations(mapview.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showManu)
                self.animateRideActionView(shouldSHow: false)
            }
            
            
            
        }
        
    }
    
    
    
    // MARK: - Passenger API
    
    func observeCurrentTrip(){
        PassengerService.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            
            guard let state = trip.state  else { return }
            
            guard let driverUid = trip.driverUid else {return}
            
            switch state{
            
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationAndOverlays()
                
                self.zoomForActiveTripe(withDriverUid: driverUid)
                
                
                Service.shared.fetchUserData(uid: driverUid) { driver in
                
                    self.animateRideActionView(shouldSHow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
                
            case .completed:
                
                PassengerService.shared.deleteTrip { (err, ref) in
                    self.animateRideActionView(shouldSHow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showManu)
                    self.inputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip completed", withMessage: "We hope you enjoyed your trip")
                    
                }
           
            }
        }
    }
    func starTrip(){
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripeState(trip: trip, state: .inProgress) { (err, ref) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationAndOverlays()
            self.mapview.addAndSelectAnnotation(forCoordinate: trip.destinationCoordinates)
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            
            
            self.generatePolyline(forDestination: mapItem)
            
            self.mapview.zoomToFit(annotations: self.mapview.annotations)
            
        
        }
    }
    
    
    
    func fetchDrivers(){
        guard let location = locationManager?.location else {return}
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else{ return}
            let annotation = DriverAnnotation(uid: driver.uid ,coordinate: coordinate)
            
            var driverIsVisible:Bool{
                return self.mapview.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    if driverAnno.uid  == driver.uid{
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTripe(withDriverUid: driver.uid)
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
    
//    MARK: - Drivers API
    
    
    func observeTrips(){
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(trip: Trip){
        DriverService.shared.observeTripCancelled(trip: trip) {
             self.removeAnnotationAndOverlays()
             self.animateRideActionView(shouldSHow: false)
 //            self.mapview.zoomToFit(annotations: self.mapview.annotations)
             self.centerMapOnUserLocation()
             self.presentAlertController(withTitle: "Ooops!",withMessage: "El  pasajero cancelo el viaje")
             
             
         }
    }
    
//    MARK: - Shared API
    
    func fetchUserData(){
        guard let curretUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: curretUid) { user in
            self.user = user
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
   fileprivate func configureActionButton(config: ActionButtonConfiguration){
        switch config {
        case .showManu:
            self.actionButton.setImage(#imageLiteral(resourceName: "hamburguer").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showManu
        case .dismissActionView:
            
            actionButton.setImage(#imageLiteral(resourceName: "left-arrow").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
        
    }
    
    func configure() {
        configureUI()
        fetchUserData()
//        fetchDrivers()
    }
    
    func configureUI(){
       configureMapView()
        
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30  ,height: 30)
        
        
        
        configureTableview()
        
    }
    
    func configureLocationInputActivationView(){
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64 )
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
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
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        
        rideActionView.delegate = self
        
        rideActionView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: rideActionViewHeight)
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
    
    
    func dismissLocationView(completion:((Bool)-> Void)? = nil){
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
//            UIView.animate(withDuration: 0.3) {
//                self.inputActivationView.alpha = 1
//                }
            }, completion: completion)
        }
    
    func animateRideActionView(shouldSHow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user : User? = nil){
       
        let yOrigen = shouldSHow ? self.view.frame.height - self.rideActionViewHeight :
            self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigen
        }
        
        if shouldSHow {
            guard let config = config else {return}
            
            if let user = user {
                rideActionView.user = user
            }
            
            
            if let destination = destination{
                rideActionView.destination = destination
            }
            
     
            rideActionView.config = config
            
        }
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
    
    func generatePolyline(forDestination destination: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        let directionRequest  = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapview.addOverlay(polyline)
            
        }
    }
    
    func removeAnnotationAndOverlays(){
        mapview.annotations.forEach { (annotation) in
            if let annotation = annotation  as? MKPointAnnotation{
                mapview
                    .removeAnnotation(annotation)
            }
        }
        
        if mapview.overlays.count > 0 {
            mapview.removeOverlay(mapview.overlays[0])
        }
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapview.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type: AnnotationType , coordinates :  CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    func zoomForActiveTripe(withDriverUid uid: String){
        var annotations  = [MKAnnotation]()
        
        self.mapview.annotations.forEach { (annotation) in
           
            
            if let anno = annotation as? DriverAnnotation {
                if anno.uid ==  uid{
                    annotations.append(anno)
                }
            }
            
            if let anno = annotation as? MKUserLocation{
                annotations.append(anno)
            }
        }
        
        self.mapview.zoomToFit(annotations: annotations)
    }
    
    
    
}




extension HomeController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        guard user.accountType == .driver else{ return }
        
        guard let location = user.location else{ return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route =  self.route {
            let polyline = route.polyline
            let  lineRender = MKPolylineRenderer(overlay: polyline)
            lineRender.strokeColor = .mainBlue
            lineRender.lineWidth = 3
            return lineRender
        }
        
        return MKOverlayRenderer()
    }
    
}

//MARK: - CLLocationManagerDelegate

extension HomeController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue{
            print("DEBUG: DId start montiring")
        }
        
        if region.identifier == AnnotationType.destination.rawValue{
            
        }
        
    }
   
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        guard let trip = self.trip else {return}
        
        if region.identifier == AnnotationType.pickup.rawValue{
           DriverService.shared.updateTripeState(trip: trip, state: .driverArrived) { (err, ref) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue{
            DriverService.shared.updateTripeState(trip: trip, state: .arrivedAtDestination) { (err, ref) in
                self.rideActionView.config = .endTrip
            }
        }
        
        
       
        
    }
    
    func enableLocationServices(){
        locationManager?.delegate = self
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
        dismissLocationView { _ in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark )
        
         generatePolyline(forDestination: destination)
        
        dismissLocationView { _ in
            self.mapview.addAndSelectAnnotation(forCoordinate: selectedPlacemark.coordinate)
            
            let annotations =  self.mapview.annotations.filter({ !$0.isKind(of: DriverAnnotation.self)})
            
//            self.mapview.showAnnotations(annotations, animated: true)
            self.mapview.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldSHow: true, destination: selectedPlacemark, config: .requestRide)
            
            
            
        }
    }
}

extension HomeController: RideActionViewDelegate {
    
    
    func pickupPassenger() {
        starTrip()
    }
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate  else {return}
        guard let destinationCoordinates = view.destination?.coordinate else {return}
        
        shouldPresentLoadingView(true, message: "Buscando conductor")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let  error = error {
                print("debug: \(error.localizedDescription)")
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
        }
    }
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
            
            self.centerMapOnUserLocation()
            
            self.animateRideActionView(shouldSHow: false)
            self.removeAnnotationAndOverlays()
            self.actionButton.setImage(#imageLiteral(resourceName: "hamburguer").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showManu
            
            
            self.inputActivationView.alpha = 1
        }
    }
    func dropOffPassenger() {
        guard  let trip = self.trip else {
            return
        }
        DriverService.shared.updateTripeState(trip: trip, state: .completed) { (err, ref) in
            self.removeAnnotationAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldSHow: false)
        }
    }
    

}

extension HomeController: PickupControllerDelegate{
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        
        self.mapview.addAndSelectAnnotation(forCoordinate: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placmark =  MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placmark)
        generatePolyline(forDestination: mapItem)
        
        mapview.zoomToFit(annotations: mapview.annotations)
        
    
        observeCancelledTrip(trip: trip)
        
        self.dismiss(animated: true) {
            
            Service.shared.fetchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldSHow: true,config: .tripAccepted,user: passenger)
            
            }
            
            
        }
    }
    
    
}
