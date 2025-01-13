//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files

public enum FilePipelineErrors: Error, LocalizedError {
    case concurrentError
    case fileNotFound(for: PipelinePath)
    case recursiveLookup(for: PipelinePath)
    case missingPipeline
    case notImplemented
    
    public var errorDescription: String? {
        switch self {
        case .concurrentError:
            "Internal concurrency error"
        case .fileNotFound(for: let path):
            "File not found for: \(path)"
        case .recursiveLookup(for: let path):
            "Recursive resolve in \(path)"
        case .missingPipeline:
            "Missing pipeline"
        case .notImplemented:
            "Not Implemented"
        }
    }
}

