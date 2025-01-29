//
//  MainViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    enum Item: String, CaseIterable {
        case cinema = "CINEMA"
        case upcoming = "UPCOMING"
        case profile = "PROFILE"
        
        var title: String {
            return rawValue
        }
        
        var imageName: String {
            switch self {
            case .cinema:
                return "popcorn"
            case .upcoming:
                return "film"
            case .profile:
                return "person.crop.circle"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        configureTabBarAppearance()
    }
}

//MARK: - Configuration
private extension MainTabBarViewController {
    func configureViewControllers() {
        let viewControllers = [
            UINavigationController(rootViewController: CinemaViewController()),
            UINavigationController(rootViewController: UpcomingViewController()),
            UINavigationController(rootViewController: ProfileViewController())
        ]
        
        zip(viewControllers, Item.allCases)
            .forEach{ viewController, item in
                viewController.tabBarItem.title = item.title
                viewController.tabBarItem.image = UIImage(systemName: item.imageName)
                viewController.tabBarItem.selectedImage = UIImage(systemName: item.imageName)
            }
        
        setViewControllers(viewControllers, animated: false)
    }
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = .moviepedia_point
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.moviepedia_point]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .moviepedia_subbackground
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.moviepedia_subbackground]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
