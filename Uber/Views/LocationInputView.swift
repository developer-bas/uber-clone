//
//  LocationInputView.swift
//  Uber
//
//  Created by PROGRAMAR on 07/10/20.
//

import UIKit

protocol LocationInputViewDelegate: class  {
    func dismissLocationInputView()
    func executeSearch(query: String)
}




class LocationInputView: UIView {

//    MARK: - Properties
    
    var user: User? {
        didSet{
            titleLabel.text = user?.fullname
        }
    }
    
    weak  var delegate : LocationInputViewDelegate?
    
    
    private let backButton: UIButton = {
        let button =  UIButton(type: .system)
        button.setImage( #imageLiteral(resourceName: "left-arrow").withRenderingMode(.alwaysOriginal), for:.normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
   private let titleLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .darkGray
        label.font  = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
   private  let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
   private let linkingview: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndocatorView: UIView =  {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    private lazy var startingLocationTextField: UITextField = {
        let tf  = UITextField()
        tf.placeholder = "Ubicacion  actual"
        tf.backgroundColor = .groupTableViewBackground
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isEnabled = false
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30 , width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Ingresa tu destino"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.delegate = self
        
        
        return tf
    }()
    
    
    
    
//    MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 40, paddingLeft: 12, width: 24,height: 25)
        
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
    

        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 40, paddingRight: 40, height: 30)

        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startingLocationTextField.bottomAnchor,
                                            left: leftAnchor, right: rightAnchor,paddingTop: 12,paddingLeft: 40, paddingRight: 40,height: 30)

        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField,leftAnchor: leftAnchor,paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationIndocatorView)
        destinationIndocatorView.centerY(inView: destinationLocationTextField,leftAnchor: leftAnchor,paddingLeft: 20)
        destinationIndocatorView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingview)
        linkingview.centerX(inView: startLocationIndicatorView)
        linkingview.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndocatorView.topAnchor, paddingTop: 4,paddingBottom: 4,width: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    MARK: - selectors
    @objc func handleBackTapped(){
        delegate?.dismissLocationInputView()
    }

    
}
// MARK: - UITextFieldDelegate

extension LocationInputView : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query =  textField.text  else {return false}
        delegate?.executeSearch(query: query)
        return true
    }
}
