//
//  MainViewModel.swift
//  HelloWorld
//
//  Created by Alumnos on 20/03/26.
//

// DESCRIPCIÓN: ViewModel del Login. Valida usuario/contraseña con Combine.
// @Published: isValidForm (habilita botón), userNameError, passwordError.
//
// FUNCIONES:
// - validateForm(): Valida campos vacíos, actualiza errores e isValidForm.
//
// NOTAS:
// - user: propiedad computada que expone/modifica el User del modelo.
// - Se invoca desde shouldChangeCharactersIn en cada keystroke.

import Combine

class MainViewModel {
    var model = MainModel()
    
    @Published var isValidForm: Bool = false
    @Published var userNameError: String = ""
    @Published var passwordError: String = ""

    var user: User {
        get { return model.user }
        set { model.user = newValue }
    }
    
    func validateForm() {
        if (user.userName.isEmpty){
            userNameError = "Please enter a username"
        } else {
            userNameError = ""
        }
        
        if (user.password.isEmpty){
            passwordError = "Please enter a valid password"
        } else {
            passwordError = ""
        }
        
        print("User \(user)")
        isValidForm = !(user.userName.isEmpty || user.password.isEmpty)
        print("isValid: \(isValidForm)")
    }
    
}
