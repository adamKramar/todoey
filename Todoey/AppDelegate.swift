//
//  AppDelegate.swift
//  Destini
//
//  Created by Adam Kramar on 21/03/2020.
//  Copyright (c) 2020 Adam Kramar. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        do {
            _ = try Realm()
        } catch {
            print("Error init realm: \(error)")
        }
        return true
    }
}

