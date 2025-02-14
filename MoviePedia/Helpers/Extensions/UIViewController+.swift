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
    
    func showAlert(title: String, message: String, Style: UIAlertController.Style, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: Style)
        actions
            .forEach{ alert.addAction($0) }
        present(alert, animated: true)
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "네트워크 오류", message: message, Style: .alert, actions: [
            UIAlertAction(title: "확인", style: .default)
        ])
    }
}
