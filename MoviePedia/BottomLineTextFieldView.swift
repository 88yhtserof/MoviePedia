//
//  BottomLineTextFieldView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class BottomLineTextFieldView: UIView {
    
    private let textField = UITextField()
    private let lineView = UIView()
    
    var text: String? {
        get {
            textField.text
        } set {
            textField.text = newValue
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
        textField.placeholder = "닉네임을 입력하세요 예) 무피아"
        textField.textColor = .moviepedia_foreground
        textField.borderStyle = .none
        textField.tintColor = .moviepedia_foreground
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        
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

