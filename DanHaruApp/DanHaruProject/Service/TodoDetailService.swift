//
//  TodoDetailService.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/12/02.
//

import Foundation



extension ViewModelService {
    
    /// 상세 페이지 데이터 조회
    static func todoDetailDataService(todoIdx: Int, searchDate: String, completionHandler: @escaping (NSDictionary?) -> Void) {
        
        guard let rootVC = RadHelper.getRootViewController() else { Dprint("rootVC 없음"); return }
        rootVC.showLoadingView()
        
        var param: [String:Any] = [:]
        param["todo_id"] = todoIdx
        param["today_dt"] = searchDate
        
        RadServerNetwork.postDataFromServer(url: Configs.API.todoDetail, type: .JSON, parameters: param) { detailData in
            if let resultCode = detailData?["result_code"] as? String,
               resultCode == APIResultCode.success.rawValue {
                guard let detailDataDic = detailData?["detail"] as? NSDictionary else { return }
                completionHandler(detailDataDic)
            } else {
                print("is error")
            }
            
        } errorHandler: { err in
            Dprint("err \(err)")
            DispatchQueue.main.async {
                rootVC.hideLoadingView()
                rootVC.showNetworkErrorView(isNeedRetry: true)
            }
        }

    }
    
    /// 데이터 업데이트
    static func todoDetailUpdteService(param: [String:Any], todoIdx: Int, completionHandler: @escaping (Bool) -> Void) {
        
        guard let rootVC = RadHelper.getRootViewController() else { Dprint("rootVC 없음"); return }
        rootVC.showLoadingView()
        
        RadServerNetwork.putDataFromServer(url: Configs.API.updateDtl + "/\(todoIdx)", parameters: param) { resultData in
            
            if let data = resultData?["result_code"] as? String,
               data == APIResultCode.success.rawValue
            {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            rootVC.hideLoadingView()
        } errorHandler: { error in
            Dprint("error \(error)")
            rootVC.hideLoadingView()
            rootVC.showNetworkErrorView(isNeedRetry: true)
        }

    }
    
    /// 챌린지 유저 등록
    static func todoCreateChaalengeService(todoIdx: Int, ownerMemId: String, completionHandler: @escaping (Bool) -> Void) {
        
        guard let rootVC = RadHelper.getRootViewController() else { Dprint("rootVC 없음"); return }
        rootVC.showLoadingView()
        
        var param: [String:Any] = [:]
        param["todo_id"] = todoIdx
        param["todo_mem_id"] = ownerMemId
        param["chaluser_mem_id"] = UserModel.memberId
        
        RadServerNetwork.postDataFromServer(url: Configs.API.createChl, type: .JSON, parameters: param) { resultDic in
            if let data = resultDic?["result_code"] as? String,
               data == APIResultCode.success.rawValue
            {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            rootVC.hideLoadingView()
        } errorHandler: { err in
            print("error \(err)")
            rootVC.hideLoadingView()
        }

    }
}