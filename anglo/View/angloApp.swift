//
//  angloApp.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
}

@main
struct angloApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        let appViewModel = AppViewModel()
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
