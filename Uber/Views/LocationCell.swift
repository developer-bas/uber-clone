//
//  LocationCell.swift
//  Uber
//
//  Created by PROGRAMAR on 08/10/20.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
//    MARK: - Properties
    
    var placemark: MKPlacemark? {
        didSet{
            tittleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    var type: LocationType?{
        didSet{
            tittleLabel.text = type?.description
            addressLabel.text = type?.subtitle
        }
    }
    
    
    let tittleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        
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
