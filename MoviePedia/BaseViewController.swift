//
//  BaseViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/25/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    lazy var backBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .moviepedia_background
        configureBackBarButton()
    }
    
    @objc func backBarButtonItemDidTapped() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Configuration
private extension BaseViewController {
    func configureBackBarButton() {
        guard self != navigationController?.viewControllers.first else { return }
        
        backBarButtonItem.tintColor = .moviepedia_point
        backBarButtonItem.image = UIImage(systemName: "chevron.left")
        backBarButtonItem.target = self
        backBarButtonItem.action = #selector(backBarButtonItemDidTapped)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
}
