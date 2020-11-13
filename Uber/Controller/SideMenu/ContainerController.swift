//
//  ContainerController.swift
//  Uber
//
//  Created by PROGRAMAR on 12/11/20.
//

import UIKit

class ContainerController: UIViewController{
//    MARK: - Properties
    
    private let homeController = HomeController()
    private var menuController = MenuController()
    var isExpanded = false
    
//    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeController()
        configureMenuController()
    }
//    MARK: - Selectors
//    MARK: - Helper Functions
    
    func configureHomeController(){
        
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
    }
    
    func configureMenuController (){
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
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
