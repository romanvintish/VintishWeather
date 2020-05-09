//
//  AppDelegate.swift
//  VintishYalantisWeather
//
//  Created by Roman Vintish on 07.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let weatherViewController = WeatherViewController(nibName: String(describing: WeatherViewController.self), bundle: nil)
        
        setRootViewController(weatherViewController)
        
        return true
    }

    func setRootViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            viewController.view.frame = UIScreen.main.bounds
            viewController.view.bounds = UIScreen.main.bounds
            
            if self?.window == nil {
                self?.window = UIWindow.init(frame: UIScreen.main.bounds)
                self?.window?.frame = UIScreen.main.bounds
                self?.window?.bounds = UIScreen.main.bounds
                self?.window?.makeKeyAndVisible()
            }

            self?.window?.rootViewController = viewController
        }
    }
    
}

