//
//  MenuHeader.swift
//  Uber
//
//  Created by PROGRAMAR on 13/11/20.
//

import UIKit

class MenuHeader: UIView {
//    MARK: - Properties
    
    var user: User?{
        didSet{
            fullName.text = user?.fullname
            emailLabel.text = user?.email
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullName : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Sebas el pro"
        label.backgroundColor = .white
        return label
    }()
    
    private let emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = .lightGray
        label.text = "test@email.com"
        return label
    }()
    
    
//    MARK: - Lifecycle
    override init(frame: CGRect) {
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
