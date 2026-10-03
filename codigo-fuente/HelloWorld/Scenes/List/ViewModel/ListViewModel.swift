//
//  ListViewModel.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// DESCRIPCIÓN: ViewModel de la lista de personajes. MVVM + Repository.
// Obtiene datos via ListRepository y los expone al ViewController.
//
// FUNCIONES:
// - getPokemonList(): Solicita personajes al repositorio (async/await).
//
// NOTAS:
// - pokemonList: getter/setter al modelo. hasContent: true si hay datos.
// - repository es `any ListRepositoryProtocol` para facilitar testing.

import Foundation

class ListViewModel {
    
    // MARK: - PRIVATE PROPERTIES
    
    private var model: ListModel
    private let repository: any ListRepositoryProtocol
    
    // MARK: - INIT
    
    init() {
        self.model = ListModel()
        self.repository = ListRepository()
    }
    
    // MARK: - PUBLIC PROPERTIES
    
    var pokemonList: [GetPokemon.Pokemon] {
        get { model.pokemons }
        set { model.pokemons = newValue }
    }
    
    var hasContent: Bool  {
        !pokemonList.isEmpty
    }
    
    func getPokemonList() async throws {
        let response = try await repository.getPokemons()
        pokemonList = response
    }
    
}
