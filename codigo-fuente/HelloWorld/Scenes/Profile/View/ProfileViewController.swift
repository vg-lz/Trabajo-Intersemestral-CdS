//
//  ProfileViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 27/03/26.
//

// DESCRIPCIÓN: Pantalla de perfil. Muestra foto, stats (likes/vistos) y botones cámara/galería.
// Todo el UI está definido en Main.storyboard. Solo lógica en código.
//
// FUNCIONES:
// - viewDidLoad(): Configura imagen placeholder y colores de borde.
// - viewWillAppear(): Actualiza contadores de likes y vistos.
// - cameraTapped()/galleryTapped(): Abre UIImagePickerController.
//
// NOTAS:
// - Lee FavoritesViewController.favorites.count y CharacterDetailViewController.visitCount.
// - La foto de perfil no se persiste (se pierde al cerrar la app).
// - borderColor se configura en código (CGColor no se puede asignar desde storyboard).

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Componentes visuales
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var likesValueLabel: UILabel!
    @IBOutlet weak var viewsValueLabel: UILabel!
    
    // MARK: - Ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Mi perfil"
        
        // Imagen placeholder inicial
        profileImage.image = UIImage(systemName: "photo")
        
        // borderColor es CGColor, no se puede asignar desde storyboard
        profileImage.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Actualiza los contadores cada vez que se muestra la pantalla
        likesValueLabel.text = "\(FavoritesViewController.favorites.count)"
        viewsValueLabel.text = "\(CharacterDetailViewController.visitCount)"
    }
    
    // MARK: - Acciones
    
    @IBAction func cameraTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func galleryTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Validar que se seleccionó una imagen
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // Cambia la presentación para mostrar la foto seleccionada
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
