//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish


public protocol PipelineFile {
    var source: [PipelineSourceFile] { get }
    var output: PipelineOutputFile { get }
    
    // URL for the primary file
    var canonical: Path { get }
}


public protocol PipelineSourceFile {
    var canonical: Path { get }
    
    var file: File { get }
}

public protocol PipelineOutputFile {
    var file: File { get }
}

extension Path {
    
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
    
    func replacing(name: String) -> Path {
        self.deletingLastPathComponent().appendingComponent(name)
    }
}


struct RenamedPipelineFile: PipelineFile {
    var source: [any PipelineSourceFile] {
        self.wrapped.source
    }
    
    var output: any PipelineOutputFile {
        self.wrapped.output
    }
    
    var canonical: Publish.Path {
        self.wrapped.canonical.replacing(name: name)
    }
    
    var wrapped: PipelineFile
    var name: String
    
    init(wrapped: PipelineFile, name: String) {
        self.wrapped = wrapped
        self.name = name
    }
}
