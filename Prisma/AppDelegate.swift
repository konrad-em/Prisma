//
//  AppDelegate.swift
//  Prisma
//
//  Created by Konrad Em on 12/03/2019.
//  Copyright © 2019 Perpetuum. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = StyleTransferViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
