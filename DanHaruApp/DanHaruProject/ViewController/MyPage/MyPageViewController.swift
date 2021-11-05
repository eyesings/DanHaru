//
//  MyPageViewController.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/29.
//

import Foundation
import UIKit


class MyPageViewController: UIViewController {
    
    @IBOutlet var scrollTopViewHeightConst: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var profileImgView: UIImageView!
    @IBOutlet var profileUserName: UILabel!
    @IBOutlet var profileUserIntroduce: UILabel!
    
    @IBOutlet var userScoreView: UIView!
    @IBOutlet var toDoScoreView: UIView!
    @IBOutlet var challengeScoreView: UIView!
    @IBOutlet var totalScoreView: UIView!
    
    @IBOutlet var snapShotUnderView: UIView!
    
    
    private var totalCtn: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageLayoutInit()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = CGSize(width: screenwidth, height: screenheight + 20)
        scrollTopViewHeightConst.constant = screenheight
    }
    
    
    // MARK: - OBJC Method
    @IBAction func onTapMoveToProfileEdit(_ sender: UIButton) {
        if let profileEditVC = RadHelper.getVCFromMyPageSB(withID: StoryBoardRef.profileVC) as? ProfileEditViewController {
            
            self.navigationController?.pushViewController(profileEditVC)
        }
    }
    
    @IBAction func onTapSaveProfileBtn(_ sender: UIButton) {
        let absolutePosition = snapShotUnderView.convert(snapShotUnderView.bounds, to: nil)
        if let image = self.view.takeScreenShot(absolutePosition.maxY - snapShotUnderView.frame.height) {
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        }
        
    }
    
    
    @IBAction func onTapMoveToChallenge(_ sender: UIButton) {
        if let challangeVC = RadHelper.getVCFromMyPageSB(withID: StoryBoardRef.myChallangeVC) as? MyChallengeListViewController {
            
            self.navigationController?.pushViewController(challangeVC)
        }
    }
    
    @IBAction func onTapMoveToSetting(_ sender: UIButton) {
        if let settingVC = RadHelper.getVCFromMyPageSB(withID: StoryBoardRef.settingVC) as? SettingViewController {
            
            self.navigationController?.pushViewController(settingVC)
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)  {
        
        func showToasPopup(_ str: String) {
            DispatchQueue.main.async {
                let warning = WarningView.shared
                warning.message = str
                warning.showAndAutoHide()
            }
        }
        
        if let error = error {
            print("error : \(error)")
            showToasPopup("내 도전 현황 저장에 실패 하였습니다.")
        } else {
            showToasPopup("내 도전 현황 저장에 성공 하였습니다.")
        }
    }
    
}

// MARK: - CustomToolBarDelegate
extension MyPageViewController: CustomToolBarDelegate {
    func ToolBarSelected(_ button: UIButton) {
        if button.tag == ToolBarBtnTag.home.rawValue {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIView Init
extension MyPageViewController {
    
    private func pageLayoutInit() {
        profileImgView.layer.cornerRadius = profileImgView.frame.height / 2
        profileImgView.backgroundColor = .clear
        profileImgView.image = RadHelper.getProfileImage() ?? #imageLiteral(resourceName: "profileNon")
        profileUserName.text = UserModel.nickName ?? (UserModel.userIdx ?? "유저 이름")
        profileUserIntroduce.text = UserModel.profileIntro ?? "단 하루라도 열심히 살자"
        
        userScoreViewLayerInit()
        
        let totalCnt = CGFloat(UserModel.totalCnt ?? 99)
        let todoCnt = CGFloat(UserModel.todoCnt ?? 35)
        let challangeCnt = CGFloat(UserModel.challangeCnt ?? 20)
        let doneCnt = todoCnt + challangeCnt
        
        totalCtn = totalCnt
        
        pieChartViewInit(todoCnt, toDoScoreView)
        pieChartViewInit(challangeCnt, challengeScoreView)
        pieChartViewInit(doneCnt, totalScoreView)
        
        if let toolBar = self.navigationController?.toolbar as? CustomToolBar {
            toolBar.customDelegate = self
            toolBar.setSelectMenu(.myPage)
        }
    }
    
    private func userScoreViewLayerInit() {
        userScoreView.layer.cornerRadius = 15
        
        userScoreView.createShadow(CGSize(width: 0, height: 10))
        
        userScoreView.layer.masksToBounds = false
    }
    
    private func pieChartViewInit(_ doneCnt: CGFloat, _ onView: UIView) {
        
        let pieChartView = PieChartView(frame: CGRect(origin: .zero, size: onView.frame.size))
        let pieChartVal = doneCnt / totalCtn
        
        if pieChartVal > 1.0 {
            pieChartView.slices = [Slice(percent: 0.9999, color: .subLightColor)]
            print("값이 1을 넘길수는 없습니다.")
        } else if pieChartVal == 1.0 {
            pieChartView.slices = [Slice(percent: 0.9999, color: .subHeavyColor)]
        } else {
            pieChartView.slices = [Slice(percent: pieChartVal, color: .subHeavyColor),
                                   Slice(percent: 1 - pieChartVal, color: .subLightColor)]
        }
        onView.addSubview(pieChartView)
        pieChartView.animateChart()
        
        let label = UILabel()
        label.text = "\(Int(doneCnt))/\(Int(totalCtn))"
        label.textColor = .customBlackColor
        label.font = .systemFont(ofSize: 15.0)
        pieChartView.addSubview(label)
        
        label.snp.makeConstraints { label in
            label.centerX.centerY.equalTo(pieChartView)
        }
    }
}