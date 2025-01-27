//
//  BottomLineTextFieldView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class BottomLineTextFieldView: UIView {
    
    // TODO: - EditingChanged 동작을 오버라이드하는 방식으로 변경해, textField를 private 처리할 수 있도록 개선하기
    let textField = UITextField()
    private let lineView = UIView()
    
    var text: String? {
        get {
            textField.text
        } set {
            textField.text = newValue
        }
    }
    
    var placeholder: String? {
        get {
            textField.placeholder
        } set {
            textField.placeholder = newValue
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        textField.textColor = .moviepedia_foreground
        textField.borderStyle = .none
        textField.tintColor = .moviepedia_foreground
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(string: "placeholder", attributes: [.foregroundColor: UIColor.moviepedia_subbackground])
        
        lineView.backgroundColor = .moviepediaLightGray
    }
    
    private func configureHierarchy() {
        addSubviews(textField, lineView)
    }
    
    private func configureConstraints() {
        textField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

