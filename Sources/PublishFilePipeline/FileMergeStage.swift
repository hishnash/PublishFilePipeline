//
//  FileMergeStage.swift
//  
//
//  Created by Matthaus Woolard on 20/06/2020.
//

import Foundation
import Publish

public struct FileMergeStage: PipelineStage {
    let fileExtension: String
    
    public init (fileExtension: String) {
        self.fileExtension = fileExtension
    }
    
    public func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] where Site : Website {
        
        var data = Data()
        
        for file in files {
            for outputFile in file.output {
                try data.append(outputFile.file.read())
            }
        }
        
        let inputs: [PipelineFileWrapper] = files.flatMap { file in file.output }
        
        let file = try PipelineTemporaryStageFile(
            from: inputs,
            with: data,
            named: "merged.\(self.fileExtension)"
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
