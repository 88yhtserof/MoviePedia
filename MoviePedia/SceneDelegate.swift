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
        
        if UserDefaultsManager.isOnboardingNotNeeded {
            rootViewController = MainViewController()
        } else {
            rootViewController = OnboardingViewController()
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
        
    }
}

