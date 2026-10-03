//
//  Encoding.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

// DESCRIPCIÓN: Tipo de encoding para params de ApiRequestModel.
// url = query string en la URL. json = body JSON.

import Foundation

enum Encoding: String {
    case url
    case json
}
