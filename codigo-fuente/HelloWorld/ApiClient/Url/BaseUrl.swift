//
//  BaseUrl.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

// DESCRIPCIÓN: Construye URLs completas del API concatenando base + endpoint.
// Base actual: https://swapi.info/api/ (SWAPI - Star Wars API).
//
// FUNCIONES:
// - getBaseUrl(): Retorna la URL base del API.
// - getUrl(with:): Concatena base + endpoint.rawValue.
//
// NOTAS:
// - Para cambiar de ambiente (dev/qa/pro), modificar la URL en getBaseUrl().

import Foundation

struct BaseUrl {
    
    static func getBaseUrl() -> String {
        do {
            let url: String = "https://swapi.info/api/"
            return url
        }
        catch {
            fatalError("review configuration variables")
        }
    }
    
    static func getUrl(with endpoint: Endpoint) -> String {
        let url = self.getBaseUrl()
        return url + endpoint.rawValue
    }
}
