//
//  LocationInputActivationView.swift
//  Uber
//
//  Created by PROGRAMAR on 07/10/20.
//
import UIKit


protocol LocationInputActivationViewDelegate : class {
    func presentLocationInputView()
}

class LocationInputActivationView : UIView {
    
    weak var delegate: LocationInputActivationViewDelegate?
//    MARK :  - Properties
    
    let indicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private let placeholderLabel: UILabel = {
       
        let label = UILabel()
        label.text = "¿A dondé vamos?"
        label.font = UIFont.systemFont(ofSize:  18)
        label.textColor = .darkGray
        return label
        
    }()
    
//    MARK :  - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16 )
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Selectors
    
    @objc  func handleShowLocationInputView(){
        delegate?.presentLocationInputView()
    }
    
    
}


