//
//  UIViewController+.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit

extension UIViewController {
    
    /// Switches the rootViewController of current window.
    func switchRootViewController(rootViewController: UIViewController, isNavigationEmbeded: Bool = false) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        if isNavigationEmbeded {
            window.rootViewController = UINavigationController(rootViewController: rootViewController)
        } else {
            window.rootViewController = rootViewController
        }
        window.makeKeyAndVisible()
    }
}
