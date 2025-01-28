//
//  SceneDelegate.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        var rootViewController: UIViewController
        rootViewController = MainTabBarViewController()
//        if UserDefaultsManager.isOnboardingNotNeeded {
//            rootViewController = MainTabBarViewController()
//        } else {
//            rootViewController = UINavigationController(rootViewController: OnboardingViewController())
//        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
    }
}

