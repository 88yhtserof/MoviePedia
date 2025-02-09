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
    let inputEditingChangedNickname: Observable<String?> = Observable(nil)
    let inputNicknameResult: Observable<String?> = Observable(nil)
    let inputMBTIResultValueChaned: Observable<[String]?> = Observable(nil)
    let inputSaveProfileInfo: Observable<Void> = Observable(())
    
    let inputMBTIEneryValueChanged: Observable<String?> = Observable(nil)
    let inputMBTIPerceptionValueChanged: Observable<String?> = Observable(nil)
    let inputMBTIJudgmentValueChanged: Observable<String?> = Observable(nil)
    let inputMBTILifeStyleValueChanged: Observable<String?> = Observable(nil)
    
    // OUT
    let outputProfileImageName: Observable<String> = Observable("")
    let outputProfileImageNumber: Observable<Int> = Observable(0)
    let outputNicknameValidationResult: Observable<ValidationResult> = Observable(.success(""))
    let outputDoneButtonIsEnabled: Observable<Bool> = Observable(false)
    let outProfileInfoSaveResult: Observable<User?> = Observable(nil)
    
    // DATA
    private let nicknameValidator = NicknameValidator()
//    private var nickname: String?
    
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
        
        inputEditingChangedNickname.lazyBind { [weak self] text in
            print("inputEditingChangedNickname bind")
            guard let self else { return }
            self.validateNickname(text)
        }
        
        [ inputMBTIEneryValueChanged,
          inputMBTIPerceptionValueChanged,
          inputMBTIJudgmentValueChanged,
          inputMBTILifeStyleValueChanged ]
            .forEach {
                $0.lazyBind { [weak self] _ in
                    print("inputMBTIXXXValueChaned bind")
                    self?.checkMBTIResult()
                }
            }
        
        inputMBTIResultValueChaned.lazyBind { [weak self] result in
            print("inputMBTIResultValueChanged bind", result)
            self?.checkDoneButtonStatus()
        }
        
        inputNicknameResult.lazyBind { [weak self] result in
            print("inputNicknameResult bind", result)
            self?.checkDoneButtonStatus()
        }
        
        inputSaveProfileInfo.lazyBind { [weak self] _ in
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
        outputProfileImageName.send(imageName)
    }
    
    func validateNickname(_ text: String?) {
        guard let text else { return }
        
        do {
            let nickname = try self.nicknameValidator.validateNickname(of: text)
            self.outputNicknameValidationResult.send(.success("사용할 수 있는 닉네임이에요"))
            self.inputNicknameResult.send(nickname)
            
        } catch let error as NicknameValidator.ValidationError {
            self.outputNicknameValidationResult.send(.failure(error))
            self.inputNicknameResult.send(nil)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func checkMBTIResult() {
        guard let energy = inputMBTIEneryValueChanged.value,
           let perception = inputMBTIPerceptionValueChanged.value,
           let judgment = inputMBTIJudgmentValueChanged.value,
           let lifeStyle = inputMBTILifeStyleValueChanged.value
        else {
            inputMBTIResultValueChaned.send(nil)
            return
        }
        let result = [ energy, perception, judgment, lifeStyle ]
        inputMBTIResultValueChaned.send(result)
    }
    
    func checkDoneButtonStatus() {
        guard inputNicknameResult.value != nil,
              inputMBTIResultValueChaned.value != nil
        else {
            outputDoneButtonIsEnabled.send(false)
            return
        }
        outputDoneButtonIsEnabled.send(true)
    }
    
    private func saveProfileData() {
        guard let nickname = inputNicknameResult.value else { return }
        let profileImageName = outputProfileImageName.value
        let user = User(createdAt: Date(), nickname: nickname, profileImage: profileImageName)
        UserDefaultsManager.user = user
        outProfileInfoSaveResult.send(user)
    }
}
