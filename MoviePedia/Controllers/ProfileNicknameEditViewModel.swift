//
//  ProfileNicknameEditViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/8/25.
//

import Foundation

final class ProfileNicknameEditViewModel: BaseViewModel {
    
    private(set) var input: Input
    private(set) var output: Output
    
    struct Input {
        let viewDidLoad: Observable<Void> = Observable(())
        let profileImageNumber: Observable<Int> = Observable(0)
        let editingChangedNickname: Observable<String?> = Observable(nil)
        let nicknameResult: Observable<String?> = Observable(nil)
        let mbtiResultValueChaned: Observable<[String]?> = Observable(nil)
        let saveProfileInfo: Observable<Void> = Observable(())
        
        let mbtiEneryValueChanged: Observable<String?> = Observable(nil)
        let mbtiPerceptionValueChanged: Observable<String?> = Observable(nil)
        let mbtiJudgmentValueChanged: Observable<String?> = Observable(nil)
        let mbtiLifeStyleValueChanged: Observable<String?> = Observable(nil)
    }
    
    struct Output {
        let profileImageName: Observable<String> = Observable("")
        let profileImageNumber: Observable<Int> = Observable(0)
        let nicknameValidationResult: Observable<ValidationResult> = Observable(.success(""))
        let doneButtonIsEnabled: Observable<Bool> = Observable(false)
        let profileInfoSaveResult: Observable<User?> = Observable(nil)
    }
    
    // DATA
    private let nicknameValidator = NicknameValidator()
    
    init() {
        print("ProfileNicknameEditViewModel init")
        
        input = Input()
        output = Output()
        
        transform()
    }
    
    func transform() {
        input.viewDidLoad.lazyBind { [weak self] _ in
            print("inputViewDidLoad bind")
            guard let self else { return }
            let number = (0...11).randomElement()!
            self.output.profileImageNumber.send(number)
            self.configureProfileImageName(at: number)
        }
        
        input.profileImageNumber.lazyBind { [weak self] number in
            print("inputProfileImageNumber bind")
            guard let self else { return }
            self.output.profileImageNumber.send(number)
            self.configureProfileImageName(at: number)
        }
        
        input.editingChangedNickname.lazyBind { [weak self] text in
            print("inputEditingChangedNickname bind")
            guard let self else { return }
            self.validateNickname(text)
        }
        
        [ input.mbtiEneryValueChanged,
          input.mbtiPerceptionValueChanged,
          input.mbtiJudgmentValueChanged,
          input.mbtiLifeStyleValueChanged ]
            .forEach {
                $0.lazyBind { [weak self] _ in
                    print("inputMBTIXXXValueChaned bind")
                    self?.checkMBTIResult()
                }
            }
        
        input.mbtiResultValueChaned.lazyBind { [weak self] result in
            print("inputMBTIResultValueChanged bind", result)
            self?.checkDoneButtonStatus()
        }
        
        input.nicknameResult.lazyBind { [weak self] result in
            print("inputNicknameResult bind", result)
            self?.checkDoneButtonStatus()
        }
        
        input.saveProfileInfo.lazyBind { [weak self] _ in
            print("inputSaveProfileInfo bind")
            self?.saveProfileData()
        }
    }
    
    deinit {
        print("ProfileNicknameEditViewModel deinit")
    }
}

private extension ProfileNicknameEditViewModel {
    
    func configureProfileImageName(at number: Int) {
        let imageName = String(format: "profile_%d", number)
        output.profileImageName.send(imageName)
    }
    
    func validateNickname(_ text: String?) {
        guard let text else { return }
        
        do {
            let nickname = try self.nicknameValidator.validateNickname(of: text)
            self.output.nicknameValidationResult.send(.success("사용할 수 있는 닉네임이에요"))
            self.input.nicknameResult.send(nickname)
            
        } catch let error as NicknameValidator.ValidationError {
            self.output.nicknameValidationResult.send(.failure(error))
            self.input.nicknameResult.send(nil)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func checkMBTIResult() {
        guard let energy = input.mbtiEneryValueChanged.value,
           let perception = input.mbtiPerceptionValueChanged.value,
           let judgment = input.mbtiJudgmentValueChanged.value,
           let lifeStyle = input.mbtiLifeStyleValueChanged.value
        else {
            input.mbtiResultValueChaned.send(nil)
            return
        }
        let result = [ energy, perception, judgment, lifeStyle ]
        input.mbtiResultValueChaned.send(result)
    }
    
    func checkDoneButtonStatus() {
        guard input.nicknameResult.value != nil,
              input.mbtiResultValueChaned.value != nil
        else {
            output.doneButtonIsEnabled.send(false)
            return
        }
        output.doneButtonIsEnabled.send(true)
    }
    
    private func saveProfileData() {
        guard let nickname = input.nicknameResult.value else { return }
        let profileImageName = output.profileImageName.value
        let user = User(createdAt: Date(), nickname: nickname, profileImage: profileImageName)
        UserDefaultsManager.user = user
        output.profileInfoSaveResult.send(user)
    }
}
