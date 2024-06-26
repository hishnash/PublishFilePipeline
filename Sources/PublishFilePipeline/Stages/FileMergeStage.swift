//
//  FileMergeStage.swift
//  
//
//  Created by Matthaus Woolard on 20/06/2020.
//

import Foundation
import Publish

public struct FileMergeStage: ReducingFilePipelineStage {
    
    public let tags: [String] = []
    
    let path: Path
    
    public init (path: Path) {
        self.path = path
    }
    
    public func run<Site>(inputs: [any PipelineFile], on context: Publish.PublishingContext<Site>) throws -> any PipelineFile where Site : Publish.Website {
        
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
