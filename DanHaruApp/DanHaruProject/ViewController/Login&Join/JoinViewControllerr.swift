//
//  JoinViewControllerr.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/26.
//

import Foundation
import UIKit

class JoinViewController: UIViewController {
    
    @IBOutlet var preBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var inputTypeLabel: UILabel!
    @IBOutlet var inputTextField: UITextField!
    @IBOutlet var errorInfoMsgLabel: UILabel!
    
    @IBOutlet var topNavView: UIView!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var notchBottomView: UIView!
    
    @IBOutlet var signUpLabel: UILabel!
    @IBOutlet var startBtn: UIButton!
    
    @IBOutlet var stepProgressView: UIView!
    @IBOutlet var stepProgressViewArr: [UIButton]!
    
    @IBOutlet var startBtnBottomConst: NSLayoutConstraint!
    @IBOutlet var progressParentView: NSLayoutConstraint!
    
    public var isFromLoginVC: Bool = false
    
    private var nowInputType: InputType = .email
    
    private var emailInputText: String = ""
    private var idInputText: String = ""
    private var pwInputText: String = ""
    
    private var keyboardH: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.isHidden = true
        inputTextField.makesToCustomField()
        changeTextField(type: .email)
        
        if isFromLoginVC { setLayoutMoveFromLogin() }
        
        self.registerKeyboardNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showWelcomPage), name: Configs.NotificationName.userLoginSuccess, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Configs.NotificationName.userLoginSuccess, object: nil)
    }
    
    /// 로그인 VC에서 넘어온 경우 UI 변경
    func setLayoutMoveFromLogin() {
        preBtn?.isHidden = true
        closeBtn?.isHidden = false
    }
    
    
    // MARK: - OBJC Method
    @IBAction func onTapPreBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapNextBtn(_ sender: UIButton = UIButton()) {
        
        if inputTextField.hasText {
            if nowInputType == .email {
                if inputTextField.isValidEmail() {
                    self.checkIsValidValue()
                } else {
                    print("이메일 형식이 아님")
                    inputTextField.fieldNotHasTextUI()
                    return
                }
            } else if nowInputType == .id {
                self.checkIsValidValue()
            } else if nowInputType == .pw {
                nowInputType = .done
            }
            changeTextField(type: nowInputType)
        } else {
            inputTextField.becomeFirstResponder()
            inputTextField.updateUI()
        }
    }
    
    @IBAction func onTapCloseBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func panEdgeSwipeGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .recognized && nowInputType != .done {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onTapStartBtn(_ sender: UIButton) {
        RadHelper.rootVcChangeToMain()
    }
    
    @IBAction func onTapScreenGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func onTapProgressBtn(_ sender: UIButton) {
        
        if sender.tag > nowInputType.rawValue {
            onTapNextBtn()
        } else {
            if let inputType = InputType.init(rawValue: sender.tag) {
                nowInputType = inputType
                changeTextField(type: nowInputType)
            }
        }
    }
    
    private func userJoin() {
        RadHelper.getRootViewController()?.showLoadingView()
        let _ = UserJoinViewModel.init(emailInputText, idInputText, pwInputText)
    }
    
    @objc private func showWelcomPage() {
        self.nowInputType = .done
        self.showJoinSuccessPage()
    }
}

// MARK: - Private Func
extension JoinViewController {

    private func checkIsValidValue() {
        
        guard let inputText = inputTextField.text else { return }
        // FIXME: Server has character 0. ?
//        UserInfoValidCheckViewModel.checkIsValid(inputText, nowInputType, emailInputText) { isValid in
//            if !isValid {
//                self.errorInfoMsgLabel.isHidden = false
//                self.errorInfoMsgLabel.text = self.nowInputType == .email ? RadMessage.UserJoin.alreadyExistEmail : RadMessage.UserJoin.alreadyExistId
//            } else {
                if self.nowInputType == .email {
                    self.emailInputText = self.inputTextField.text ?? ""
                    self.nowInputType = .id
                } else if self.nowInputType == .id {
                    self.nowInputType = .pw
                    self.idInputText = self.inputTextField.text ?? ""
                }
                
                self.changeTextField(type: self.nowInputType)
//            }
//        }
    }
}

// MARK: - UI Method
extension JoinViewController {
    
    /// 회원가입 절차 Progress 뷰 UI 업데이트
    private func stepViewProgress() {
        for btn in self.stepProgressViewArr
        {
            if let label = btn.titleLabel
            {
                label.textColor = btn.tag == self.nowInputType.rawValue ? .backgroundColor : .subLightColor
            }
            
            btn.backgroundColor = btn.tag == self.nowInputType.rawValue ? .subHeavyColor : .lightGrayColor
            btn.layer.cornerRadius = btn.frame.width / 2
        }
    }
    
    /// 텍스트 필드 UI 변경
    /// - Parameter type: 입력 받을 값
    private func changeTextField(type: InputType) {
        
        startBtn.isHidden = true
        signUpLabel.isHidden = true
        stepProgressView.isHidden = false
        errorInfoMsgLabel.isHidden = true
        
        inputTextField.isSecureTextEntry = (type == .pw)
        inputTextField.keyboardType = .asciiCapable
        inputTextField.placeholder = type.name() + "\(type == .email ? "을 " : "를 ")" + RadMessage.UserJoin.placeHolderInfo
        inputTypeLabel.text = type.name()
        
        switch type {
        case .email:
            inputTextField.keyboardType = .emailAddress
            inputTextField.text = emailInputText
        case .id:
            inputTextField.textContentType = .nickname
            inputTextField.text = idInputText
        case .pw:
            inputTextField.textContentType = .password
            inputTextField.text = nil
        case .done, .introduce, .nickName:
            userJoin()
        }
        
        inputTextField.updateUI(true)
        stepViewProgress()
    }
    
    private func showJoinSuccessPage() {
        inputTypeLabel.isHidden = true
        inputTextField.isHidden = true
        topNavView.isHidden = true
        nextBtn.isHidden = true
        notchBottomView.isHidden = true
        
        startBtn.isHidden = false
        signUpLabel.isHidden = false
        
        startBtn.layer.cornerRadius = startBtn.frame.height / 2
        
        stepProgressView.isHidden = true
        
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.hasText == true {
            onTapNextBtn(UIButton())
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.updateUI()
        
        if nowInputType == .email {
            if let textCnt = textField.text?.count {
                self.errorInfoMsgLabel.text = RadMessage.UserJoin.notValidEmail
                self.errorInfoMsgLabel.isHidden = textCnt > 0 ? textField.isValidEmail() : true
            }
            textField.fieldNotHasTextUI()
            emailInputText = textField.text ?? ""
        } else if nowInputType == .id {
            idInputText = textField.text ?? ""
        } else if nowInputType == .pw {
            pwInputText = textField.text ?? ""
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateUI()
    }
}

// MARK: - Keyboard Protocol
extension JoinViewController: keyboardNotiRegistProtocol {
    func keyboardShowAndHide(_ notification: Notification) {
        RadHelper.keyboardAnimation(notification, startBtnBottomConst) {
            self.view.layoutIfNeeded()
        }
    }
}
