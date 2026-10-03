//
//  TestRunLogger.swift
//  HelloWorldTests
//
//  Created by Diego Vega on 27/09/26.
//
//  Guarda el resultado de cada prueba al terminar la ejecución:
//    logs/<target>-resultados.csv  (una fila por prueba)
//    logs/<target>-errores.log     (solo las que fallan)
//  Si no puede escribir en logs/, la ejecución sigue normal y los
//  resultados quedan en el reporte de Xcode.
//

import Foundation
import XCTest

final class TestRunLogger: NSObject, XCTestObservation {

    static let shared = TestRunLogger()
    private static var registered = false

    /// Registra el observador una sola vez por corrida.
    static func registerOnce(target: String, file: String = #filePath) {
        guard !registered else { return }
        registered = true
        shared.target = target
        shared.repoRoot = TestRunLogger.repoRoot(from: file)
        XCTestObservationCenter.shared.addTestObserver(shared)
    }

    private var target = "tests"
    private var repoRoot: URL?
    private var rows: [String] = []
    private var errors: [String] = []
    private var currentIssues: [String] = []
    private var startedAt = Date()

    /// Sube desde .../codigo-fuente/<Target>/Support/Archivo.swift hasta la carpeta que contiene logs/.
    static func repoRoot(from file: String) -> URL? {
        var url = URL(fileURLWithPath: file)
        for _ in 0..<10 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("logs").path) {
                return url
            }
        }
        return nil
    }

    /// Extrae el ID del caso del nombre del método: test_PU_REG_01_descripcion -> PU-REG-01
    static func caseID(from name: String) -> String {
        let method = name.components(separatedBy: " ").last?.replacingOccurrences(of: "]", with: "") ?? name
        let parts = method.components(separatedBy: "_")
        guard parts.count >= 4, parts[0] == "test" else { return method }
        return "\(parts[1])-\(parts[2])-\(parts[3])"
    }

    // MARK: - XCTestObservation

    func testBundleWillStart(_ testBundle: Bundle) {
        startedAt = Date()
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        currentIssues = []
    }

    func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        let location = issue.sourceCodeContext.location
        let where_ = location.map { "\(URL(fileURLWithPath: $0.fileURL.path).lastPathComponent):\($0.lineNumber)" } ?? "-"
        let message = issue.compactDescription.replacingOccurrences(of: "\n", with: " ")
        currentIssues.append("[\(where_)] \(message)")
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        let run = testCase.testRun
        let id = TestRunLogger.caseID(from: testCase.name)
        let status: String
        if run?.hasBeenSkipped == true {
            status = "Omitido"
        } else if run?.hasSucceeded == true {
            status = "Pasa"
        } else {
            status = "Falla"
        }
        let duration = String(format: "%.3f", run?.totalDuration ?? 0)
        let detail = currentIssues.joined(separator: " | ").replacingOccurrences(of: "\"", with: "'")
        rows.append("\"\(id)\",\"\(testCase.name)\",\"\(status)\",\(duration),\"\(detail)\"")
        if status == "Falla" {
            errors.append("\(ISO8601DateFormatter().string(from: Date())) ERROR \(id) \(testCase.name)\n    " +
                          currentIssues.joined(separator: "\n    "))
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        guard let root = repoRoot else { return }
        let fm = FileManager.default
        let stamp = ISO8601DateFormatter().string(from: startedAt)
        let logsDir = root.appendingPathComponent("logs")
        try? fm.createDirectory(at: logsDir, withIntermediateDirectories: true)

        let csv = (["id,metodo,resultado,duracion_s,detalle"] + rows).joined(separator: "\n") + "\n"
        try? csv.write(to: logsDir.appendingPathComponent("\(target)-resultados.csv"), atomically: true, encoding: .utf8)

        let passed = rows.filter { $0.contains("\"Pasa\"") }.count
        let failed = rows.filter { $0.contains("\"Falla\"") }.count
        var log = "Corrida: \(stamp)\nTarget: \(target)\nCasos: \(rows.count)  Pasan: \(passed)  Fallan: \(failed)\n\n"
        log += errors.isEmpty ? "Sin errores.\n" : errors.joined(separator: "\n\n") + "\n"
        try? log.write(to: logsDir.appendingPathComponent("\(target)-errores.log"), atomically: true, encoding: .utf8)
    }
}

/// Clase base: registra el logger y deja el ID del caso en el nombre del método.
class QATestCase: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestRunLogger.registerOnce(target: "unitarias-integracion")
    }
}
