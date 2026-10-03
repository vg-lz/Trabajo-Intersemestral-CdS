//
//  LoginViewModelTests.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//  Pruebas unitarias de MainViewModel (login) y HomeViewModel. Requisito: RF-03.
//

import XCTest
@testable import HelloWorld

final class LoginViewModelTests: QATestCase {

    private func makeViewModel(user: String, password: String) -> MainViewModel {
        let vm = MainViewModel()
        vm.user.userName = user
        vm.user.password = password
        vm.validateForm()
        return vm
    }

    func test_PU_LOG_01_camposVaciosMuestranErroresYDeshabilitan() {
        let vm = makeViewModel(user: "", password: "")
        XCTAssertEqual(vm.userNameError, "Please enter a username")
        XCTAssertEqual(vm.passwordError, "Please enter a valid password")
        XCTAssertFalse(vm.isValidForm)
    }

    func test_PU_LOG_02_soloUsuarioNoHabilitaLogin() {
        let vm = makeViewModel(user: "qauser", password: "")
        XCTAssertEqual(vm.userNameError, "")
        XCTAssertEqual(vm.passwordError, "Please enter a valid password")
        XCTAssertFalse(vm.isValidForm)
    }

    func test_PU_LOG_03_usuarioYContrasenaHabilitanLogin() {
        let vm = makeViewModel(user: "qauser", password: "Qa123456")
        XCTAssertEqual(vm.userNameError, "")
        XCTAssertEqual(vm.passwordError, "")
        XCTAssertTrue(vm.isValidForm)
    }

    func test_PU_LOG_04_homeViewModelExponeNombreDelUsuario() {
        var user = User()
        user.name = "Diego"
        let vm = HomeViewModel(model: HomeModel(user: user))
        XCTAssertEqual(vm.name, "Diego")
        vm.user.name = "Otro"
        XCTAssertEqual(vm.name, "Otro", "El setter de user actualiza el modelo")
    }
}
