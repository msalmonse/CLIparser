//
//  OptValueAt.swift
//  
//
//  Created by Michael Salmon on 2021-06-01.
//

import Foundation

/// Value found at argument
public struct OptValueAt {
    let value: String
    let atIndex: Int

    // Short cut
    public var isEmpty: Bool { value.isEmpty }

    public static let empty = OptValueAt(value: "", atIndex: -1)
}

public typealias OptValuesAt = [OptValueAt]

extension OptValueAt {

    /// Convert an OptValueAt to a double
    /// - Parameter val: the value to convert
    /// - Throws: OptGetterError.illegalValue
    /// - Returns: converted Double

    public func doubleValue() throws -> Double {
        if let doubleVal = Double(value) {
            return doubleVal
        } else {
            throw CLIparserError.illegalValue(type: "number", valueAt: self)
        }
    }

    /// Convert an array of OptValueAt to Doubles
    /// - Parameter vals: OptValueAt array
    /// - Throws: OptGetterError.illegalValue
    /// - Returns: Double array

    public static func doubleArray(_ vals: OptValuesAt) throws -> [Double] {
        var result: [Double] = []

        do {
            for val in vals {
                result.append(try val.doubleValue())
            }
        } catch {
            throw error
        }

        return result
    }

    /// Convert an OptValueAt to an Int
    /// - Parameter val: the value to convert
    /// - Throws: OptGetterError.illegalValue
    /// - Returns: converted int

    public func intValue() throws -> Int {
        if let intVal = Int(value) {
            return intVal
        } else {
            throw CLIparserError.illegalValue(type: "whole number", valueAt: self)
        }
    }

    /// Convert an array of OptValueAt to Doubles
    /// - Parameter vals: OptValueAt array
    /// - Throws: OptGetterError.illegalValue
    /// - Returns: Double array

    public static func intArray(_ vals: OptValuesAt) throws -> [Int] {
        var result: [Int] = []

        do {
            for val in vals {
                result.append(try val.intValue())
            }
        } catch {
            throw error
        }

        return result
    }

    /// Convert an OptValueAt to a string
    /// - Parameter val: the value to convert
    /// - Returns: string

    public func stringValue() -> String {
        return value
    }

    /// Convert an array of OptValueAt to strings
    /// - Parameter vals: OptValueAt array
    /// - Returns: String array

    public static func stringArray(_ vals: OptValuesAt) -> [String] {
        return vals.map { $0.value }
    }
}
