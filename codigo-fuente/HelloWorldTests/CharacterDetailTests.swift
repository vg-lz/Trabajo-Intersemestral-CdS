//
//  CharacterDetailTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas del detalle: contador de visitas, tabla y datos que faltan.
//  Requisitos: RF-07 Detalle, RF-09 Perfil (Vistos), RNF-06 Idioma.
//

import XCTest
import UIKit
@testable import HelloWorld

final class CharacterDetailTests: QATestCase {

    @MainActor private func makeDetail(_ character: GetPokemon.Pokemon) -> CharacterDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: CharacterDetailViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "CharacterDetail") as! CharacterDetailViewController
        vc.character = character
        vc.loadViewIfNeeded()
        return vc
    }

    /// Lee texto y valor de una fila tal como la dibuja la tabla (vista alta para que todas las filas sean visibles).
    @MainActor private func value(_ vc: CharacterDetailViewController, section: Int, row: Int) -> (String?, String?) {
        let indexPath = IndexPath(row: row, section: section)
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 2000)
        vc.detailTable.reloadData()
        vc.view.layoutIfNeeded()
        let cell = vc.detailTable.cellForRow(at: indexPath)
            ?? vc.tableView(vc.detailTable, cellForRowAt: indexPath)
        let config = cell.contentConfiguration as? UIListContentConfiguration
        return (config?.text, config?.secondaryText)
    }

    @MainActor func test_PU_DET_01_cadaAperturaIncrementaVisitas() {
        let before = CharacterDetailViewController.visitCount
        _ = makeDetail(GetPokemon.Pokemon(name: "Yoda"))
        _ = makeDetail(GetPokemon.Pokemon(name: "Leia Organa"))
        XCTAssertEqual(CharacterDetailViewController.visitCount, before + 2)
    }

    @MainActor func test_PU_DET_02_estructuraDeSeccionesYFilas() {
        let vc = makeDetail(GetPokemon.Pokemon(name: "Luke Skywalker", height: "172", mass: "77"))
        XCTAssertEqual(vc.title, "Luke Skywalker")
        XCTAssertEqual(vc.numberOfSections(in: vc.detailTable), 2)
        XCTAssertEqual(vc.tableView(vc.detailTable, numberOfRowsInSection: 0), 5)
        XCTAssertEqual(vc.tableView(vc.detailTable, numberOfRowsInSection: 1), 3)
        XCTAssertEqual(value(vc, section: 0, row: 0).0, "Altura")
        XCTAssertEqual(value(vc, section: 0, row: 0).1, "172")
        XCTAssertEqual(value(vc, section: 0, row: 1).1, "77")
    }

    @MainActor func test_PU_DET_03_datosFaltantesSeMuestranComoGuion() {
        let vc = makeDetail(GetPokemon.Pokemon(name: "Desconocido"))
        XCTAssertEqual(value(vc, section: 0, row: 0).1, "-", "Altura sin dato")
        XCTAssertEqual(value(vc, section: 1, row: 0).1, "-", "Año de nacimiento sin dato")
    }

    @MainActor func test_PU_DET_04_encabezadosConOrtografiaCorrecta() {
        let vc = makeDetail(GetPokemon.Pokemon(name: "Luke Skywalker"))
        XCTAssertEqual(vc.tableView(vc.detailTable, titleForHeaderInSection: 0), "Características Físicas")
        XCTAssertEqual(vc.tableView(vc.detailTable, titleForHeaderInSection: 1), "Información General")
    }

    @MainActor func test_PU_DET_05_falloAlCargarPlanetaNoDejaCargandoIndefinido() {
        // Un dominio .invalid nunca existe, así que la petición siempre falla.
        let vc = makeDetail(GetPokemon.Pokemon(name: "Luke Skywalker", homeworld: "https://planeta.invalid/api/planets/1"))
        XCTAssertEqual(value(vc, section: 1, row: 2).1, "Cargando...", "Precondición: estado inicial")
        let wait = expectation(description: "espera de la petición de planeta")
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { wait.fulfill() }
        self.wait(for: [wait], timeout: 10)
        XCTAssertNotEqual(value(vc, section: 1, row: 2).1, "Cargando...",
                          "Tras el fallo de red, 'Planeta natal' sigue en 'Cargando...' sin mensaje de error")
    }
}
