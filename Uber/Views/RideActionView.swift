//
//  RideActionView.swift
//  Uber
//
//  Created by PROGRAMAR on 15/10/20.
//

import UIKit
import MapKit


protocol RideActionViewDelegate : class {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
}
enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}



class RideActionView: UIView {

//      MARK: - Properties
    
    var destination: MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    weak  var delegate : RideActionViewDelegate?
    var user: User?  
    
    let titleLabel: UILabel =  {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Test Label"
        label.textAlignment = .center
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "street  name an number"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
       
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = "X"
        label.textColor = .white
        return label
    }()
    
    private let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Uber X"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM RIDE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
//      MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 55, width: 55)
        infoView.layer.cornerRadius = 55 / 2
        
        addSubview(uberInfoLabel)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberInfoLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberInfoLabel.bottomAnchor,left: leftAnchor,right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12,paddingBottom: 12 ,paddingRight: 12, height: 50)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
//    MARK: - Selectors
    
    @objc func actionButtonPressed(){
       
        
        
        switch buttonAction{
        
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: GET DIRECTIONS")
        case .pickup:
            print("DEBUG: pickup")
        case .dropOff:
            print("DEBUG: dropof")
        }
    }
    
//    MARK: - Helper functions
   public func confugureUI(withConfig config : RideActionViewConfiguration){
        switch config {
        
        
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripAccepted:
            guard let user = user else{ return }
            if user.accountType == .passenger{
                
                titleLabel.text =  "En Route To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
               
            }else{
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
            
        case .pickupPassenger:
            
            titleLabel.text = "Llegando por el pasajero"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
            
        case .tripInProgress:
            
            guard let user = user else{ return  }
            if  user.accountType == .driver {
                actionButton.setTitle("Trip in progress ", for: .normal)
                actionButton.isEnabled = false
            }else{
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
                
            }
            
            titleLabel.text = "En camino al destino"
            
        case .endTrip:
            guard let user = user else {return}
            
            if user.accountType == .driver {
                actionButton.setTitle("Llegando al punto", for: .normal)
                actionButton.isEnabled = false
            }else{
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
                
            }
        case .driverArrived:
            print("ARRIVED")
        }
    }

}
