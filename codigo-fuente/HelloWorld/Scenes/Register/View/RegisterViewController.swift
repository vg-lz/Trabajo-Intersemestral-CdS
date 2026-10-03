//
//  ViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 18/03/26.
//

// DESCRIPCIÓN: Formulario de registro con 5 campos validados con Combine.
// Todos los componentes son genéricos UIKit via IBOutlet (Main.storyboard).
//
// FUNCIONES:
// - viewDidLoad(): Tap-to-dismiss, delegates, 6 suscripciones Combine a errores.
// - popViewController(): Regresa a la pantalla anterior.
// - loginTapped(): Guarda usuario en UserDefaults, muestra alerta de éxito y regresa.
//
// EXTENSION UITextFieldDelegate:
// - textFieldShouldReturn(): Oculta teclado.
// - textField(_:shouldChangeCharactersIn:): Actualiza campo en ViewModel, valida.
// - setErrorBorder(): Borde rojo si hay error.
//
// NOTAS:
// - Persiste userName, name y password en UserDefaults al registrar.

import UIKit
import Combine

class RegisterViewController: UIViewController {
    
    // MARK: - Componenetes visuales
    @IBOutlet weak var tfUser: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblUserError: UILabel!
    @IBOutlet weak var lblNameError: UILabel!
    @IBOutlet weak var lblLastNameError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordConfirmError: UILabel!
    
    // MARK: - Propiedades privadas
    private let viewModel = RegisterViewModel()
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
        
        tfUser.delegate = self
        tfPassword.delegate = self
        tfName.delegate = self
        tfLastName.delegate = self
        tfConfirmPassword.delegate = self
        
        viewModel.$isValidForm
            .sink { [weak self] isValid in
                guard let self else { return }
                self.btnRegister.isEnabled = isValid
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
        
        viewModel.$nameError
            .sink { [weak self] error in
                guard let self else { return }
                let showError = !error.isEmpty
                self.lblNameError.text = error
                self.setErrorBorder(for: tfName, show: showError)
            }
            .store(in: &cancellable)
        
        viewModel.$lastNameError
            .sink { [weak self] error in
                guard let self else { return }
                let showError = !error.isEmpty
                self.lblLastNameError.text = error
                self.setErrorBorder(for: tfLastName, show: showError)
            }
            .store(in: &cancellable)
        
        viewModel.$confirmPasswordError
            .sink { [weak self] error in
                guard let self else { return }
                let showError = !error.isEmpty
                self.lblPasswordConfirmError.text = error
                self.setErrorBorder(for: tfConfirmPassword, show: showError)
            }
            .store(in: &cancellable)
    }
    
    @IBAction func popViewController() {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    @IBAction func loginTapped() {

        let defaults = UserDefaults.standard
        let alert = UIAlertController(title: "Success", message: "User registered successfully", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            self.dismiss(animated: true)
            defaults.set(false, forKey: "isLoggedIn")
            defaults.set(self.viewModel.user.userName, forKey: "userName")
            defaults.set(self.viewModel.user.name, forKey: "name")
            defaults.set(self.viewModel.user.password, forKey: "password")
            
            guard let navigationController = self.navigationController else { return }
            navigationController.popViewController(animated: true)
        })
        
        self.present(alert, animated: true , completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
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
        else if tfName == textField {
            viewModel.user.name = updatedText
        }
        else if tfLastName == textField {
            viewModel.user.lastName = updatedText
        }
        else if tfConfirmPassword == textField {
            viewModel.user.passwordCorrect = updatedText
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
