//
//  stderr.swift
//  csv2svg
//
//  Created by Michael Salmon on 2021-03-02.
//
// From https://nshipster.com/textoutputstream/

import func Darwin.fputs
import var Darwin.stderr

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

var standardError = StderrOutputStream()
