//
//  AppDelegate.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/6/22.
//

import UIKit
import CoreData
import GiphyUISDK
import OneSignal
import RevenueCat
import AVFoundation
import Nuke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
      
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Task {
            Giphy.configure(apiKey: GiphyKeys.apiKey)
            Purchases.configure(withAPIKey: RevenueCatKeyProvider.apiKey)
        }
        
        ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
          
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(OneSignalKeyProvider.appId)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

