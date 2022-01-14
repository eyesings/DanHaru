//
//  ViewController.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/25.
//

import UIKit
import Lottie
import SnapKit
import SkeletonView
import AVFAudio
import AVFoundation

class MainViewController: UIViewController, UITextFieldDelegate,CustomToolBarDelegate {
    
    var dateLabel = UILabel()
    let calendarAnimation = AnimationView()
    
    let calendarShowHideBtn = UIButton()
    let calendarView = UIView()
    var calendar = CalendarView()
    let todoListTableView = UITableView()
    var cautionView = UIView()
    
    var networkView: NetworkErrorView!
    
    var todoListModel: TodoListViewModel!
    
    var selectedDate: String = ""
    var selectedIdxPath: IndexPath!
    var invitedTodoIdx: Int?
    var openDetailTotoIdx: Int?
    var invitedFriendId: String?
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 캘린더 화면 노출 여부
    var calendarShowOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestTodoList),
                                               name: Configs.NotificationName.userLoginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.doneSetTodoListModel(_:)),
                                               name: Configs.NotificationName.todoListFetchDone, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestTodoList),
                                               name: Configs.NotificationName.todoListCreateNew, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUserInfo),
                                               name: Configs.NotificationName.reloadAfterLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inviteChallFromFriend(_:)),
                                               name: Configs.NotificationName.inviteFriendChall, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openAppFromWidget(_:)),
                                               name: Configs.NotificationName.openAppFromWidget, object: nil)
        
        self.setUI()
        networkView = NetworkErrorView.shared
        networkView.delegate = self
        
        if let _ = UserDefaults.shared.string(forKey: Configs.UserDefaultsKey.userInputID),
           let _ = UserDefaults.shared.string(forKey: Configs.UserDefaultsKey.userInputPW) {
            self.apiService(withType: .UserLogin)
            todoListTableView.showAnimatedGradientSkeleton()
        }
        
        selectedDate = DateFormatter().korDateString()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let toolBar = self.navigationController?.toolbar as? CustomToolBar {
            toolBar.customDelegate = self
            toolBar.setSelectMenu(.home)
        }
        
        calendarAnimation.animation = .named(calendarShowOn ? "up-arrows" : "down-arrows")
        calendarAnimation.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.calendar.setDisplayDate(Date())
    }
    
    func ToolBarSelected(_ button: UIButton) {
        // 바텀 체크...
        if  button.tag == ToolBarBtnTag.myPage.rawValue {
            let myPageSB = RadHelper.getVCFromMyPageSB(withID: RadHelper.isLogin() ? StoryBoardRef.myPageVC : StoryBoardRef.noneLoginMyPageVC)
            self.navigationController?.pushViewController(myPageSB, animated: true)
        }
        
    }
    
    @objc func requestTodoList(_ noti: NSNotification) {
        guard let isSuccess = noti.object as? Bool else { return }
        if isSuccess {
            splashViewRemove()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.apiService(withType: .TodoList)
            }
        }
    }
    
    @objc func doneSetTodoListModel(_ noti: NSNotification) {
        self.todoListTableView.reloadData()
        self.todoListTableView.hideSkeleton()
        
        if let isSuccess = noti.object as? Bool {
            self.showNoneListView(isSuccess)
        }
        
        
        guard let rootVC = RadHelper.getRootViewController() else { return }
        rootVC.hideLoadingView()
        
        if let _ = self.openDetailTotoIdx {
            self.apiService(withType: .TodoDetail)
            self.openDetailTotoIdx = nil
        }
    }
    
    @objc func reloadUserInfo() {
        self.todoListModel = nil
        self.todoListTableView.reloadData()
        let tempID = RadHelper.tempraryID
        _ = UserJoinViewModel.init("\(tempID)@danharu.com", tempID, "1", errHandler: { print("error Occur \($0)") })
    }
    
    @objc
    func splashViewRemove() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0) {
                self.appDelegate.splashView.alpha = 0.0
            } completion: { _ in
                self.appDelegate.splashView.removeFromSuperview()
            }
        }
    }
}


extension MainViewController: NetworkErrorViewDelegate {
    func isNeedRetryService(_ type: APIType) {
        self.apiService(withType: type)
    }
    
