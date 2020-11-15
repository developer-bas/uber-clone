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
    private var menuController: MenuController!
    var isExpanded = false
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80
    
    
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
      checkIfUserIsLoggedIn()
        
       
    }
    
    override var prefersStatusBarHidden: Bool{
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
//    MARK: - Selectors
    @objc func dismissMenu(){
        isExpanded = false
        aniateMenu(shouldExpand: isExpanded)
    }
    
//    MARK: - API
    
    func checkIfUserIsLoggedIn(){
        if  Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else{
           configure()
        }
        
        
    }
    
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
    func signOut(){
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
//    MARK: - Helper Functions
    func configure(){
        configureHomeController()
        view.backgroundColor = .backgroundColor
        fetchUserData()
    }
    
    func configureHomeController(){
        
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
        
    }
     
    func configureMenuController (withUser user: User){
     
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlackView()

    }
    
    
    func configureBlackView (){
        
        
            self.blackView.frame = CGRect(x: xOrigin,
                                          y: 0,
                                          width: 80,
                                          height: self.view.frame.height)
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.alpha = 0
            view.addSubview(blackView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
            blackView.addGestureRecognizer(tap)
        
        
    }
    
    func aniateMenu(shouldExpand: Bool,completion: ((Bool)->Void)? = nil ){
        
        
        
        if shouldExpand {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)

    
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.blackView.alpha = 0
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
       animateStatusBar()
        
    }
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
}

extension ContainerController : HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded.toggle()
        aniateMenu(shouldExpand: isExpanded)
    }
    
    
}

extension ContainerController : MenuControllerDelegate{
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        aniateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            
            case .youTrips:
                break
            case .setting:
                break
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
}
