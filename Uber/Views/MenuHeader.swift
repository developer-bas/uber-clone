//
//  MenuHeader.swift
//  Uber
//
//  Created by PROGRAMAR on 13/11/20.
//

import UIKit

class MenuHeader: UIView {
//    MARK: - Properties
    
//    var user: User?{
//        didSet{
//            fullName.text = user?.fullname
//            emailLabel.text = user?.email
//        }
//    }
//
    
    private let user: User
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private lazy var fullName : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = user.fullname
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = .lightGray
        label.text = user.email
        return label
    }()
    
    
//    MARK: - Lifecycle
    
    init(user: User, frame: CGRect){
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 12,width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        
        
        let stack = UIStackView(arrangedSubviews: [fullName,emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
