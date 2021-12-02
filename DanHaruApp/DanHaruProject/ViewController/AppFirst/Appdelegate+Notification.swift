//
//  Appdelegate+Notification.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/11/30.
//

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //앱이 실행중일때 iOS 10 이상부터
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let pushDic = notification.request.content.userInfo
        Dprint("userNotificationCenter push data = \(pushDic)")
        // FIXME: 작동확인하기
        
        completionHandler([.sound])  //?????... 실행중일땐 alertview를 보여준다?...

    }

    //앱이 백그라운드에 있을때나 시작할때 실행중일때 모두 푸시를 터치하면 실행하는 메서드
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        print("userNotificationCenter didReceive")
        
        let actionId = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        if actionId == UNNotificationDismissActionIdentifier {
            //메세지를 열지않고 지웠을때 호출된다.
            Dprint("UNNotificationDismissActionIdentifier")
            completionHandler()
        }else if actionId == UNNotificationDefaultActionIdentifier {
            //푸시 메세지를 클릭했을때
            Dprint("UNNotificationDefaultActionIdentifier")
            
            completionHandler()
        }
        Dprint("actionId \(actionId)   userinfo  \(userInfo)")
    }
    
}