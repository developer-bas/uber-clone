//
//  SettingsController.swift
//  Uber
//
//  Created by PROGRAMAR on 16/11/20.
//

import UIKit

private let reuseIdentifier = "LocationCell"

protocol SettingsControllerDelegate: class {
    func updateUser(_ controller: SettingsController)
    
}

enum LocationType: Int, CaseIterable, CustomStringConvertible{
    case home
    case work
    
    var description: String{
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
    
    var subtitle: String{
        switch self {
        case .home:
            return "add home"
        case .work:
            return "add work"
        }
    }
}

class SettingsController: UITableViewController {
    
//    MARK: - Properties
     var user : User
    private let locationManger = LocationHandler.shared.locationManager
    var userInfoUpdated = false
    
    weak var delegate: SettingsControllerDelegate?
    
    private  lazy var infoHeader : UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 140)
        let view = UserInfoHeader(user: user , frame: frame)
        return view
        
    }()
    
//    MARK: - LifeCycle
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        configureNavigationBar()
    }
//    MARK: - Selectors
    @objc func handlerDismissal(){
        
        
        if userInfoUpdated{
            delegate?.updateUser(self)
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
//    MARK:  - Helper functions
    
    func locationType(forType type: LocationType ) -> String {
        switch type {
      
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    
    func configureTableView(){
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handlerDismissal))
    }
    
    
}

//MARK: - UITableViewDelegate
extension SettingsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,for: indexPath) as! LocationCell

        guard let type = LocationType(rawValue: indexPath.row) else {return cell}

        cell.tittleLabel.text = type.description
        cell.addressLabel.text = locationType(forType: type)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else {return}
        guard let location = locationManger?.location  else {return}
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
}

extension SettingsController : AddLocationControllerDelegate{
    func updateLocation(locationString: String, type: LocationType) {
        
        PassengerService.shared.saveLocation(locationStrng: locationString, type: type) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
            
            self.userInfoUpdated = true
            
            switch type{
            
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
        
    }
}
