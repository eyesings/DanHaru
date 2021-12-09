//
//  UserService.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/12/02.
//

import Foundation
import UIKit


extension ViewModelService {
    
    /// 회원가입
    static func userJoinService(_ param: [String:Any], completionHandler: @escaping () -> Void, errorHandler: @escaping (APIType) -> Void) {
        
        guard let rootVC = RadHelper.getRootViewController() else { print("rootVC 없음"); return }
        
        RadServerNetwork.postDataFromServer(url: Configs.API.join, type: .JSON, parameters: param) { resultDic in
            if let dic = resultDic {
                if let msgStr = dic["msg"] as? String {
                    RadAlertViewController.alertControllerShow(WithTitle: RadMessage.title, message: msgStr, isNeedCancel: false, viewController: rootVC) { if $0 { rootVC.hideLoadingView() } }
                } else {
                    completionHandler()
                    NotificationCenter.default.post(name: Configs.NotificationName.userLoginSuccess, object: true)
                }
            }
        } errorHandler: { err in
            print("error \(err)")
            DispatchQueue.main.async {
                rootVC.hideLoadingView()
                NotificationCenter.default.post(name: Configs.NotificationName.userLoginSuccess, object: false)
            }
        }

        
    }
    
    /// 로그인 유효값 확인
    static func userInputValidValueService(_ param: [String:Any], _ type: InputType, completionHandler: @escaping (Bool) -> Void, errorHandler: @escaping (APIType) -> Void) {
        
        guard let rootVC = RadHelper.getRootViewController() else { print("rootVC 없음"); return }
        
        rootVC.showLoadingView()
        
        var apiUrl = ""
        if type == .email { apiUrl = Configs.API.validEmail }
        else if type == .id { apiUrl = Configs.API.validID }
        
        RadServerNetwork.postDataFromServer(url: apiUrl, type: .JSON, parameters: param) { resultDic in
            
            if let dic = resultDic, let rsltCode = dic["result_code"] as? String, let code = APIResultCode.init(rawValue: rsltCode) {
                
                completionHandler(code == .success)
            }
            rootVC.hideLoadingView()
        } errorHandler: { err in
            Dprint("error \(err)")
            DispatchQueue.main.async {
                rootVC.hideLoadingView()
                errorHandler(.UserValidate)
            }
        }

    }
    
    /// 로그인 및 유저 정보 확인
    static func userInfoService(_ id: String, _ pw: String, completionHandler: @escaping (NSDictionary?) -> Void, errorHandler: @escaping (APIType) -> Void) {
        
        let rootVC = RadHelper.getRootViewController()
        
        func rootVCHideLoadingView() {
            rootVC?.hideLoadingView()
        }
        
        var param: [String:Any] = [:]
        param["id"] = id
        param["pw"] = pw
        
        RadServerNetwork.postDataFromServer(url: Configs.API.login, type: .JSON, parameters: param) { resultDic in
            if let msgStr = resultDic?["msg"] as? String {
                RadAlertViewController.alertControllerShow(WithTitle: RadMessage.title, message: msgStr, isNeedCancel: false, viewController: rootVC ?? UIViewController()) { if $0 { rootVCHideLoadingView() } }
            } else {
                completionHandler(resultDic)
                NotificationCenter.default.post(name: Configs.NotificationName.userLoginSuccess, object: true)
                rootVCHideLoadingView()
            }
        } errorHandler: { err in
            Dprint("error \(err)")
            DispatchQueue.main.async {
                rootVCHideLoadingView()
                errorHandler(.UserLogin)
            }
        }
    }
    
    
    /// 유저 정보 업데이트
    static func userInfoUpdateService(_ name: String = "", _ image: UIImage?, _ intro: String = "", completionHandler: @escaping () -> Void, errorHandler: @escaping (APIType) -> Void) {
        var param: [String:Any] = [:]
        param["profile_nm"] = name
        param["profile_into"] = intro
        param["uploaded_file"] = image
        
        let apiStr = RadHelper.makeString(With: [Configs.API.updateUser, "/\(UserModel.memberId ?? "")", "/\(UserModel.memberEmail ?? "")"])
        
        RadServerNetwork.putDataFromServer(url: apiStr,
                                           parameters: param,
                                           isForUploadImg: true) { resultData in
            
            _ = UserInfoViewModel.init((resultData?["detail"] as? NSDictionary)) {
                completionHandler()
            } errHandler: { errorHandler($0) }
        } errorHandler: { error in
            print("err \(error)")
            errorHandler(.UserUpdate)
        }

    }
    
    /// 유저 할일, 도전, 완료 카운트 서비스
    /// - Parameters:
    ///   - completionHandler: 서버 통신 성공
    ///   - errHandler: 서버 통신 실패
    static func userTodoCntInfoService(completionHandler: @escaping (NSDictionary?) -> Void, errHandler: @escaping (APIType) -> Void) {
        
        var param: [String:Any] = [:]
        param["mem_id"] = UserModel.memberId
        
        let rootVC = RadHelper.getRootViewController()
        rootVC?.showLoadingView()
        
        RadServerNetwork.postDataFromServer(url: Configs.API.getUsrTodo, type: .JSON, parameters: param) { resultData in
            if let resultCode = resultData?["result_code"] as? String,
               resultCode == APIResultCode.success.rawValue {
                completionHandler(resultData?["detail"] as? NSDictionary)
            } else {
                errHandler(.UserTodoCnt)
            }
            rootVC?.hideLoadingView()
        } errorHandler: { err in
            errHandler(.UserTodoCnt)
            rootVC?.hideLoadingView()
        }

    }
}