    func apiService(withType type: APIType) {
        
        func showNetworkErrView(type: APIType) {
            self.networkView.showNetworkView()
            self.networkView.needRetryType = type
        }
        
        if type == .UserLogin
        {
            _ = UserInfoViewModel.init(UserDefaults.userInputId, UserDefaults.userInputPw) { showNetworkErrView(type: $0) }
        }
        else if type == .TodoList
        {
            todoListModel = TodoListViewModel.init(searchDate: selectedDate) { showNetworkErrView(type: $0) }
            todoListTableView.reloadData()
        }
        else if type == .TodoDetail {
            var todoModelId: Int!
            
            if let selectIdx = self.selectedIdxPath,
               let todoIdxFromIndexPath = self.todoListModel.model[selectIdx.row].todo_id {
                todoModelId = todoIdxFromIndexPath
            } else if let todoIdxFromInvite = self.invitedTodoIdx {
                todoModelId = todoIdxFromInvite
            } else if let todoIdxFormNoti = self.openDetailTotoIdx {
                todoModelId = todoIdxFormNoti
            } else {
                Dprint("model get Error")
                return
            }
            
            let detailVC = TodoListDetailViewController()
            detailVC.modalPresentationStyle = .fullScreen
            
            func presentDetailVC() {
                self.navigationController?.pushViewController(detailVC)
                self.invitedFriendId = nil
                self.invitedTodoIdx = nil
            }
            
            if let _ = self.invitedFriendId {
                detailVC.invitedMemId = self.invitedFriendId
                detailVC.isForInviteFriend = true
            }
            //FIXME: - 디테일 뷰 조회 및 인증 파일 함수 구현중
            let _ = TodoDetailViewModel(todoModelId, selectedDate) { model in
                if model.use_yn?.lowercased() == "n" {
                    RadAlertViewController.alertControllerShow(WithTitle: RadMessage.title,
                                                               message: RadMessage.AlertView.useNTodoChallenge,
                                                               isNeedCancel: false,
                                                               viewController: self)
                    RadHelper.getRootViewController()?.hideLoadingView()
                    return
                }
                // FIXME: 오늘이, EndDate보다 뒤 인 경우에만 등록 가능
                detailVC.detailInfoModel = model
                detailVC.selectedDay = self.selectedDate

                for model in model.challenge_user! {
                    if model.mem_id == UserModel.memberId {
                        detailVC.isForInviteFriend = false
                        detailVC.invitedMemId = nil
                    }
                }
                
                if let list = model.certification_list {
                    if list.count > 0 {
                        
                        self.getCertificateFiles(list) { dic in
                            if let images = dic["images"] as? [UIImage] {
                                // 이미지 파일이 존재시
                                if images.count > 0 { detailVC.isRegisterAuth = true; detailVC.aleadyRegisterAuth = true }
                                detailVC.selectedImage = images
                                DispatchQueue.main.async {
                                    presentDetailVC()
                                }
                                
                            } else if let voice = dic["voice"] {
                                // 보이스
                                DispatchQueue.main.async {
                                    presentDetailVC()
                                }
                                
                            } else {
                                // 사진, 보이스 가 아닌 경우
                                if let check = dic["check"] as? String {
                                    // 단순 체크
                                    if check.lowercased().contains("y") {
                                        detailVC.isRegisterAuth = true
                                        detailVC.aleadyRegisterAuth = true
                                    }
                                    
                                    DispatchQueue.main.async {
                                        presentDetailVC()
                                    }
                                    
                                } else if let certi = dic["certi"] as? String {
                                    // 인증 내역에 자기꺼가 없을 때
                                    DispatchQueue.main.async {
                                        presentDetailVC()
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                    } else {
                        DispatchQueue.main.async {
                            presentDetailVC()
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        presentDetailVC()
                    }
                }
                
            } errHandler: { showNetworkErrView(type: $0) }
            
        }
    }
    
    /// 인증 파일 가져오는 함수
    func getCertificateFiles(_ list:[ChallengeCertiModel], handler: @escaping(_ dic: NSDictionary) -> Void) {
        var checkArray: Array<Int> = []
        for i in 0 ..< list.count {
            
            if UserModel.memberId == list[i].mem_id {
                if let certiImageString = list[i].certi_img {
                    // 인증 이미지 존재시
                    var certiImages: [UIImage] = []
                    
                    let certiStrArr = certiImageString.components(separatedBy: ",")
                    for q in 0 ..< certiStrArr.count {
                        
                        RadServerNetwork.getFromServerNeedAuth(url: Configs.API.getCertiImg + "/\(certiStrArr[q].trimmingCharacters(in: .whitespacesAndNewlines))") { dic in
                            if let certiImage = dic?["image"] {
                                certiImages.append(certiImage as! UIImage)
                                
                                if q + 1 == certiStrArr.count {
                                    /// 불러온 이미지 갯수랑 이미지 파일 이름 갯수가 같으면
                                    if certiImages.count != q + 1 { // 이미지 불러오기 딜레이 되는 경우
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            
                                            let dic: NSDictionary = [
                                                "images":certiImages
                                            ]
                                            
                                            handler(dic)
                                        }
                                    } else {
                                        
                                        let dic: NSDictionary = [
                                            "images":certiImages
                                        ]
                                    
                                        handler(dic)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } errorHandler: { error in
                            print("image called failed")
                        }
                        
                        
                    }
                    
                    
                } else if let certiVoiceString = list[i].certi_voice {
                    // 인증 보이스 파일 이름 존재시
                    /*
                    RadServerNetwork.getFromServerNeedAuth(url: Configs.API.getCertiImg + "/\(certiVoiceString)") { dic in
                        
                        if let data = dic?["data"] as? Data {
                            do {
                                
                                let player = try AVAudioPlayer(data: data)
                                player.prepareToPlay()
                                player.volume = 1.0
                                player.play()
                                
                            } catch {
                                print("failed to player create \(error)")
                            }
                            
                        }
                        
                        
                    } errorHandler: { error in
                        print("audio api called failed \(error)")
                    }
                    */
                    
                    
                } else {
                    // 단순인증
                    let dic: NSDictionary = [
                        "check":"Y"
                    ]
                    handler(dic)
                }
                
                
                
                
            } else {
                // 인증한 내역이 없을 때
                checkArray.append(i)
                
                if checkArray.count == list.count {
                    let dic: NSDictionary = [
                        "certi":"N"
                    ]
                    
                    handler(dic)
                }
                
            }
            
        }
        
        
    }
    
}
