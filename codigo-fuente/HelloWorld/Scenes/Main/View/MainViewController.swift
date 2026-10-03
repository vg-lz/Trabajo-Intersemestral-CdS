//
//  ViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 18/03/26.
//

// DESCRIPCIÓN: Pantalla de Login. Valida credenciales vs UserDefaults y soporta Face ID.
// Usa MVVM con Combine: observa isValidForm, userNameError, passwordError del ViewModel.
//
// FUNCIONES:
// - viewDidLoad(): Configura tap-to-dismiss, Face ID gesture, delegates y suscripciones Combine.
// - loginTapped(): Compara credenciales con UserDefaults. Push a Home o muestra alerta de error.
// - faceIDTapped(): Autentica con biométricos (LAContext). Push a Home si exitoso.
//
// EXTENSION UITextFieldDelegate:
// - textFieldShouldReturn(): Oculta teclado con Return.
// - textField(_:shouldChangeCharactersIn:): Captura keystroke, actualiza ViewModel, valida.
// - setErrorBorder(): Aplica/quita borde rojo en text field según error.
//
// NOTAS:
// - Todos los componentes son genéricos UIKit via IBOutlet (Main.storyboard).
// - Navega a HomeViewController instanciando desde storyboard con inyección de ViewModel.

import UIKit
import Combine
import Foundation
import LocalAuthentication

class MainViewController: UIViewController {
    
    // MARK: - Componenetes visuales
    @IBOutlet weak var tfUser: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblUserError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var btnFaceID: UIImageView!
    
    // MARK: - Propiedades privadas
    private let viewModel = MainViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: -  Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(
            target: view,
            action: #selector(UIView.endEditing)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        // Fin ocultar teclado
        
        // BTNFACEID
        let tapFaceID = UITapGestureRecognizer(
            target: self,
            action: #selector(faceIDTapped)
        )
        btnFaceID.addGestureRecognizer(tapFaceID)
        // Fin
        
        tfUser.delegate = self
        tfPassword.delegate = self
        
        
        viewModel.$isValidForm
            .sink { [weak self] isValid in
                guard let self else { return }
                self.btnLogin.isEnabled = isValid
            }
            .store(in: &cancellable)
        
        viewModel.$passwordError
            .sink { [weak self] error in
                guard let self else { return }
                let showError = !error.isEmpty
                self.lblPasswordError.text = error
                self.setErrorBorder(for: tfPassword, show: showError)
            }
            .store(in: &cancellable)
        
        viewModel.$userNameError
            .sink { [weak self] error in
                guard let self else { return }
                let showError = !error.isEmpty
                self.lblUserError.text = error
                self.setErrorBorder(for: tfUser, show: showError)
            }
            .store(in: &cancellable)
    }
    
    
    
    @IBAction func loginTapped() {
        guard let navigationController = navigationController else { return }
        let storyboard = "Main"
        let id = "Home"
        let defaults = UserDefaults.standard
        let userName = defaults.string(forKey: "userName") ?? ""
        let password = defaults.string(forKey: "password") ?? ""
        
        let SecondVC = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(identifier: id) {
            coder in
            self.viewModel.user.name = "Alexander Riggs Zermeño"
            let model = HomeModel(user: self.viewModel.user)
            let viewModel = HomeViewModel(model: model)
            return HomeViewController(coder: coder, viewModel: viewModel) // init()
        }
        
        if viewModel.user.userName == userName && viewModel.user.password == password {
            navigationController.pushViewController(SecondVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Invalid credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc func faceIDTapped() {
        let context = LAContext()
        var error: NSError? = nil
        let canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let defaults = UserDefaults.standard
        guard let navigationController = navigationController else { return }
        let id = "Home"
        let storyboard = "Main"
        let SecondVC = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(identifier: id) {
            coder in
            self.viewModel.user.name = "Alexander Riggs Zermeño"
            let model = HomeModel(user: self.viewModel.user)
            let viewModel = HomeViewModel(model: model)
            return HomeViewController(coder: coder, viewModel: viewModel) // init()
        }
        
        if (canUseBiometrics && defaults.string(forKey: "userName")?.isEmpty == false) {
            let reason = "Authenticate with face ID to access your data"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard self != nil else {return}
                    
                    if success {
                        print("Biometric authentication succesful")
                        navigationController.pushViewController(SecondVC, animated: true)
                    }
                    else if let error = error {
                        print ("Biometric authentication failed with error: \(error.localizedDescription)")
                    }
                    else {
                        print("Biometric authentication was cancelled or failed")
                    }
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Oops...", message: "You can't use this feature", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true)
        }
        
    }
    
    
}

extension MainViewController: UITextFieldDelegate {
    // Ocultar teclado al presionar return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if tfUser == textField {
            viewModel.user.userName = updatedText
        }
        else if tfPassword == textField {
            viewModel.user.password = updatedText
        }
        viewModel.validateForm()
        
        return true
    }
    
    func setErrorBorder(for textField:UITextField, show: Bool) {
        if show {
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        } else {
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0.0
        }
    }
    
}
