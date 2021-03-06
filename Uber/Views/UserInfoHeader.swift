//
//  UserInfoHeader.swift
//  Uber
//
//  Created by PROGRAMAR on 16/11/20.
//

import UIKit
class UserInfoHeader: UIView {
//    MARK: - Properties
    
    private let user: User
    
    private lazy var profileImageView: UIView = {
        let iv = UIView()
        iv.backgroundColor = .darkGray
        iv.addSubview(initialLabel)
        initialLabel.centerX(inView: iv)
        initialLabel.centerY(inView: iv)
        
        return iv
    }()
    
    
    private lazy var initialLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.text = user.firstInitial
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var fullnameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        
        label.text = "Sebas el capo"
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
       
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "SEBAS@gmail.com"
        label.text = user.fullname
        return label
        
    }()
//    MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self,leftAnchor: leftAnchor,paddingLeft: 16)
        profileImageView.setDimensions(height: 64, width: 64 )
        profileImageView.layer.cornerRadius = 64/2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel,emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor,paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
