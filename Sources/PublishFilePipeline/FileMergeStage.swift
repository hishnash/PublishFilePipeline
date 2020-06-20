//
//  FileMergeStage.swift
//  
//
//  Created by Matthaus Woolard on 20/06/2020.
//

import Foundation
import Publish

public struct FileMergeStage: PipelineStage {
    let extention: String
    
    public init (extention: String) {
        self.extention = extention
    }
    
    public func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] where Site : Website {
        
        var data = Data()
        
        for file in files {
            for outputFile in file.output {
                try data.append(outputFile.file.read())
            }
        }
        
        let inputs: [PipelineFileWrapper] = files.flatMap { file in file.output }
        
        let file = try PipelineTemporayStageFile(
            from: inputs,
            with: data,
            named: "merged.\(self.extention)"
        )!
        
        
       return [
            PipelineFileContainer(
                children: [
                    file
                ],
                parents: files.flatMap { file in file.source }
            
            )
        ]
    }
    
    
}
