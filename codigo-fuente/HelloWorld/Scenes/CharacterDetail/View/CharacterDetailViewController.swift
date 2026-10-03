//
//  CharacterDetailViewController.swift
//  HelloWorld
//
//  Created by Diego Vega on 29/04/26.
//

// DESCRIPCIÓN: Detalle de un personaje. Tabla agrupada (insetGrouped) con 2 secciones:
// físicas (altura, masa, colores) y generales (nacimiento, género, planeta).
// Tabla definida en Main.storyboard. Se instancia via storyboard identifier "CharacterDetail".
//
// FUNCIONES:
// - viewDidLoad(): Incrementa visitCount, asigna delegate/dataSource, carga planeta.
// - fetchHomeworld(): Fetch async del nombre del planeta natal via URL.
//
// NOTAS:
// - visitCount: static, se muestra en ProfileViewController.
// - character se inyecta como propiedad antes de pushViewController.
// - planetName se carga async y recarga la tabla al obtenerlo.

import UIKit

class CharacterDetailViewController: UIViewController {
    
    // MARK: - Componentes visuales
    @IBOutlet weak var detailTable: UITableView!
    
    // Contador global de cuántas veces se ha entrado al detalle de un personaje
    static var visitCount: Int = 0
    
    // Personaje recibido desde la pantalla anterior (se asigna antes de push)
    var character: GetPokemon.Pokemon!
    
    // Nombre del planeta natal obtenido desde el endpoint de SWAPI
    private var planetName: String = "Cargando..."
    
    // Filas mostradas en la sección de características físicas
    private var physicalRows: [(String, String)] {
        [
            ("Altura", character.height ?? "-"),
            ("Masa", character.mass ?? "-"),
            ("Color de cabello", character.hair_color ?? "-"),
            ("Color de piel", character.skin_color ?? "-"),
            ("Ojos", character.eye_color ?? "-")
        ]
    }
    
    // Filas mostradas en la sección de información general
    private var generalRows: [(String, String)] {
        [
            ("Año de nacimiento", character.birth_year ?? "-"),
            ("Género", character.gender ?? "-"),
            ("Planeta natal", planetName)
        ]
    }
    
    // Modelo simple para decodificar el nombre del planeta
    private struct Planet: Codable {
        var name: String?
    }
    
    // MARK: - Ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Incrementa el contador de visitas mostrado en la pantalla de perfil
        CharacterDetailViewController.visitCount += 1
        
        // El título de la pantalla corresponde al nombre del personaje
        title = character.name
        
        // Se asignan delegate y datasource de la tabla
        detailTable.delegate = self
        detailTable.dataSource = self
        detailTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Se solicita el nombre del planeta natal a la API
        fetchHomeworld()
    }
    
    private func fetchHomeworld() {
        guard
            let urlString = character.homeworld,
            let url = URL(string: urlString)
        else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let data = data,
                let planet = try? JSONDecoder().decode(Planet.self, from: data)
            else { return }
            
            DispatchQueue.main.async {
                self?.planetName = planet.name ?? "-"
                self?.detailTable.reloadData()
            }
        }.resume()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CharacterDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Caracteristicas Fisicas" : "Información General"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? physicalRows.count : generalRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.section == 0 ? physicalRows[indexPath.row] : generalRows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = row.0
        content.secondaryText = row.1
        cell.contentConfiguration = content
        return cell
    }
}
