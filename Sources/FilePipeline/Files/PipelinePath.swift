//
//  Path.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 13/01/2025.
//
import Foundation

public struct PipelinePath: CustomStringConvertible,
                           ExpressibleByStringInterpolation,
                            Comparable,
                           Codable,
                           Hashable {
    public var description: String {
        self.string
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.string < rhs.string
    }
    
    public var string: String

    public init(_ string: String) {
        self.string = string
    }
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.string = stringInterpolation.description
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(from decoder: Decoder) throws {
        try self.init(decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.string)
    }
}

public extension PipelinePath {

    var absoluteString: String {
        guard !string.hasPrefix("/") else { return string }
        guard !string.hasPrefix("http://") else { return string }
        guard !string.hasPrefix("https://") else { return string }
        return "/\(string)"
    }

    func appendingComponent(_ component: String) -> Self {
        guard !string.isEmpty else {
            return Self(component)
        }

        let component = component.drop(while: { $0 == "/" })
        let separator = (string.last == "/" ? "" : "/")
        return "\(string)\(separator)\(component)"
    }
}

extension PipelinePath {
    func deletingLastPathComponent() -> PipelinePath {
        let path = self.string.split(separator: "/").dropLast().joined(separator: "/")
        return PipelinePath(path)
    }
    
    var fileExtension: String? {
        URL(filePath: self.string).pathExtension
    }
}


extension PipelinePath {
    
    /// A URL representation of the location's `path`.
    var url: URL {
        return URL(fileURLWithPath: self.string)
    }

    /// The name of the location, including any `extension`.
    var name: String {
        return url.pathComponents.last!
    }

    /// The name of the location, excluding its `extension`.
    var nameExcludingExtension: String {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return name }
        return components.dropLast().joined()
    }

    /// The file extension of the item at the location.
    var `extension`: String? {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return nil }
        return String(components.last!)
    }
    
    func replacing(name: String) -> PipelinePath {
        self.deletingLastPathComponent().appendingComponent(name)
    }
}
