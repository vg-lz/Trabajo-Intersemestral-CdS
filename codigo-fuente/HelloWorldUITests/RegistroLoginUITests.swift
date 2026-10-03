//
//  RegistroLoginUITests.swift
//  HelloWorldUITests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas de interfaz de animación de inicio, registro e inicio de sesión.
//

import XCTest

final class RegistroLoginUITests: UITestBase {

    // MARK: - Splash

    func test_PF_SPL_01_splashTransicionaAlLoginEnMenosDe10s() {
        let app = XCUIApplication()
        let start = Date()
        app.launch()
        self.app = app
        XCTAssertTrue(field("Usuario").waitForExistence(timeout: 10), "El login no apareció en 10 s")
        let elapsed = Date().timeIntervalSince(start)
        print(String(format: "PF-SPL-01 tiempo hasta login: %.2f s", elapsed))
        evidence("PF-SPL-01_login_tras_splash")
    }

    // MARK: - Registro

    private func openRegister() {
        app.buttons["¿No tienes cuenta? Regístrate"].tap()
        XCTAssertTrue(field("Nombre(s)").waitForExistence(timeout: 5), "No se abrió la pantalla de registro")
    }

    func test_PF_REG_01_navegarARegistroDesdeLogin() {
        launchApp()
        openRegister()
        XCTAssertTrue(app.navigationBars["Regístrate"].exists)
        evidence("PF-REG-01_pantalla_registro")
    }

    func test_PF_REG_02_botonRegistroDeshabilitadoConFormularioVacio() {
        launchApp()
        openRegister()
        XCTAssertFalse(app.buttons["REGÍSTRATE"].isEnabled)
        evidence("PF-REG-02_boton_deshabilitado")
    }

    func test_PF_REG_03_datosInvalidosMuestranMensajes() {
        launchApp()
        openRegister()
        type("1ab", into: field("Usuario"))
        type("abc", into: secureField("Contraseña"), pressReturn: true)
        XCTAssertTrue(text(containing: "Debe tener entre 4 y 20 caracteres").waitForExistence(timeout: 3))
        XCTAssertTrue(text(containing: "Debe tener al menos 8 caracteres").exists)
        evidence("PF-REG-03_mensajes_validacion")
    }

    func test_PF_REG_04_registroExitosoYLoginConNuevaCuenta() {
        launchApp(withTestUser: false)
        openRegister()
        let user = "qa" + String(Int(Date().timeIntervalSince1970) % 100000)
        type(user, into: field("Usuario"))
        type("Diego", into: field("Nombre(s)"))
        type("Vega", into: field("Apellido(s)"))
        type("Qa123456", into: secureField("Contraseña"))
        type("Qa123456", into: secureField("Confirmar contraseña"), pressReturn: true)
        XCTAssertTrue(app.buttons["REGÍSTRATE"].isEnabled)
        evidence("PF-REG-04_1_formulario_valido")
        app.buttons["REGÍSTRATE"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "No apareció la confirmación de registro")
        evidence("PF-REG-04_2_alerta_registro")
        alert.buttons.firstMatch.tap()
        dismissSavePasswordPrompt(timeout: 3)
        XCTAssertTrue(app.buttons["ENTRAR"].waitForExistence(timeout: 5), "No regresó al login")
        login(user: user, password: "Qa123456")
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "No pudo iniciar sesión con la cuenta nueva")
        dismissSavePasswordPrompt()
        evidence("PF-REG-04_3_home_con_cuenta_nueva")
    }

    func test_PF_REG_05_contrasenaDebilNoDebePermitirRegistro() {
        launchApp()
        openRegister()
        type("qatester", into: field("Usuario"))
        type("Diego", into: field("Nombre(s)"))
        type("Vega", into: field("Apellido(s)"))
        type("abc", into: secureField("Contraseña"))
        type("abc", into: secureField("Confirmar contraseña"), pressReturn: true)
        XCTAssertTrue(text(containing: "Debe tener al menos 8 caracteres").waitForExistence(timeout: 3),
                      "Precondición: se muestra el error de contraseña")
        evidence("PF-REG-05_contrasena_debil")
        XCTAssertFalse(app.buttons["REGÍSTRATE"].isEnabled,
                       "El botón REGÍSTRATE está habilitado con una contraseña que no cumple la política")
    }

    // MARK: - Login

    func test_PF_LOG_01_botonEntrarDeshabilitadoConCamposVacios() {
        launchApp()
        XCTAssertFalse(app.buttons["ENTRAR"].isEnabled)
        evidence("PF-LOG-01_entrar_deshabilitado")
    }

    func test_PF_LOG_02_credencialesInvalidasMuestranError() {
        launchApp()
        login(user: Self.qaUser, password: "Incorrecta1")
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "No se mostró alerta de error")
        XCTAssertFalse(app.tabBars.firstMatch.exists, "No debe entrar al Home")
        evidence("PF-LOG-02_credenciales_invalidas")
    }

    func test_PF_LOG_03_loginExitosoMuestraHomeSinBotonAtras() {
        launchApp()
        login()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        dismissSavePasswordPrompt()
        XCTAssertEqual(app.tabBars.buttons.count, 3)
        XCTAssertTrue(app.tabBars.buttons["Buscar"].exists)
        XCTAssertTrue(app.tabBars.buttons["Favoritos"].exists)
        XCTAssertTrue(app.tabBars.buttons["Perfil"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists, "No debe poder regresar al login")
        evidence("PF-LOG-03_home")
    }

    func test_PF_LOG_04_mensajesDeLoginEnEspanol() {
        launchApp()
        login(user: Self.qaUser, password: "Incorrecta1")
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        evidence("PF-LOG-04_idioma_alerta")
        XCTAssertFalse(alert.staticTexts["Invalid credentials"].exists,
                       "RNF-06: la alerta de error se muestra en inglés ('Invalid credentials')")
    }
}
