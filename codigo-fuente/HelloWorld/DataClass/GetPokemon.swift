//
//  GetPokemon.swift
//  HelloWorld
//
//  Created by Diego Vega on 22/04/26.
//

// DESCRIPCIÓN: Modelos Codable para la respuesta de SWAPI.
// GetPokemon = respuesta paginada. Pokemon = personaje individual.
// Todos los campos son opcionales. El nombre "Pokemon" es legacy.
//
// NOTAS:
// - homeworld es una URL; se resuelve con fetch aparte en CharacterDetailVC.
// - Se decodifica como [GetPokemon.Pokemon] directamente en ListRepository.

struct GetPokemon: Codable {
    var count: Double?
    var next: String?
    var previous: String?
    var results: [Pokemon]?
    
    struct Pokemon: Codable {
        var name: String?
        var url: String?
        var height: String?
        var mass: String?
        var hair_color: String?
        var skin_color: String?
        var eye_color: String?
        var birth_year: String?
        var gender: String?
        var homeworld: String?
    }
}
