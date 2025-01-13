//
//  FileMergeStage.swift
//  
//
//  Created by Matthaus Woolard on 20/06/2020.
//

import Foundation

public struct FileMergeStage: ReducingFilePipelineStage {
    
    public let tags: [String] = []
    
    let path: PipelinePath
    
    public init (path: PipelinePath) {
        self.path = path
    }
    
    public func run(inputs: [any PipelineFile], on context: PipelineContext) throws -> any PipelineFile {
        
        var data = Data()
        
        for file in inputs {
            data.append(try file.output.file.read())
        }
        
        let file = try PipelineTemporaryStageFile(
            from: inputs,
            with: data,
            path: path
        )
        
       return file
    }
}
