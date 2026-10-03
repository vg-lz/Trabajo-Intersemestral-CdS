//
//  UITestBase.swift
//  HelloWorldUITests
//
//  Created by Diego Vega on 27/09/26.
//  Funciones comunes de las pruebas de interfaz: abrir la app, iniciar sesión,
//  buscar campos y tomar capturas.
//

import XCTest

@MainActor
class UITestBase: XCTestCase {

    /// Usuario de prueba. Se manda al abrir la app (-userName y -password)
    /// para poder entrar sin registrarse, porque el registro no funciona
    /// (incidencia 17). No borra el usuario guardado en el simulador.
    static let qaUser = "qauser"
    static let qaPassword = "Qa123456"

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        UITestRunLogger.registerOnce()
    }

    // MARK: - Lanzamiento

    @discardableResult
    func launchApp(withTestUser: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        if withTestUser {
            app.launchArguments += ["-userName", Self.qaUser, "-password", Self.qaPassword]
        }
        app.launch()
        self.app = app
        XCTAssertTrue(field("Usuario").waitForExistence(timeout: 15), "El splash no transicionó al login")
        return app
    }

    // MARK: - Búsqueda de elementos

    func field(_ placeholder: String) -> XCUIElement {
        app.textFields.matching(NSPredicate(format: "placeholderValue == %@", placeholder)).firstMatch
    }

    func secureField(_ placeholder: String) -> XCUIElement {
        app.secureTextFields.matching(NSPredicate(format: "placeholderValue == %@", placeholder)).firstMatch
    }

    /// Escribe en un campo y, por defecto, presiona Return para ocultar el teclado
    /// (evita que el teclado tape el siguiente campo).
    func type(_ text: String, into element: XCUIElement, pressReturn: Bool = true) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "No existe el campo \(element)")
        element.tap()
        element.typeText(pressReturn ? text + "\n" : text)
    }

    /// iOS 27 muestra "¿Guardar contraseña?" (Passwords/AutoFill) al salir de una pantalla
    /// con un campo de contraseña. Es un diálogo del sistema, no de la app: se descarta
    /// con "Ahora no" para que no bloquee las interacciones siguientes.
    func dismissSavePasswordPrompt(timeout: TimeInterval = 6) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let labels = ["Ahora no", "Not Now"]
        let end = Date().addingTimeInterval(timeout)
        repeat {
            for root in [app!, springboard] {
                for label in labels where root.buttons[label].exists {
                    root.buttons[label].tap()
                    return
                }
            }
            Thread.sleep(forTimeInterval: 0.3)
        } while Date() < end
    }

    func text(containing value: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", value)).firstMatch
    }

    // MARK: - Flujos

    func login(user: String = qaUser, password: String = qaPassword) {
        type(user, into: field("Usuario"))
        type(password, into: secureField("Contraseña"))
        app.buttons["ENTRAR"].tap()
    }

    func loginAndWaitForList() {
        login()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "No se mostró el Home (TabBar)")
        dismissSavePasswordPrompt()
        XCTAssertTrue(app.tables.cells.firstMatch.waitForExistence(timeout: 30), "La lista no cargó desde SWAPI")
    }

    func cell(named name: String) -> XCUIElement {
        app.tables.cells.containing(NSPredicate(format: "label == %@", name)).firstMatch
    }

    func search(_ text: String) {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText(text)
    }

    /// Valor numérico más cercano (en pantalla) a una etiqueta, p. ej. "Likes" -> "2".
    func numberNear(label: String) -> String? {
        let title = app.staticTexts[label]
        guard title.waitForExistence(timeout: 5) else { return nil }
        let numbers = app.staticTexts.allElementsBoundByIndex.filter { Int($0.label) != nil }
        func distance(_ e: XCUIElement) -> CGFloat {
            abs(e.frame.midX - title.frame.midX) + abs(e.frame.midY - title.frame.midY)
        }
        return numbers.min { distance($0) < distance($1) }?.label
    }

    // MARK: - Evidencias

    func evidence(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
