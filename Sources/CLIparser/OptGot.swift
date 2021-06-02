//
//  File.swift
//  
//
//  Created by Michael Salmon on 2021-06-01.
//

import Foundation

/// Options found
public class OptGot {
    public var count = 0
    public let opt: OptToGet
    public var optValuesAt: OptValuesAt = []

    // convenience computed properties
    public var doubleValue: Double? { !optValuesAt.isEmpty ? Double(optValuesAt[0].value) : nil }
    public var intValue: Int? { !optValuesAt.isEmpty ? Int(optValuesAt[0].value) : nil }
    public var isEmpty: Bool { optValuesAt.isEmpty }
    public var name: String { opt.long ?? opt.short ?? "???" }
    public var stringValue: String? { !optValuesAt.isEmpty ? optValuesAt[0].value : nil }
    public var tag: CLIparserTag? { opt.tag }

    init(opt: OptToGet) { self.opt = opt }
}

public typealias OptsGot = [OptGot]

/// Options matched

class OptMatch {
    let opt: OptToGet
    var matched: OptGot?
    var long: String? { opt.long }

    init(_ opt: OptToGet) { self.opt = opt}
}
