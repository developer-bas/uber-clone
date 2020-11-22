//
//  PickupController.swift
//  Uber
//
//  Created by PROGRAMAR on 15/10/20.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
//    MARK: - Properties
    private let mapView = MKMapView()
    let trip : Trip
    weak var delegate : PickupControllerDelegate?
    
    private lazy var circularProgressView : CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cpview = CircularProgressView(frame: .zero)
        
        cpview.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268/2
        mapView.centerX(inView: cpview)
        mapView.centerY(inView: cpview, constant: 32)
        return cpview
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Aceptas el siguiente viaje ?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
//    MARK: - Lifecycle
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress),with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
//    MARK: - Selectors
    
    @objc func handleAcceptTrip(){
        DriverService.shared.acceptTrip(trip: trip){ (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc func animateProgress(){
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 5, value: 0) {
            
            DriverService.shared.updateTripeState(trip: self.trip, state: .denied) { (err, ref) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
//    MARK: - API
    
//    MARK: - Helper functions
    
    
    func configureMapView(){
        
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: false)
       
        mapView.addAndSelectAnnotation(forCoordinate: trip.pickupCoordinates)
    }
    
    func configureUI(){
        
        view.backgroundColor = .backgroundColor
       
       
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor,left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32,height: 50)
    }
}
