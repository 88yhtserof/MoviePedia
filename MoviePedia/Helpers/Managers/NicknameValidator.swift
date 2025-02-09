//
//  NicknameValidator.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

typealias ValidationResult = Result<String, NicknameValidator.ValidationError>

class NicknameValidator {
    private var trimmedNickname: String?
    
    private func validateCount() -> Bool {
        let regex = ".{2,9}"
        return validate(of: regex)
    }
    
    private func validateNumber() -> Bool {
        let regex = "(?=.*[0-9]).{2,9}"
        return validate(of: regex, isMatched: false)
    }
    
    private func validateString() -> Bool {
        let regex = "(?=.*[@#$%]).{2,9}"
        return validate(of: regex, isMatched: false)
    }
    
    private func validate(of regex: String, isMatched: Bool = true) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: trimmedNickname)
        return isMatched ? result : !result
    }
    
    func validateNickname(of nickname: String) throws -> String? {
        trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let trimmedNickname, !trimmedNickname.isEmpty else {
            throw ValidationError.none
        }
        
        guard validateCount() else {
            throw ValidationError.invalidCount
        }
        
        guard validateNumber() else {
            throw ValidationError.usingNumber
        }
        
        guard validateString() else {
            throw ValidationError.usingSpecialCharacter
        }
        
        return trimmedNickname
    }
    
    enum ValidationError: Error {
        case none
        case invalidCount
        case usingNumber
        case usingSpecialCharacter
        
        var description: String {
            switch self {
            case .none:
                return ""
            case .invalidCount:
                return "2글자 이상 10글자 미만으로 설정해주세요"
            case .usingNumber:
                return "닉네임에 숫자는 포함할 수 없어요"
            case .usingSpecialCharacter:
                return "닉네임에 @, #, $, % 는 포함할 수 없어요"
            }
        }
    }
}
