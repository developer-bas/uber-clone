//
//  LocationCell.swift
//  Uber
//
//  Created by PROGRAMAR on 08/10/20.
//

import UIKit

class LocationCell: UITableViewCell {
//    MARK: - Properties
    
    
    private let tittleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "123 Main street"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.text = "123 Main street, Washington, DC"
        return label
    }()
    
//    MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack  = UIStackView(arrangedSubviews: [tittleLabel,addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerY(inView: self,leftAnchor: leftAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    MARK:
}
