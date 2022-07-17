//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish

public struct PipelineFileWrapper {
    public init(file: File, path: Path) {
        self.file = file
        self.canonical = path
    }
    
    public var file: File
    public var canonical: Path
}


extension PipelineFileWrapper: PipelineFile {
    public var source: [PipelineFileWrapper] {
        return [self]
    }
    
    public var output: [PipelineFileWrapper] {
        return [self]
    }
}
