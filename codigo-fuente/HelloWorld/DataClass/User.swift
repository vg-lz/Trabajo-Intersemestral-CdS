//
//  User.swift
//  HelloWorld
//
//  Created by Alumnos on 20/03/26.
//

// DESCRIPCIÓN: Modelo local del usuario. Campos para login (userName, password)
// y registro (name, lastName, passwordCorrect). Se persiste en UserDefaults.

import Foundation

struct User {
    var name: String = ""
    var password: String = ""
    var userName: String = ""
    var lastName: String = ""
    var passwordCorrect: String = ""
}
