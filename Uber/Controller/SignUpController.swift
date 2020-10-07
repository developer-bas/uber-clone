//
//  SignUpController.swift
//  Uber
//
//  Created by PROGRAMAR on 29/09/20.
//

import Foundation
import  UIKit
import Firebase

class SingUpController : UIViewController{
    
//    MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .white
        return label
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "email"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullnameContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "user"), textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    
    private lazy var passwordContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "padlock"), textField: passwordTextFiel)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "user"), segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private let emailTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextFiel : UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let fullnameTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Full name", isSecureTextEntry: false)
        
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider"," Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.89)
        sc.selectedSegmentIndex =  0
        return  sc
    }()
    
    private let signUpButton : AuthButton = {
        let button =  AuthButton(type: .system)
        button
            .setTitle("Sign Up ", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    
    let alreadytHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "¿Ya tienes una  cuenta? ",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Ingresa", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.mainBlue]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
//    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
//    MARK: - Selectors
    
   
    
    @objc func handleSignUp(){
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextFiel.text  else { return }
        guard let fullname = fullnameTextField.text else {return}
        
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email,
                          password: password) { (result, error) in
            
            if let error = error {
                print("Error al registrar al usuario \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email":email,
                          "fullname":fullname,
                          "accountType":accountTypeIndex] as [String : Any]
            
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (erro, ref) in
                
                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController
                        else  { return }
                
                controller.configureUI()
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    func configureUI(){
        
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,fullnameContainerView ,passwordContainerView, accountTypeContainerView , signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 40,
                     paddingLeft: 16,
                     paddingRight: 16)

        view.addSubview(alreadytHaveAccountButton)
        alreadytHaveAccountButton.centerX(inView: view)
        alreadytHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
    }
    
    
}

