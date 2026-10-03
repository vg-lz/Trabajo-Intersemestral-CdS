//
//  ListViewController.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// DESCRIPCIÓN: Lista de personajes de Star Wars con tabla, búsqueda y favoritos.
// Tabla y SearchBar vía IBOutlet (storyboard). Solo lógica en código.
//
// FUNCIONES:
// - configureComponents(): Configura delegate del searchBar, refreshControl y tabla.
// - refresh(): Pull-to-refresh (actualmente limpia lista para demo).
// - getMovieList(): Llama al ViewModel async, recarga tabla o muestra alerta.
// - showAlert(): Presenta UIAlertController genérico.
// - reloadData(): Recarga tabla y muestra emptyLabel si no hay datos.
//
// EXTENSION UITableViewDelegate/DataSource:
// - didSelectRowAt: Push a CharacterDetailViewController.
// - cellForRowAt: Celda genérica con nombre, URL, icono y botón estrella (favorito).
// - favoriteTapped(): Toggle favorito y recarga celda.
//
// EXTENSION UISearchBarDelegate:
// - textDidChange(): Filtra por nombre (case-insensitive).
// - searchBarCancelButtonClicked(): Limpia el filtro.
//
// NOTAS:
// - isSearching: determina si usar filteredList o pokemonList completo.
// - emptyLabel: UILabel genérico como backgroundView de tabla vacía.

import UIKit

class ListViewController: UIViewController {
    
    // MARK: - PUBLIC PROPERTIES
    
    // Instancia del ViewModel encargada de manejar la lógica y los datos
    let viewModel = ListViewModel()
    
    // MARK: - PRIVATE PROPERTIES
    
    // Control utilizado para realizar la acción de "pull to refresh"
    private let refreshControl = UIRefreshControl()
    
    // Lista filtrada que se muestra cuando el usuario está buscando
    private var filteredList: [GetPokemon.Pokemon] = []
    
    // Bandera que indica si actualmente hay una búsqueda activa
    private var isSearching: Bool {
        !(searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - Ui Components
    
    // Tabla principal donde se mostrará la lista de pokemones (IBOutlet del storyboard)
    @IBOutlet weak var listTable: UITableView!
    
    // Buscador definido en el storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Label de estado vacío definido en el storyboard (hidden por defecto)
    @IBOutlet weak var emptyLabel: UILabel!
        
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMovieList()
    }
    
    private func configureComponents() {
        
        // Título de la pantalla
        navigationItem.title = "Explorar Personajes"
        
        // Delegate del buscador (definido en storyboard)
        searchBar.delegate = self
        
        // Texto mostrado al realizar pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        // Se asigna la acción que se ejecutará al refrescar
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        // Se agrega el refresh control a la tabla
        listTable.addSubview(refreshControl)
        
        // Se asignan delegate y datasource de la tabla
        listTable.delegate = self
        listTable.dataSource = self
        
        // Registro de la celda reutilizable con identificador "cell"
        listTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.pokemonList = []
        reloadData()
        refreshControl.endRefreshing()
    }
    
    private func getMovieList() {
        Task {
            do {
                try await viewModel.getPokemonList()
                reloadData()
            }
            catch {
                showAlert(title: "Oops...", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func reloadData() {
        listTable.reloadData()
        let isEmpty = !viewModel.hasContent
        emptyLabel.isHidden = !isEmpty
        listTable.separatorStyle = isEmpty ? .none : .singleLine
    }
}

// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = isSearching ? filteredList[indexPath.row] : viewModel.pokemonList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "CharacterDetail") as! CharacterDetailViewController
        detailVC.character = data
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredList.count : viewModel.pokemonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = isSearching ? filteredList[indexPath.row] : viewModel.pokemonList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = data.name
        content.secondaryText = data.url
        content.image = UIImage(systemName: "person.fill")
        cell.contentConfiguration = content
        
        let favoriteButton = UIButton(type: .system)
        let iconName = FavoritesViewController.isFavorite(data) ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.tag = indexPath.row
        favoriteButton.addTarget(self, action: #selector(favoriteTapped(_:)), for: .touchUpInside)
        cell.accessoryView = favoriteButton
        
        return cell
    }
    
    @objc private func favoriteTapped(_ sender: UIButton) {
        let item = isSearching ? filteredList[sender.tag] : viewModel.pokemonList[sender.tag]
        FavoritesViewController.toggle(item)
        listTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.lowercased()
        filteredList = viewModel.pokemonList.filter {
            ($0.name ?? "").lowercased().contains(text)
        }
        listTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredList = []
        listTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
