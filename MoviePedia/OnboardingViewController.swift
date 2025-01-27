//
//  OnboardingViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class OnboardingViewController: BaseViewController {
    
    private enum LiteralText: String {
        case title = "Onboarding"
        case subtitle = "당신만의 영화 세상,\nMoviePedia를 시작해보세요"
        case buttonTitle = "시작하기"
        
        var text: String {
            return rawValue
        }
    }
    
    private let onboaringImageView = UIImageView()
    private let onboardingTitleLabel = UILabel()
    private let onboardingSubtitleLabel = UILabel()
    private let startButton = BorderLineButton(title: LiteralText.buttonTitle.text)
    private lazy var stackView = UIStackView(arrangedSubviews: [onboardingTitleLabel, onboardingSubtitleLabel, startButton])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    @objc func startButtonDidTapped() {
        let profileNicknameVC = ProfileNicknameEditViewController()
        self.navigationController?.pushViewController(profileNicknameVC, animated: true)
    }
}

//MARK: - Configuration
private extension OnboardingViewController {
    func configureViews() {
        onboaringImageView.image = UIImage(named: "onboarding")
        onboaringImageView.contentMode = .scaleAspectFit
        
        onboardingTitleLabel.text = LiteralText.title.text
        onboardingTitleLabel.textAlignment = .center
        onboardingTitleLabel.textColor = .moviepedia_foreground
        onboardingTitleLabel.font = .systemFont(ofSize: 35, weight: .bold)
        
        
        onboardingSubtitleLabel.text = LiteralText.subtitle.text
        onboardingSubtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        onboardingSubtitleLabel.textColor = .moviepedia_foreground
        onboardingSubtitleLabel.textAlignment = .center
        onboardingSubtitleLabel.numberOfLines = 2
        
        startButton.addTarget(self, action: #selector(startButtonDidTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
    }
    
    func configureHierarchy() {
        view.addSubviews(onboaringImageView, stackView)
    }
    
    func configureConstraints() {
        
        onboaringImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.horizontalEdges.equalToSuperview()
        }
        
        onboardingTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        onboardingSubtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(45)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(onboaringImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

