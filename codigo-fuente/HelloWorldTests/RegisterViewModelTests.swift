//
//  RegisterViewModelTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas unitarias del registro: grupos de datos y valores en el límite.
//  Requisito: RF-02 Registro de usuario.
//

import XCTest
@testable import HelloWorld

final class RegisterViewModelTests: QATestCase {

    // Datos correctos por defecto; cada prueba cambia solo el campo que revisa.
    private func makeViewModel(user: String = "tester01",
                               name: String = "Diego",
                               lastName: String = "Vega",
                               password: String = "Abcdefg1",
                               confirm: String? = nil) -> RegisterViewModel {
        let vm = RegisterViewModel()
        vm.user.userName = user
        vm.user.name = name
        vm.user.lastName = lastName
        vm.user.password = password
        vm.user.passwordCorrect = confirm ?? password
        vm.validateForm()
        return vm
    }

    // MARK: - Usuario

    func test_PU_REG_01_usuarioVacioMuestraObligatorio() {
        let vm = makeViewModel(user: "")
        XCTAssertEqual(vm.userNameError, "El usuario es obligatorio")
    }

    func test_PU_REG_02_usuarioDe3CaracteresEsRechazado() {
        let vm = makeViewModel(user: "abc")
        XCTAssertEqual(vm.userNameError, "Debe tener entre 4 y 20 caracteres")
    }

    func test_PU_REG_03_usuarioDe4CaracteresEsAceptado() {
        let vm = makeViewModel(user: "abcd")
        XCTAssertEqual(vm.userNameError, "")
    }

    func test_PU_REG_04_usuarioDe20CaracteresEsAceptado() {
        let vm = makeViewModel(user: "a" + String(repeating: "b", count: 19))
        XCTAssertEqual(vm.userNameError, "")
    }

    func test_PU_REG_05_usuarioDe21CaracteresEsRechazado() {
        let vm = makeViewModel(user: "a" + String(repeating: "b", count: 20))
        XCTAssertEqual(vm.userNameError, "Debe tener entre 4 y 20 caracteres")
    }

    func test_PU_REG_06_usuarioConCaracterEspecialEsRechazado() {
        let vm = makeViewModel(user: "ab_cd")
        XCTAssertEqual(vm.userNameError, "No se permiten espacios ni caracteres especiales")
    }

    func test_PU_REG_07_usuarioQueIniciaConNumeroEsRechazado() {
        let vm = makeViewModel(user: "1abcd")
        XCTAssertEqual(vm.userNameError, "El usuario no puede comenzar con un número")
    }

    func test_PU_REG_08_usuarioConEspacioInicialEsRechazado() {
        // Regla: "No se permiten espacios". El valor se guarda SIN recortar en UserDefaults.
        let vm = makeViewModel(user: " abcd")
        XCTAssertEqual(vm.userNameError, "No se permiten espacios ni caracteres especiales",
                       "Un usuario con espacio inicial pasa la validación y se guarda con el espacio")
    }

    // MARK: - Nombre y apellido

    func test_PU_REG_09_nombreVacioMuestraObligatorio() {
        XCTAssertEqual(makeViewModel(name: "").nameError, "El nombre es obligatorio")
    }

    func test_PU_REG_10_nombreValoresLimite() {
        XCTAssertEqual(makeViewModel(name: "A").nameError, "Debe tener entre 2 y 30 caracteres", "1 carácter")
        XCTAssertEqual(makeViewModel(name: "Al").nameError, "", "2 caracteres")
        XCTAssertEqual(makeViewModel(name: String(repeating: "a", count: 30)).nameError, "", "30 caracteres")
        XCTAssertEqual(makeViewModel(name: String(repeating: "a", count: 31)).nameError,
                       "Debe tener entre 2 y 30 caracteres", "31 caracteres")
    }

    func test_PU_REG_11_nombreConDigitosEsRechazado() {
        XCTAssertEqual(makeViewModel(name: "Juan2").nameError, "Solo se permiten letras")
    }

    func test_PU_REG_12_nombreConAcentosYEnieEsAceptado() {
        XCTAssertEqual(makeViewModel(name: "José Ñúñez").nameError, "")
    }

    func test_PU_REG_13_apellidoReglasDeValidacion() {
        XCTAssertEqual(makeViewModel(lastName: "").lastNameError, "El apellido es obligatorio")
        XCTAssertEqual(makeViewModel(lastName: "V").lastNameError, "Debe tener entre 2 y 30 caracteres")
        XCTAssertEqual(makeViewModel(lastName: "Vega López").lastNameError, "")
        XCTAssertEqual(makeViewModel(lastName: "Vega#").lastNameError, "Solo se permiten letras")
    }

    // MARK: - Contraseña

    func test_PU_REG_14_contrasenaVaciaMuestraObligatoria() {
        XCTAssertEqual(makeViewModel(password: "", confirm: "").passwordError, "La contraseña es obligatoria")
    }

    func test_PU_REG_15_contrasenaValoresLimite() {
        XCTAssertEqual(makeViewModel(password: "Abcde12").passwordError, "Debe tener al menos 8 caracteres", "7 caracteres")
        XCTAssertEqual(makeViewModel(password: "Abcdef12").passwordError, "", "8 caracteres")
    }

    func test_PU_REG_16_contrasenaConEspacioEsRechazada() {
        XCTAssertEqual(makeViewModel(password: "Abcd 1234").passwordError, "No se permiten espacios")
    }

    func test_PU_REG_17_contrasenaSinComplejidadEsRechazada() {
        let msg = "Debe contener al menos una letra mayúscula, minúscula y un número"
        XCTAssertEqual(makeViewModel(password: "abcdefg1").passwordError, msg, "sin mayúscula")
        XCTAssertEqual(makeViewModel(password: "ABCDEFG1").passwordError, msg, "sin minúscula")
        XCTAssertEqual(makeViewModel(password: "Abcdefgh").passwordError, msg, "sin número")
    }

    func test_PU_REG_18_confirmacionDeContrasena() {
        XCTAssertEqual(makeViewModel(password: "Abcdefg1", confirm: "").confirmPasswordError,
                       "Debes confirmar la contraseña")
        XCTAssertEqual(makeViewModel(password: "Abcdefg1", confirm: "Abcdefg2").confirmPasswordError,
                       "Las contraseñas no coinciden")
        XCTAssertEqual(makeViewModel(password: "Abcdefg1", confirm: "Abcdefg1").confirmPasswordError, "")
    }

    // MARK: - Habilitación del botón (isValidForm), combinaciones

    func test_PU_REG_19_formularioValidoHabilitaRegistro() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.userNameError + vm.nameError + vm.lastNameError + vm.passwordError + vm.confirmPasswordError, "")
        XCTAssertTrue(vm.isValidForm)
    }

    func test_PU_REG_20_usuarioInvalidoNoDebeHabilitarRegistro() {
        let vm = makeViewModel(user: "1ab")
        XCTAssertFalse(vm.userNameError.isEmpty, "Precondición: el campo usuario muestra error")
        XCTAssertFalse(vm.isValidForm, "isValidForm=true aunque el usuario es inválido")
    }

    func test_PU_REG_21_contrasenaDebilNoDebeHabilitarRegistro() {
        let vm = makeViewModel(password: "abc", confirm: "abc")
        XCTAssertFalse(vm.passwordError.isEmpty, "Precondición: el campo contraseña muestra error")
        XCTAssertFalse(vm.isValidForm, "isValidForm=true aunque la contraseña es débil")
    }
}
