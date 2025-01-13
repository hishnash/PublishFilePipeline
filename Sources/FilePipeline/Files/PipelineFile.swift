//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files


public protocol PipelineFile {
    var source: [PipelineSourceFile] { get }
    var output: PipelineOutputFile { get }
    
    // URL for the primary file
    var canonical: PipelinePath { get }
}


public protocol PipelineSourceFile {
    var canonical: PipelinePath { get }
    
    var file: File { get }
}

public protocol PipelineOutputFile {
    var file: File { get }
}




struct RenamedPipelineFile: PipelineFile {
    var source: [any PipelineSourceFile] {
        self.wrapped.source
    }
    
    var output: any PipelineOutputFile {
        self.wrapped.output
    }
    
    var canonical: PipelinePath {
        self.wrapped.canonical.replacing(name: name)
    }
    
    var wrapped: PipelineFile
    var name: String
    
    init(wrapped: PipelineFile, name: String) {
        self.wrapped = wrapped
        self.name = name
    }
}
