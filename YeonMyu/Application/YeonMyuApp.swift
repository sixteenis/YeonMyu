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
//        LocalNotificationManager().requestPermission() 알림 현재 없음, 추후 알림 추가시 권한 요청 주석 해제 필요
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct YeonMyuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// 앱 전역 의존성 컨테이너. 단 1개.
    /// → Repository, Logger, GlobalErrorHandler 등 모든 인프라가 여기서 조립됨.
    @State private var container = DIContainer()

    @State var appCoordinator: MainCoordinator = MainCoordinator()

    /// DIContainer 가 만들어 주는 UserUseCase. 기존 코드와 호환 위해 동일 변수명 유지.
    @State private var userUseCase: UserUseCase

    init() {
        // self 가 아직 초기화 안 됐으므로 임시 컨테이너로 UseCase 초기화.
        // (SwiftUI App 의 init 제약을 우회하기 위한 패턴)
        let initialContainer = DIContainer()
        _container = State(initialValue: initialContainer)
        _userUseCase = State(initialValue: initialContainer.makeUserUseCase())

        let appearance = UINavigationBarAppearance()
        
        // 뒤로 가기 버튼 이미지 리사이징
        let originalImage = UIImage.leftTailArrow!
        let targetSize = CGSize(width: 25, height: 25)
        let resizedImage = originalImage.resized(to: targetSize).withTintColor(UIColor(hex: "919193"), renderingMode: .alwaysOriginal)
        
        // 뒤로 가기 버튼 설정
        appearance.setBackIndicatorImage(resizedImage, transitionMaskImage: resizedImage)
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        // 전체 내비게이션 바 스타일 설정
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(hex: "919193")
        UINavigationBar.appearance().prefersLargeTitles = false
        
        KakaoSDK.initSDK(appKey: AppConfig.kakaoAppKey)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.asPurple300)
                .environment(appCoordinator)
                .environment(userUseCase)
                .environment(container)
                .task {
                    // GlobalErrorHandler 가 Coordinator 와 UserUseCase.logout 을 알 수 있도록 연결.
                    // (init 시점엔 둘 다 준비 안 됐으므로 task 에서 한 번)
                    container.wire(coordinator: appCoordinator, userUseCase: userUseCase)
                }
                .onOpenURL { url in //구글 로그인
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onOpenURL { url in //카카오 로그인
                    if (AuthApi.isKakaoTalkLoginUrl(url)) { _ = AuthController.handleOpenUrl(url: url)}
                }

        }
    }
}
