//
//  ProfileImageEditViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/7/25.
//

import Foundation
/*
 로직 1) 기존 이미지 전달받아 헤더 이미지에 표시

 로직 2) 프로필 이미지 목록에서 전달 받은 기존 이미지를 찾아 선택 상태로 설정하기
 
 로직 3) 프로필 이미지 목록 중 아이템 선택 시 활성화 UI 표시, 나머지 아이템들은 비활성화 UI 사용

 로직 4) 전달 버튼 선택 시 선택된 프로필 이미지 아이템 전달
 */

final class ProfileImageEditViewModel: BaseViewModel {
    
    private(set) var input: Input
    private(set) var output: Output
    
    struct Input {
        let profileImageNumber: Observable<Int> = Observable(0)
        let viewDidLoad: Observable<Void> = Observable(())
        let popPreviousVC: Observable<Void> = Observable(())
    }
    
    struct Output {
        let initSelectedProfileImageItem: Observable<Int> = Observable(0)
        let profileImageName: Observable<String> = Observable("")
        let profileImageNumbe: Observable<Int> = Observable(0)
        let sendProfileImageNumber: Observable<Int> = Observable(0)
    }
    
    // DATA
    private var profileImageNumber: Int = 0
    lazy var profileImageNames = (0...11).map({ profileImageName(at: $0) })
    
    init() {
        print("ProfileImageEditViewModel init")
        
        input = Input()
        output = Output()
        
        transform()
    }
    
    func transform() {
        input.profileImageNumber.lazyBind { [weak self] number in
            print("inputProfileImageNumber bind")
            guard let self else { return }
            self.profileImageNumber = number
            self.configureProfileImageName(at: number)
        }
        
        input.viewDidLoad.lazyBind { [weak self] _ in
            print("inputViewDidLoad bind")
            guard let self else { return }
            self.output.initSelectedProfileImageItem.send(self.profileImageNumber)
        }
        
        input.popPreviousVC.lazyBind { [weak self] _ in
            print("inputPopPreviousVC bind")
            guard let self else { return }
            self.output.sendProfileImageNumber.send(self.profileImageNumber)
        }
    }
    
    deinit {
        // 호출이 되고 있지 않음
        print("ProfileImageEditViewModel deinit")
    }
}

private extension ProfileImageEditViewModel {
    
    func profileImageName(at profileImageNumber: Int) -> String {
        return String(format: "profile_%d", profileImageNumber)
    }
    
    func configureProfileImageName(at profileImageNumber: Int) {
        let profileImageName = profileImageName(at: profileImageNumber)
        self.output.profileImageName.send(profileImageName)
        // outputProfileImageNamet이 아직 정의되어 있지 않아 value를 보내도 클로저가 응답하지 않음, 따라서 초기값을 가지고 있다가 이후 클로저가 구성되면 호출된다. 따라서 outputProfileImageName는 lazy하게 정의 되면 안 된다.
        // outputProfileImageNumber도 동일
    }
}
