//
//  ApiService.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

// DESCRIPCIÓN: Singleton HTTP que ejecuta peticiones REST.
// Construye URLRequest desde ApiRequestModel, maneja headers,
// encoding (URL/JSON), timeouts de 60s y decodificación genérica.
//
// FUNCIONES:
// - request(): Ejecuta petición async, decodifica respuesta a tipo T genérico.
// - query(): Convierte diccionario de params a query string URL-encoded.
// - queryComponents(): Descompone recursivamente clave-valor para query (soporta dict, array, bool).
// - escape(): Percent-encoding de strings para URL (RFC 3986).
//
// NOTAS:
// - Uso: ApiService.shared.request(model, Tipo.self)
// - Solo acepta respuestas con status 200. 500 = serverError, otro = generalError.
// - NSNumber.isBool: extensión privada para distinguir Bool de Number.

import Foundation

class ApiService: NSObject {
    
    // Declaración de las variables
    static let shared = ApiService()
    private let configuration: URLSessionConfiguration
    private let bearerToken = "" // Token de autenticación
    private lazy var session = URLSession(configuration: self.configuration) // Crea la sesión reutilizable
    
    
    // Se definen los timeouts
    override init() {
        self.configuration = URLSessionConfiguration.default
        self.configuration.timeoutIntervalForRequest = 60 // 60 s para poder iniciar la solicitud
        self.configuration.timeoutIntervalForResource = 60 // 60 s para poder completar la respuesta de la API
    }
    
    func request<T: Decodable>(_ requestModel: ApiRequestModel, _ modelType: T.Type) async throws -> T {
        
        // Se construye la URL del servicio utilizando el endpoint recibido
        guard
            let serviceUrl = URLComponents(string: BaseUrl.getUrl(with: requestModel.endpoint)),
            let url = serviceUrl.url
        else {
            throw NetworkingError.invalidURL
        }
        
        // Se crea la solicitud HTTP con la URL generada
        var request = URLRequest(url: url)
        
        // Se asigna el método HTTP correspondiente
        request.httpMethod = requestModel.method.rawValue
        
        // Se indica que la respuesta esperada será en formato JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Se valida si la solicitud necesita encabezado de autorización
        switch requestModel.header {
        case .Authorization:
            request.setValue(self.bearerToken, forHTTPHeaderField: "Authorization")
            
        case .noHeader: break // do nothing
        }
        
        // Se agregan los parámetros a la solicitud si existen
        if let parameters = requestModel.parameters {
            switch requestModel.encoding {
            case .url:
                // Se agregan los parámetros dentro de la URL como query params
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let percentEncodedQuery = (urlComponents?.percentEncodedQuery.map { $0 + "&" } ?? "") + self.query(parameters)
                urlComponents?.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents?.url
                
            case .json:
                // Se agregan los parámetros dentro del cuerpo de la solicitud en formato JSON
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }
        
        // Se convierte el body a texto para poder imprimirlo en consola
        let parameters = String(data: request.httpBody ?? Data(), encoding: .utf8)
        
        // Se imprime la información de la solicitud para depuración
        print("-------- REQUEST --------")
        print("METHOD: \(requestModel.method.rawValue)")
        print("HEADERS: \(request.allHTTPHeaderFields ?? ["":""])")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("BODY: \(parameters ?? "")")
        
        do {
            // Se ejecuta la solicitud de forma asíncrona
            let (data, response) = try await self.session.data(for: request)
            
            // Se valida que la respuesta sea de tipo HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.httpResponseError
            }
            
            // Se valida si la respuesta fue exitosa
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                
                // Se decodifica la respuesta JSON al modelo recibido
                let decodeData = try decoder.decode(T.self, from: data)
                
                // Se imprime la respuesta obtenida para depuración
                print("-------- REPSONSE --------")
                print("\( String(data: data, encoding: .utf8) ?? "")")
                
                // Se retorna el modelo decodificado
                return decodeData
            }
            else if httpResponse.statusCode == 500 {
                // Error interno del servidor
                throw NetworkingError.serverError
            }
            else {
                // Error general para otros códigos de respuesta
                throw NetworkingError.generalError
            }
        }
        catch {
            // Se valida si el error fue causado por tiempo de espera agotado
            if (error as? URLError)?.code == .timedOut {
                throw NetworkingError.timeOut
            }
            // Se valida si la conexión se perdió durante la solicitud
            else if (error as? URLError)?.code == .networkConnectionLost {
                throw NetworkingError.connectionLost
            }
            
            // Error general si no coincide con los casos anteriores
            throw NetworkingError.generalError
        }
    }
    
    func query(_ parameters: ParameterType) -> String {
        // Arreglo donde se almacenan los parámetros convertidos a texto
        var components: [(String, String)] = []
        
        // Se recorren las llaves ordenadas alfabéticamente
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            
            // Se generan los componentes de query para cada parámetro
            components += self.queryComponents(fromKey: key, value: value)
        }
        
        // Se unen los parámetros con el formato key=value separados por &
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        // Arreglo donde se almacenan los componentes individuales de la query
        var components: [(String, String)] = []
        
        // Se valida si el valor es un diccionario
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                // Se construye la llave anidada y se procesa nuevamente
                components += self.queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        }
        // Se valida si el valor es un arreglo
        else if let array = value as? [Any] {
            for value in array {
                // Se construye la llave como arreglo y se procesa cada valor
                components += self.queryComponents(fromKey: "\(key)[]", value: value)
            }
        }
        // Se valida si el valor es de tipo NSNumber
        else if let value = value as? NSNumber {
            if value.isBool {
                // Se agrega el valor booleano codificado
                components.append((self.escape(key), self.escape("\(value.boolValue)")))
            } else {
                // Se agrega el valor numérico codificado
                components.append((self.escape(key), self.escape("\(value)")))
            }
        }
        // Se valida si el valor es de tipo Bool
        else if let bool = value as? Bool {
            components.append((self.escape(key), self.escape("\(bool)")))
        }
        else {
            // Se agrega cualquier otro tipo de valor como texto codificado
            components.append((self.escape(key), self.escape("\(value)")))
        }
        
        // Se retornan los componentes generados
        return components
    }
    
    func escape(_ string: String) -> String {
        // Caracteres generales que deben codificarse en la URL
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        
        // Subdelimitadores que también deben codificarse
        let subDelimitersToEncode = "!$&'()*+,;="
        
        // Se obtiene el conjunto de caracteres permitidos en una query URL
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        
        // Se eliminan los caracteres que deben codificarse
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        // Se retorna el texto codificado, o el texto original si no se pudo codificar
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
// MARK: - Convenience checks
fileprivate extension NSNumber {
    
    // Verifica si el NSNumber realmente representa un valor booleano
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}
