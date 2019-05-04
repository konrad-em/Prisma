//
//  ModelBuilding.swift
//  Prisma
//
//  Created by Konrad Em on 18/03/2019.
//  Copyright © 2019 Perpetuum. All rights reserved.
//

import Foundation

protocol ModelBuilding {
    static func build() throws -> StyleTransfer
}

extension StyleTransfer: ModelBuilding {
    enum Error: Swift.Error {
        case invalidModelUrl
        case unableToInitializeModel
    }
    
    static func build() throws -> StyleTransfer {
        guard let url = Bundle.main.url(forResource: String(describing: self), withExtension:"mlmodelc") else { throw Error.invalidModelUrl }
        do {
            return try StyleTransfer(contentsOf: url)
        } catch {
            throw Error.unableToInitializeModel
        }
    }
}
