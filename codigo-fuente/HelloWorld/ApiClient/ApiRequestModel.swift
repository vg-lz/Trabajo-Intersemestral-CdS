//
//  ApiRequestModel.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

// DESCRIPCIÓN: Struct que agrupa los datos de una solicitud HTTP.
// Se pasa como parámetro único a ApiService.request().
//
// NOTAS:
// - endpoint: ruta del API. method: verbo HTTP. header: con/sin auth.
// - encoding: url (query params) o json (body). parameters: opcionales.

import Foundation

struct ApiRequestModel {
    let endpoint: Endpoint
    let method: HTTPMethod
    let header: Header
    let encoding: Encoding
    let parameters: ParameterType?
}
