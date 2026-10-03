//
//  SwapiIntegrationTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas de integración con SWAPI (https://swapi.info). Necesitan internet.
//  Requisitos: RF-05 Listado, RF-07 Detalle, RNF-02 Velocidad,
//  RNF-05 Manejo de errores.
//

import XCTest
@testable import HelloWorld

final class SwapiIntegrationTests: QATestCase {

    private struct Planet: Decodable { let name: String? }

    func test_PI_API_01_repositorioObtienePersonajes() async throws {
        let list = try await ListRepository().getPokemons()
        XCTAssertGreaterThan(list.count, 0)
        XCTAssertTrue(list.contains { $0.name == "Luke Skywalker" })
        print("PI-API-01 personajes recibidos: \(list.count)")
    }

    func test_PI_API_02_cadaPersonajeTieneUrlUnica() async throws {
        // Los favoritos usan la url como identificador (FavoritesViewController.isFavorite)
        let list = try await ListRepository().getPokemons()
        let urls = list.compactMap { $0.url }
        XCTAssertEqual(urls.count, list.count, "Hay personajes sin url")
        XCTAssertEqual(Set(urls).count, urls.count, "Hay urls duplicadas")
    }

    func test_PI_API_03_camposQueLaAppMuestraVienenPoblados() async throws {
        let list = try await ListRepository().getPokemons()
        for p in list {
            XCTAssertFalse((p.name ?? "").isEmpty, "Personaje sin nombre: \(p.url ?? "-")")
            XCTAssertNotNil(URL(string: p.homeworld ?? ""), "homeworld inválido en \(p.name ?? "-")")
        }
    }

    func test_PI_API_04_planetaNatalDeLukeEsTatooine() async throws {
        let list = try await ListRepository().getPokemons()
        let luke = try XCTUnwrap(list.first { $0.name == "Luke Skywalker" })
        let url = try XCTUnwrap(URL(string: luke.homeworld ?? ""))
        let (data, _) = try await URLSession.shared.data(from: url)
        XCTAssertEqual(try JSONDecoder().decode(Planet.self, from: data).name, "Tatooine")
    }

    func test_PI_API_05_tiempoDeRespuestaMenorA3Segundos() async throws {
        let start = Date()
        _ = try await ListRepository().getPokemons()
        let elapsed = Date().timeIntervalSince(start)
        print(String(format: "PI-API-05 tiempo de respuesta: %.3f s", elapsed))
        XCTAssertLessThan(elapsed, 3.0, "RNF-02: la lista debe cargar en menos de 3 s")
    }

    func test_PI_API_06_listViewModelCargaDatos() async throws {
        let vm = ListViewModel()
        try await vm.getPokemonList()
        XCTAssertTrue(vm.hasContent)
    }

    func test_PI_API_07_respuestaConFormatoInesperadoLanzaErrorControlado() async {
        // La raíz del API no devuelve un arreglo de personajes: la app debe fallar de forma controlada.
        let request = ApiRequestModel(endpoint: .VALIDATE_USER, method: .get, header: .noHeader,
                                      encoding: .url, parameters: nil)
        do {
            _ = try await ApiService.shared.request(request, [GetPokemon.Pokemon].self)
            XCTFail("Se esperaba un error")
        } catch let error as NetworkingError {
            print("PI-API-07 error recibido: \(error.localizedDescription)")
        } catch {
            XCTFail("Error no controlado: \(error)")
        }
    }
}
