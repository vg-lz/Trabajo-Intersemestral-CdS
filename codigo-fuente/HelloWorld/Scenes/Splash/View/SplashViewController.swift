//
//  SplashViewController.swift
//  HelloWorld
//
//  Created by José De Jesús Vega López on 04/05/26.
//

// DESCRIPCIÓN: Pantalla de splash animada con Lottie (Dancing Ewok).
// UI definida en Main.storyboard (escena "Splash").
// Solo lógica de animación y transición en código.
//
// FUNCIONES:
// - viewDidLoad(): Asigna animación y modo de reproducción.
// - viewDidAppear(): Reproduce la animación.
// - playAnimation(): Reproduce y transiciona al flujo principal al terminar.
// - goToMainApp(): Cambia el rootViewController al flujo de Main.storyboard.

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
    // MARK: - IBOutlets (definidos en Main.storyboard)
    
    // Vista Lottie para la animación del splash
    @IBOutlet weak var animationView: LottieAnimationView!
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Carga la animación por nombre y configura la reproducción
        animationView.animation = LottieAnimation.named("splash_anim")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAnimation()
    }
    
    // MARK: - PRIVATE METHODS
    
    private func playAnimation() {
        animationView.play { [weak self] finished in
            guard finished else { return }
            self?.goToMainApp()
        }
    }
    
    private func goToMainApp() {
        guard let windowScene = view.window?.windowScene,
              let window = windowScene.windows.first else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = mainVC
        }
    }
}
