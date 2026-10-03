//
//  HomeViewModel.swift
//  HelloWorld
//
//  Created by Alumnos on 23/03/26.
//

// DESCRIPCIÓN: ViewModel del Home. Almacena el usuario autenticado.
// Se inyecta desde MainViewController al navegar post-login.
//
// NOTAS:
// - user: getter/setter al modelo. name: nombre del usuario (solo lectura).

class HomeViewModel {
    
    var model: HomeModel
    
    init(model: HomeModel) {
        self.model = model
    }
    
    var user: User {
        get { model.user }
        set { model.user = newValue }
    }
    
    var name: String {
        user.name
    }
}
