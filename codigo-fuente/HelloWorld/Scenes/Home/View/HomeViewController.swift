//
//  HomeViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 23/03/26.
//

// DESCRIPCIÓN: TabBarController principal post-login. 3 pestañas: Buscar, Favoritos, Perfil.
// Se instancia desde Main.storyboard con inyección de HomeViewModel.
//
// FUNCIONES:
// - init?(coder:viewModel:): Init desde storyboard con inyección de dependencia.
// - viewDidLoad(): Oculta botón Back y desactiva swipe-back gesture.
//
// NOTAS:
// - Las tabs se configuran en Main.storyboard via segues de relación.

import UIKit

class HomeViewController: UITabBarController {
    
    // MARK: - Componentes visuales
    private let viewmodel: HomeViewModel
    
    // MARK: - Componentes visuales
    init?(coder: NSCoder, viewModel: HomeViewModel) {
        self.viewmodel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("inir(coder:) has not been implemented")
    }
    
    // MARK: - Componentes visuales
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
