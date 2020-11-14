//
//  MenuController.swift
//  Uber
//
//  Created by PROGRAMAR on 12/11/20.
//
import UIKit

private let  reuseIdentifier = "MenuCell"

class MenuController: UITableViewController{
    
    
//    MARK: - Properties
    var user : User? {
        didSet{
            guard let user = user else{ return }
            menuHeader.user = user
        }
    }
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width - 80,
                           height: 180)
        let view = MenuHeader(frame: frame)
        return view
    }()
    
//    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        configureTableView()
    }
//    MARK: - Selectors
    
//    MARK: - Helper
    func configureTableView(){
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}

extension MenuController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text =  "Menu Option"
        return cell
    }
}
