//
//  Notification.swift
//  musicalRecordProject
//
//  Created by 박성민 on 10/14/24.
//

import Foundation
import UserNotifications

struct Notification {
    var id: String
    var title: String
    var date: Date
}

final class LocalNotificationManager {
    var notifications = [Notification]()
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted == true && error == nil {
                    //we have permission!
                    print("알람 허용함")
                } else {
                    print("알람 허용안함")
                }
            }
    }
    
    func addNotification(title: String, date: String) -> Void {
        let dateFormatter = DateFormatter()
        //2024년 9월 14일
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        let dateType = dateFormatter.date(from: date)!
        
        notifications.append(Notification(id: UUID().uuidString, title: title, date: dateType))
    }
    
    func schedule() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    
    func scheduleNotifications() -> Void {
        for notification in notifications {
            var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.date)
            triggerDate.hour = 8
            triggerDate.minute = 0
            
            
            let content = UNMutableNotificationContent()
            content.title = "🎉예정된 공연일"
            content.sound = UNNotificationSound.default
            content.subtitle = "예정된 \"\(notification.title)\"을 관람하는 날!"
            
            
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("scheduling notification with id:\(notification.id)")
            }
        }
    }
    
    
}
