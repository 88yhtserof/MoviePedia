//
//  ProfileImageEditViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/7/25.
//

import Foundation
/*
 로직 1) 기존 이미지 전달받아 헤더 이미지에 표시

 로직 2) 프로필 이미지 목록 중 아이템 선택 시 활성화 UI 표시, 나머지 아이템들은 비활성화 UI 사용

 로직 3) 전달 버튼 선택 시 선택된 프로필 이미지 아이템 전달
 */

final class ProfileImageEditViewModel {
    
    // IN
    let inputProfileImageNumber: Observable<Int> = Observable(0)
    
    // OUT
    let outputProfileImageName: Observable<String> = Observable("")
    
    init() {
        print("ProfileImageEditViewModel init")
        
        inputProfileImageNumber.lazyBind { [weak self] number in
            print("inputProfileImageNumber bind")
            guard let self else { return }
            self.configureProfileImageName(at: number)
        }
    }
    
    deinit {
        print("ProfileImageEditViewModel deinit")
    }
}

private extension ProfileImageEditViewModel {
    
    func configureProfileImageName(at profileImageNumber: Int) {
        let profileImageName = String(format: "profile_%d", profileImageNumber)
        self.outputProfileImageName.send(profileImageName)
        // outputProfileImageNamet이 아직 정의되어 있지 않아 value를 보내도 클로저가 응답하지 않음, 따라서 초기값을 가지고 있다가 이후 클로저가 구성되면 호출된다. 따라서 outputProfileImageName는 lazy하게 정의 되면 안 된다.
    }
}
