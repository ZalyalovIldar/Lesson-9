//
//  SceneDelegate.swift
//  Lesson9
//
//  Created by Никита Лужбин on 05.12.2019.
//  Copyright © 2019 Никита. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        DataManager.shared.deleteAllData()
    }
}

