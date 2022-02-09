//
//  OptionalExtension.swift
//  screenshot
//
//  Created by lian on 2022/2/9.
//

import Foundation

extension Optional {
    @discardableResult
    func unwrap(file: String = #file, function: String = #function, line: Int = #line) throws -> Wrapped {
        if let unwrapped = self { return unwrapped }
        throw AppError(file: file, function: function, line: line)
    }
}
public struct AppError: Error, CustomStringConvertible {
    
    public var description: String {
        return _description
    }
    
    public init(file: String = #file, function: String = #function, line: Int = #line) {
        _description = "error at " + (file as NSString).lastPathComponent + ":\(line)"
    }
    
    private let _description: String
}
