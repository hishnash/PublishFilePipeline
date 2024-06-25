//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files

public enum FilePipelineErrors: Error {
    case concurrentError
    case fileNotFound(for: Path)
    case recursiveLookup(for: Path)
    case missingPipeline
}

