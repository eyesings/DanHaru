//
//  UserViewModel.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/29.
//

import Foundation


/// 유저 회원가입 뷰모델
class UserJoinViewModel {
    
    init(_ email: String, _ id: String, _ pw: String) {
        var param: [String:Any] = [:]
        param["email"] = email
        param["id"] = id
        param["pw"] = pw
        ViewModelService.userJoinService(param) {
            let _ = UserInfoViewModel(id, pw)
        }
    }
}

/// 유저 입력 값 유효 체크
class UserInfoValidCheckViewModel {
    
    static func checkIsValid(_ str: String, _ inputType: InputType, _ emailAddress: String = "", validCheckHandler: @escaping (Bool) -> Void) {
        var param: [String:Any] = [:]
        param["id"] = inputType == .id ? str : ""
        param["email"] = inputType == .email ? str : emailAddress
        param["pw"] = ""
        
        ViewModelService.userInputValidValueService(param, inputType) { validCheckHandler($0) }
        
    }
}

/// 유저 정보 뷰모델
class UserInfoViewModel {
    var model: UserInfoModel = UserInfoModel()
    
    init(_ id: String, _ pw: String) {
        ViewModelService.userInfoService(id, pw) { infoDic in
            if let dic = infoDic
            {
                do {
                    self.model = try JSONDecoder().decode(UserInfoModel.self,
                                                          from: JSONSerialization.data(withJSONObject: dic))
                }
                catch {
                    Dprint(error)
                    
                    self.model.mem_id = dic["mem_id"] as? String
                    self.model.mem_email = dic["mem_email"] as? String
                    self.model.profile_nm = dic["profile_nm"] as? String
                    self.model.profile_img = dic["profile_img"] as? String
                    self.model.profile_into = dic["profile_into"] as? String
                    
                    
                }
                
                UserModel = self.model
                NotificationCenter.default.post(name: Configs.NotificationName.userLoginSuccess, object: nil)
            }
        }
    }
}
