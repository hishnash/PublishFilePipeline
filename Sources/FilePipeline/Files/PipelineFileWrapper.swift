//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files

public struct PipelineFileWrapper {
    public let file: File
    public let path: PipelinePath
    
    init(file: File, path: PipelinePath) {
        self.file = file
        self.path = path
    }
}

extension PipelineFileWrapper: PipelineSourceFile {
    public var canonical: PipelinePath {
        self.path
    }
}

extension PipelineFileWrapper: PipelineOutputFile {}

extension PipelineFileWrapper: PipelineFile {
    public var source: [any PipelineSourceFile] {
        [self]
    }
    
    public var output: any PipelineOutputFile {
        self
    }
}
