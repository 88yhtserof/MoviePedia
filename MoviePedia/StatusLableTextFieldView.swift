//
//  StatusLableTextFieldView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class StatusLableTextFieldView: UIView {
    
    let textField = BottomLineTextFieldView()
    private let statusLabel = UILabel()
    
    var statusText: String? {
        didSet {
            statusLabel.text = statusText
        }
    }
    
    init(statusText: String? = nil) {
        self.statusText = statusText
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
        statusLabel.textColor = .moviepedia_point
        statusLabel.font = .systemFont(ofSize: 12, weight: .light)
        statusLabel.text = statusText
    }
    
    private func configureHierarchy() {
        addSubviews(textField, statusLabel)
    }
    
    private func configureConstraints() {
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }
}
