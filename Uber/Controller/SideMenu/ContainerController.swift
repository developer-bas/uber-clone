//
//  ContainerController.swift
//  Uber
//
//  Created by PROGRAMAR on 12/11/20.
//

import UIKit
import Firebase

class ContainerController: UIViewController{
//    MARK: - Properties
    
    private let homeController = HomeController()
    private var menuController = MenuController()
    var isExpanded = false
    
    private var user : User? {
        didSet{
            guard let user = user else  {return}
            
            configureMenuController(withUser: user)
            homeController.user = user
        }
    }
    
//    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configureMenuController()
        configureHomeController()
        view.backgroundColor = .backgroundColor
        fetchUserData()
        
       
    }
//    MARK: - Selectors
    
//    MARK: - API
    
    func fetchUserData(){
        print("DEBUG:  FETCH DATA")
        guard let curretUid = Auth.auth().currentUser?.uid else {
            print("DEBUG: NO USER IN FETCH DATA")
            return
            
        }
        print("DEBUG: AFTER FETCH DATA")
        Service.shared.fetchUserData(uid: curretUid) { user in
            self.user = user
            print("DEBUG: DATA FETCHED ")
        }
    }
    
//    MARK: - Helper Functions
    
    func configureHomeController(){
        
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
        
    }
    
    func configureMenuController (withUser user: User){
     
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.user = user

    }
    
    func aniateMenu(shouldExpand: Bool){
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: nil)
        }
    }
    
}

extension ContainerController : HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded.toggle()
        aniateMenu(shouldExpand: isExpanded)
    }
    
    
}
