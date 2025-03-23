//
//  YeonMyuApp.swift
//  YeonMyu
//
//  Created by 박성민 on 3/9/25.
//

import SwiftUI
import UIKit
import Firebase

import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        LocalNotificationManager().requestPermission()
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct YeonMyuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appCoordinator: MainCoordinator = MainCoordinator()
    init() {
        let appearance = UINavigationBarAppearance()
        
        // 뒤로 가기 버튼의 텍스트 제거
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0) // 텍스트 위치를 화면 밖으로 밀어내기
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        // 전체 내비게이션 바 스타일 설정
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        KakaoSDK.initSDK(appKey: APIKey.kakaoKey)
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .onOpenURL { url in //구글 로그인
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onOpenURL { url in //카카오 로그인
                    if (AuthApi.isKakaoTalkLoginUrl(url)) { _ = AuthController.handleOpenUrl(url: url)}
                }
            
        }
    }
}
