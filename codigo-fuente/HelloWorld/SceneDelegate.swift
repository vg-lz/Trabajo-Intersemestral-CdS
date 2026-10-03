//
//  SceneDelegate.swift
//  HelloWorld
//
//  Created by Alumnos on 18/03/26.
//

// DESCRIPCIÓN: Delegado de UIWindowScene. Muestra SplashViewController como pantalla inicial
// con animación Lottie y luego transiciona al flujo principal (Main.storyboard).

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Instancia SplashViewController desde el storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "Splash") as! SplashViewController
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = splashVC
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

}

