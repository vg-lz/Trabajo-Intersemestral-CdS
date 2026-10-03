//
//  MainViewModel.swift
//  HelloWorld
//
//  Created by Alumnos on 20/03/26.
//

// DESCRIPCIÓN: ViewModel del Registro. Valida 5 campos con Combine.
// Cada campo tiene su @Published de error + isValidForm global.
//
// FUNCIONES:
// - validateForm(): Valida userName (4-20, alfanum, no inicia con número),
//   name/lastName (2-30, solo letras), password (8+, mayúscula+minúscula+número),
//   passwordCorrect (debe coincidir con password).
//
// NOTAS:
// - user: getter/setter al modelo. Se invoca en cada keystroke.

import Combine

class RegisterViewModel {
    var model = RegisterModel()
    
    @Published var isValidForm: Bool = false
    @Published var userNameError: String = ""
    @Published var passwordError: String = ""
    @Published var nameError: String = ""
    @Published var confirmPasswordError: String = ""
    @Published var lastNameError: String = ""

    var user: User {
        get { return model.user }
        set { model.user = newValue }
    }
    
    func validateForm() {
        
        let userClean = user.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nombreClean = user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let apellidoClean = user.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if userClean.isEmpty {
            userNameError = "El usuario es obligatorio"
        } else if userClean.count < 4 || user.userName.count > 20{
            userNameError = "Debe tener entre 4 y 20 caracteres"
        } else if userClean.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) == nil {
            userNameError = "No se permiten espacios ni caracteres especiales"
        } else if let primerCaracter = userClean.first, primerCaracter.isNumber {
            userNameError = "El usuario no puede comenzar con un número"
        } else {
            userNameError = ""
        }
        
        if nombreClean.isEmpty {
            nameError = "El nombre es obligatorio"
        } else if nombreClean.count < 2 || user.name.count > 30 {
            nameError = "Debe tener entre 2 y 30 caracteres"
        } else if nombreClean.range(of: "^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ]+$", options: .regularExpression) == nil {
            nameError = "Solo se permiten letras"
        } else {
            nameError = ""
        }
        
        if apellidoClean.isEmpty {
            lastNameError = "El apellido es obligatorio"
        } else if apellidoClean.count < 2 || user.lastName.count > 30 {
            lastNameError = "Debe tener entre 2 y 30 caracteres"
        } else if apellidoClean.range(of: "^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ]+$", options: .regularExpression) == nil {
            lastNameError = "Solo se permiten letras"
        } else {
            lastNameError = ""
        }
            
        if (user.password.isEmpty){
            passwordError = "La contraseña es obligatoria"
        } else if user.password.count < 8 {
            passwordError = "Debe tener al menos 8 caracteres"
        } else if user.password.contains(" ") {
            passwordError = "No se permiten espacios"
        } else if user.password.range(of: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$", options: .regularExpression) == nil {
            passwordError = "Debe contener al menos una letra mayúscula, minúscula y un número"
        } else {
            passwordError = ""
        }
        
        if user.passwordCorrect.isEmpty {
            confirmPasswordError = "Debes confirmar la contraseña"
        } else if user.password != user.passwordCorrect {
            confirmPasswordError = "Las contraseñas no coinciden"
        } else {
            confirmPasswordError = ""
        }
        
        print("User \(user)")
        isValidForm = !(user.userName.isEmpty || user.password.isEmpty || user.name.isEmpty || user.lastName.isEmpty || user.passwordCorrect.isEmpty || user.password != user.passwordCorrect)
        print("isValid: \(isValidForm)")
    }
    
}
