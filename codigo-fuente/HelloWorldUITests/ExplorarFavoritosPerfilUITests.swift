//
//  ExplorarFavoritosPerfilUITests.swift
//  HelloWorldUITests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas de interfaz de lista, búsqueda, detalle, favoritos y perfil (SWAPI real).
//  Requisitos: RF-05 Listado, RF-06 Búsqueda, RF-07 Detalle, RF-08 Favoritos,
//  RF-09 Perfil, RF-10 Recargar lista, RNF-04 Facilidad de uso, RNF-06 Idioma.
//

import XCTest

final class ExplorarFavoritosPerfilUITests: UITestBase {

    // MARK: - Lista y búsqueda

    func test_PF_LST_01_listaCargaPersonajesDesdeSwapi() {
        launchApp()
        loginAndWaitForList()
        XCTAssertTrue(app.navigationBars["Explorar Personajes"].exists)
        XCTAssertTrue(cell(named: "Luke Skywalker").waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.tables.cells.count, 5)
        evidence("PF-LST-01_lista_personajes")
    }

    func test_PF_LST_02_busquedaFiltraPorNombreSinDistinguirMayusculas() {
        launchApp()
        loginAndWaitForList()
        search("SKY")
        XCTAssertTrue(cell(named: "Luke Skywalker").waitForExistence(timeout: 5))
        XCTAssertTrue(cell(named: "Anakin Skywalker").exists)
        XCTAssertFalse(cell(named: "Leia Organa").exists, "Leia no contiene 'sky'")
        for c in app.tables.cells.allElementsBoundByIndex {
            let names = c.staticTexts.allElementsBoundByIndex.map { $0.label.lowercased() }
            XCTAssertTrue(names.contains { $0.contains("sky") }, "Resultado que no coincide: \(names)")
        }
        evidence("PF-LST-02_busqueda_sky")
    }

    func test_PF_LST_03_busquedaSinResultadosInformaAlUsuario() {
        launchApp()
        loginAndWaitForList()
        search("zzzz")
        sleep(1)
        XCTAssertEqual(app.tables.cells.count, 0)
        evidence("PF-LST-03_busqueda_sin_resultados")
        let message = app.staticTexts.matching(NSPredicate(
            format: "label CONTAINS[c] 'resultado' OR label CONTAINS[c] 'encontr' OR label CONTAINS[c] 'find'")).firstMatch
        XCTAssertTrue(message.exists, "No se informa al usuario que la búsqueda no tuvo resultados")
    }

    private func pullToRefresh() {
        let first = app.tables.cells.firstMatch
        let start = first.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 0, dy: 450))
        start.press(forDuration: 0.1, thenDragTo: end)
        sleep(3)
    }

    func test_PF_LST_04_pullToRefreshRecargaLaLista() {
        launchApp()
        loginAndWaitForList()
        let before = app.tables.cells.count
        pullToRefresh()
        evidence("PF-LST-04_despues_de_refresh")
        XCTAssertGreaterThan(app.tables.cells.count, 0,
                             "Tras 'pull to refresh' la lista queda vacía (antes: \(before) celdas)")
    }

    func test_PF_LST_05_mensajeDeListaVaciaAcordeALaApp() {
        launchApp()
        loginAndWaitForList()
        pullToRefresh()   // único camino reproducible para ver el estado vacío
        let emptyMessage = text(containing: "Oops")
        guard emptyMessage.waitForExistence(timeout: 3) else {
            XCTFail("No se mostró el mensaje de lista vacía")
            return
        }
        evidence("PF-LST-05_mensaje_lista_vacia")
        XCTAssertFalse(emptyMessage.label.lowercased().contains("pokemon"),
                       "El mensaje de estado vacío menciona 'pokemon': \(emptyMessage.label)")
    }

    // MARK: - Detalle

    func test_PF_DET_01_detalleMuestraDatosYPlanetaNatal() {
        launchApp()
        loginAndWaitForList()
        cell(named: "Luke Skywalker").tap()
        XCTAssertTrue(app.navigationBars["Luke Skywalker"].waitForExistence(timeout: 5))
        XCTAssertTrue(text(containing: "Altura").exists)
        XCTAssertTrue(app.staticTexts["172"].exists, "Altura de Luke = 172")
        XCTAssertTrue(app.staticTexts["Tatooine"].waitForExistence(timeout: 10), "No cargó el planeta natal")
        evidence("PF-DET-01_detalle_luke")
    }

    // MARK: - Favoritos

    private func toggleFavorite(_ name: String) {
        let row = cell(named: name)
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No se encontró \(name)")
        row.buttons.firstMatch.tap()
    }

    func test_PF_FAV_01_marcarFavoritoLoAgregaAFavoritos() {
        launchApp()
        loginAndWaitForList()
        toggleFavorite("Luke Skywalker")
        evidence("PF-FAV-01_1_estrella_marcada")
        app.tabBars.buttons["Favoritos"].tap()
        XCTAssertTrue(cell(named: "Luke Skywalker").waitForExistence(timeout: 5))
        XCTAssertEqual(app.tables.cells.count, 1)
        evidence("PF-FAV-01_2_lista_favoritos")
    }

    func test_PF_FAV_02_desmarcarFavoritoLoQuitaDeFavoritos() {
        launchApp()
        loginAndWaitForList()
        toggleFavorite("Luke Skywalker")
        toggleFavorite("Luke Skywalker")
        app.tabBars.buttons["Favoritos"].tap()
        sleep(1)
        XCTAssertFalse(cell(named: "Luke Skywalker").exists)
        XCTAssertEqual(app.tables.cells.count, 0)
        evidence("PF-FAV-02_favoritos_vacio")
    }

    func test_PF_FAV_03_abrirDetalleDesdeFavoritos() {
        launchApp()
        loginAndWaitForList()
        toggleFavorite("Leia Organa")
        app.tabBars.buttons["Favoritos"].tap()
        cell(named: "Leia Organa").tap()
        XCTAssertTrue(app.navigationBars["Leia Organa"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Alderaan"].waitForExistence(timeout: 10))
        evidence("PF-FAV-03_detalle_desde_favoritos")
    }

    // MARK: - Perfil

    func test_PF_PRF_01_perfilMuestraLikesYVistos() {
        launchApp()
        loginAndWaitForList()
        toggleFavorite("Luke Skywalker")
        toggleFavorite("Leia Organa")
        for name in ["Luke Skywalker", "Leia Organa"] {
            cell(named: name).tap()
            XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
            app.navigationBars[name].buttons.firstMatch.tap()   // regresar
            XCTAssertTrue(app.navigationBars["Explorar Personajes"].waitForExistence(timeout: 5))
        }
        app.tabBars.buttons["Perfil"].tap()
        XCTAssertTrue(app.staticTexts["Mi perfil"].waitForExistence(timeout: 5))
        evidence("PF-PRF-01_perfil_contadores")
        XCTAssertEqual(numberNear(label: "Likes"), "2", "Likes = número de favoritos")
        XCTAssertEqual(numberNear(label: "Vistos"), "2", "Vistos = detalles abiertos")
    }

    func test_PF_PRF_02_perfilMuestraBotonesCamaraYGaleria() {
        launchApp()
        loginAndWaitForList()
        app.tabBars.buttons["Perfil"].tap()
        XCTAssertTrue(app.buttons["Cámara"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Galería"].exists)
        evidence("PF-PRF-02_perfil_botones")
    }
}
