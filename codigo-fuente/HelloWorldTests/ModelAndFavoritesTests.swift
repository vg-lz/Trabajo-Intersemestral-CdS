//
//  ModelAndFavoritesTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas de los modelos (GetPokemon), ListViewModel y favoritos.
//  Requisitos: RF-05 Listado de personajes, RF-08 Favoritos.
//

import XCTest
@testable import HelloWorld

final class ModelTests: QATestCase {

    private let lukeJSON = """
    {"name":"Luke Skywalker","height":"172","mass":"77","hair_color":"blond","skin_color":"fair",
     "eye_color":"blue","birth_year":"19BBY","gender":"male",
     "homeworld":"https://swapi.info/api/planets/1","url":"https://swapi.info/api/people/1"}
    """

    func test_PU_MOD_01_decodificaPersonajeCompleto() throws {
        let p = try JSONDecoder().decode(GetPokemon.Pokemon.self, from: Data(lukeJSON.utf8))
        XCTAssertEqual(p.name, "Luke Skywalker")
        XCTAssertEqual(p.height, "172")
        XCTAssertEqual(p.mass, "77")
        XCTAssertEqual(p.hair_color, "blond")
        XCTAssertEqual(p.birth_year, "19BBY")
        XCTAssertEqual(p.homeworld, "https://swapi.info/api/planets/1")
        XCTAssertEqual(p.url, "https://swapi.info/api/people/1")
    }

    func test_PU_MOD_02_decodificaPersonajeConCamposFaltantes() throws {
        let p = try JSONDecoder().decode(GetPokemon.Pokemon.self, from: Data(#"{"name":"R2-D2"}"#.utf8))
        XCTAssertEqual(p.name, "R2-D2")
        XCTAssertNil(p.height)
        XCTAssertNil(p.homeworld)
        XCTAssertNil(p.url)
    }

    func test_PU_MOD_03_decodificaArregloDePersonajes() throws {
        let list = try JSONDecoder().decode([GetPokemon.Pokemon].self, from: Data("[\(lukeJSON),\(lukeJSON)]".utf8))
        XCTAssertEqual(list.count, 2)
    }

    func test_PU_MOD_04_listViewModelHasContentReflejaDatos() {
        let vm = ListViewModel()
        XCTAssertFalse(vm.hasContent, "Inicialmente vacío")
        vm.pokemonList = [GetPokemon.Pokemon(name: "Yoda", url: "u/20")]
        XCTAssertTrue(vm.hasContent)
    }
}

final class FavoritesTests: QATestCase {

    private func character(_ name: String, url: String?) -> GetPokemon.Pokemon {
        GetPokemon.Pokemon(name: name, url: url)
    }

    @MainActor private func resetFavorites() {
        FavoritesViewController.favorites = []
    }

    @MainActor func test_PU_FAV_01_toggleAgregaFavorito() {
        resetFavorites()
        let luke = character("Luke Skywalker", url: "https://swapi.info/api/people/1")
        FavoritesViewController.toggle(luke)
        XCTAssertTrue(FavoritesViewController.isFavorite(luke))
        XCTAssertEqual(FavoritesViewController.favorites.count, 1)
    }

    @MainActor func test_PU_FAV_02_toggleDobleEliminaFavorito() {
        resetFavorites()
        let luke = character("Luke Skywalker", url: "https://swapi.info/api/people/1")
        FavoritesViewController.toggle(luke)
        FavoritesViewController.toggle(luke)
        XCTAssertFalse(FavoritesViewController.isFavorite(luke))
        XCTAssertEqual(FavoritesViewController.favorites.count, 0)
    }

    @MainActor func test_PU_FAV_03_identidadDelFavoritoEsLaUrl() {
        resetFavorites()
        FavoritesViewController.toggle(character("Luke Skywalker", url: "https://swapi.info/api/people/1"))
        FavoritesViewController.toggle(character("Leia Organa", url: "https://swapi.info/api/people/5"))
        XCTAssertTrue(FavoritesViewController.isFavorite(character("Luke (otra instancia)", url: "https://swapi.info/api/people/1")))
        XCTAssertEqual(FavoritesViewController.favorites.map { $0.name ?? "" }, ["Luke Skywalker", "Leia Organa"],
                       "Se conserva el orden de inserción")
    }

    @MainActor func test_PU_FAV_04_personajesSinUrlSonIndependientes() {
        resetFavorites()
        // Dos personajes distintos sin url no deberían contar como el mismo favorito.
        let a = character("Personaje A", url: nil)
        let b = character("Personaje B", url: nil)
        FavoritesViewController.toggle(a)
        XCTAssertFalse(FavoritesViewController.isFavorite(b),
                       "Marcar A como favorito marca también a B (ambos url=nil)")
    }
}
