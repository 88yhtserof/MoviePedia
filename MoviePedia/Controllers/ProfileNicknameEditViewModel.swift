//
//  ProfileNicknameEditViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/8/25.
//

import Foundation

final class ProfileNicknameEditViewModel {
    
    // IN
    let inputViewDidLoad: Observable<Void> = Observable(())
    let inputProfileImageNumber: Observable<Int> = Observable(0)
    
    // OUT
    let outputProfileImageName: Observable<String> = Observable("")
    let outputProfileImageNumber: Observable<Int> = Observable(0)
    
    init() {
        print("ProfileNicknameEditViewModel init")
        
        inputViewDidLoad.lazyBind { [weak self] _ in
            print("inputViewDidLoad bind")
            guard let self else { return }
            let number = (0...11).randomElement()!
            self.outputProfileImageNumber.send(number)
            self.configureProfileImageName(at: number)
        }
        
        inputProfileImageNumber.lazyBind { [weak self] number in
            print("inputProfileImageNumber bind")
            guard let self else { return }
            self.outputProfileImageNumber.send(number)
            self.configureProfileImageName(at: number)
        }
    }
    
    deinit {
        print("ProfileNicknameEditViewModel deinit")
    }
}

private extension ProfileNicknameEditViewModel {
    func configureProfileImageName(at number: Int) {
        let imageName = String(format: "profile_%d", number)
        outputProfileImageName.send(imageName)
    }
}
