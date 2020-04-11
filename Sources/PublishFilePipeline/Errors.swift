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
    case fileNotFound(for: Path)
    case recusiveLookup(for: Path)
    case missingPipeline
}

