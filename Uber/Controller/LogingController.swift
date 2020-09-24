//
//  LogingController.swift
//  Uber
//
//  Created by PROGRAMAR on 23/09/20.
//


import  UIKit
class LogingController: UIViewController{
    
        // MARK : - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .white
        return label
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image  = #imageLiteral(resourceName: "email")
        imageView.alpha = 0.87
        view.addSubview(imageView)
        imageView.centerY(inView: view)
        imageView.anchor(left: view.leftAnchor, paddingLeft: 8,width: 24 ,height: 24)
        
        view.addSubview(emailTextField)
        emailTextField.centerY(inView: view)
        emailTextField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor,
                              right: view.rightAnchor,paddingLeft: 8, paddingBottom: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,paddingLeft: 8,height: 0.75)
        
        return view
    }()
    
    private let emailTextField : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        return tf
    }()
    
    
        // MARK : - Lyfecycle
    
 

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
            
            view.addSubview(titleLabel)
            titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor)
            titleLabel.centerX(inView: view)
            
            view.addSubview(emailContainerView)
            emailContainerView.anchor(top:titleLabel.bottomAnchor,left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,paddingRight: 16, height: 50)
            
        }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


}

