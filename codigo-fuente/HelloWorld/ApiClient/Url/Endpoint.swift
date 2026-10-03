//
//  Endpoint.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

// DESCRIPCIÓN: Endpoints disponibles del API. rawValue = path relativo a BaseUrl.
//
// NOTAS:
// - GET_POKEMONS = "people" (personajes Star Wars).
// - VALIDATE_USER = "" (placeholder, sin implementar).

import Foundation

enum Endpoint: String {
    case GET_POKEMONS = "people"
    case VALIDATE_USER = ""
}
