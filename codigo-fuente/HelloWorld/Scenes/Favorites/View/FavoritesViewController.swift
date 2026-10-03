//
//  FavoritesViewController.swift
//  HelloWorld
//
//  Created by Diego Vega on 29/04/26.
//

// DESCRIPCIÓN: Lista de personajes favoritos. Tabla definida en Main.storyboard.
// Gestiona favoritos via propiedades estáticas (arreglo global en memoria).
//
// FUNCIONES:
// - isFavorite(): Verifica si un personaje está en favoritos (compara por url).
// - toggle(): Agrega o elimina un personaje de la lista.
// - viewDidLoad(): Asigna delegate/dataSource y registra celda.
// - viewWillAppear(): Recarga tabla cada vez que aparece la pestaña.
//
// NOTAS:
// - favorites es static: compartido globalmente. Se pierde al cerrar la app.
// - Navegación a CharacterDetail via storyboard instantiation.

import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - Componentes visuales
    @IBOutlet weak var favoritesTable: UITableView!
    
    // Lista global de personajes marcados como favoritos
    static var favorites: [GetPokemon.Pokemon] = []
    
    // Indica si un personaje se encuentra dentro de los favoritos
    static func isFavorite(_ item: GetPokemon.Pokemon) -> Bool {
        favorites.contains { $0.url == item.url }
    }
    
    // Agrega o elimina un personaje de la lista de favoritos
    static func toggle(_ item: GetPokemon.Pokemon) {
        if let index = favorites.firstIndex(where: { $0.url == item.url }) {
            favorites.remove(at: index)
        } else {
            favorites.append(item)
        }
    }
    
    // MARK: - Ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mis Favoritos"
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresca la tabla cada vez que se muestra la pestaña
        favoritesTable.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FavoritesViewController.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = FavoritesViewController.favorites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = data.name
        content.secondaryText = data.url
        content.image = UIImage(systemName: "star.fill")
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Personaje seleccionado dentro de la lista de favoritos
        let data = FavoritesViewController.favorites[indexPath.row]
        
        // Navega a la pantalla de detalle instanciando desde storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "CharacterDetail") as! CharacterDetailViewController
        detailVC.character = data
        navigationController?.pushViewController(detailVC, animated: true)
        
        // Deselecciona visualmente la fila
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
