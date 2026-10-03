//
//  ApiClientTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas unitarias del cliente HTTP: URL, parámetros y mensajes de error.
//  Requisito: RF-05 Listado de personajes.
//

import XCTest
@testable import HelloWorld

final class ApiClientTests: QATestCase {

    private let api = ApiService.shared

    func test_PU_API_01_urlDePersonajesSeConstruyeCorrectamente() {
        XCTAssertEqual(BaseUrl.getBaseUrl(), "https://swapi.info/api/")
        XCTAssertEqual(BaseUrl.getUrl(with: .GET_POKEMONS), "https://swapi.info/api/people")
    }

    func test_PU_API_02_escapeCodificaCaracteresReservados() {
        // Se codifican espacio, & y =; "/" y "?" se dejan igual.
        XCTAssertEqual(api.escape("a b&c=d/e?f"), "a%20b%26c%3Dd/e?f")
        XCTAssertEqual(api.escape("ñ"), "%C3%B1")
    }

    func test_PU_API_03_queryOrdenaLlavesAlfabeticamente() {
        let query = api.query(["b": 2, "a": "x y"])
        XCTAssertEqual(query, "a=x%20y&b=2")
    }

    func test_PU_API_04_queryCodificaBooleanosYNumeros() {
        XCTAssertEqual(api.query(["flag": true]), "flag=true")
        XCTAssertEqual(api.query(["page": 5]), "page=5")
    }

    func test_PU_API_05_queryCodificaArreglos() {
        XCTAssertEqual(api.query(["ids": [1, 2]]), "ids%5B%5D=1&ids%5B%5D=2")
    }

    func test_PU_API_06_queryCodificaDiccionariosAnidados() {
        XCTAssertEqual(api.query(["f": ["x": 1]]), "f%5Bx%5D=1")
    }

    func test_PU_API_07_erroresDeRedTienenDescripcion() {
        let errores: [NetworkingError] = [.customError(msg: "Personalizado"), .generalError, .invalidURL,
                                          .timeOut, .connectionLost, .httpResponseError, .serverError]
        for error in errores {
            let text = error.errorDescription ?? ""
            XCTAssertFalse(text.isEmpty, "\(error) no tiene descripción")
        }
        XCTAssertEqual(NetworkingError.customError(msg: "Personalizado").errorDescription, "Personalizado")
    }
}
