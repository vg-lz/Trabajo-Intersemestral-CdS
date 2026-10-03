//
//  ListModel.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// DESCRIPCIÓN: Modelo de la lista de personajes.
// Almacena el arreglo de personajes y un enum Result para éxito/fallo.

import Foundation

struct ListModel {
    
    var pokemons: [GetPokemon.Pokemon] = []
    
    enum GetPokemons {
        case success(list: [GetPokemon.Pokemon])
        case failure(error: Error)
    }
}
