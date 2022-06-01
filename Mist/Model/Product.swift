//
//  Product.swift
//  Mist
//
//  Created by Nindi Gill on 10/3/21.
//

import Foundation

struct Product: Decodable {
    enum CodingKeys: String, CodingKey {
        case identifier = "Identifier"
        case name = "Name"
        case version = "Version"
        case build = "Build"
        case date = "PostDate"
        case distribution = "DistributionURL"
        case packages = "Packages"
        case boardIDs = "BoardIDs"
        case deviceIDs = "DeviceIDs"
        case unsupportedModels = "UnsupportedModels"
    }

    let identifier: String
    let name: String
    let version: String
    let build: String
    let date: String
    let distribution: String
    let packages: [Package]
    let boardIDs: [String]
    let deviceIDs: [String]
    let unsupportedModels: [String]
    var compatible: Bool {
        // Board ID (Intel)
        if !boardIDs.isEmpty,
            let boardID: String = Hardware.boardID,
            !boardIDs.contains(boardID) {
            return false
        }

        // Device ID (Apple Silicon or Intel T2)
        if !deviceIDs.isEmpty,
            let deviceID: String = Hardware.deviceID,
            !deviceIDs.contains(deviceID) {
            return false
        }

        // Model Identifier (Apple Silicon or Intel)
        if !unsupportedModels.isEmpty,
            let modelIdentifier: String = Hardware.modelIdentifier,
            unsupportedModels.contains(modelIdentifier) {
            return false
        }

        return true
    }
    var allDownloads: [Package] {
        [Package(url: distribution, size: 0, integrityDataURL: nil, integrityDataSize: nil)] + packages.sorted { $0.filename < $1.filename }
    }
    var installerURL: URL {
        URL(fileURLWithPath: "/Applications/Install \(name).app")
    }
    var zipName: String {
        "Install \(name) \(version) \(build).zip".replacingOccurrences(of: " ", with: "-")
    }
    var dictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": date,
            "compatible": compatible
        ]
    }
    var exportDictionary: [String: Any] {
        [
            "identifier": identifier,
            "name": name,
            "version": version,
            "build": build,
            "size": size,
            "date": date,
            "compatible": compatible,
            "distribution": distribution,
            "packages": packages.map { $0.dictionary },
            "beta": isBeta
        ]
    }
    var isTooBigForPackagePayload: Bool {
        version.range(of: "^1[1-9]\\.", options: .regularExpression) != nil
    }
    var isBeta: Bool {
        build.range(of: "[a-z]$", options: .regularExpression) != nil
    }
    var size: Int64 {
        Int64(packages.map { $0.size }.reduce(0, +))
    }
    var isoSize: Int64 {
        Int64(ceil(Double(size) / Double(Int64.gigabyte))) + 1
    }
}
