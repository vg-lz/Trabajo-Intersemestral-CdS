//
//  ListRepository.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// DESCRIPCIÓN: Repositorio (actor) que encapsula llamadas al API para personajes.
// Define protocolo ListRepositoryProtocol para testing/mocking.
//
// FUNCIONES:
// - getPokemons(): GET "people" sin params -> [Pokemon]. Usa ApiService.shared.
// - getPokemons(_:): Ejemplo con params dinámicos -> String (template).
//
// NOTAS:
// - Es `actor`: las llamadas concurrentes se serializan (thread-safe).

protocol ListRepositoryProtocol {
    func getPokemons() async throws -> [GetPokemon.Pokemon]
    func getPokemons(_ request: [String:Any]) async throws -> String
}

actor ListRepository: ListRepositoryProtocol {
    
    func getPokemons() async throws -> [GetPokemon.Pokemon] {
        
        // Se construye el modelo de la petición para consultar los pokemones
        let request = ApiRequestModel(
            endpoint: .GET_POKEMONS,
            method: .get,
            header: .Authorization,
            encoding: .url,
            parameters: nil
        )
        
        // Se realiza la petición al servicio API y se decodifica al modelo GetPokemon
        //Inicio nuevo
        let response = try await ApiService.shared.request(
            request,
            [GetPokemon.Pokemon].self
        )
        //Termina nuevo
        
        // Se retorna la lista de resultados o un arreglo vacío si no existen datos
        //Inicio nuevo
        return response
        //Termina nuevo
    }
    
    func getPokemons(_ request: [String:Any]) async throws -> String {
        
        // Se construye la petición utilizando parámetros enviados dinámicamente
        let request = ApiRequestModel(
            endpoint: .GET_POKEMONS,
            method: .get,
            header: .Authorization,
            encoding: .url,
            parameters: request
        )
        
        // Se realiza la petición esperando una respuesta tipo String
        let response = try await ApiService.shared.request(
            request,
            String.self
        )
        
        // Se retorna la respuesta obtenida
        return response
    }

    
}
