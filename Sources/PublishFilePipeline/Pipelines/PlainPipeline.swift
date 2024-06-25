//
//  PlainPipeline.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//

import Publish

struct PlainPipeline: Pipeline {
    func matches(query: FileQuery) -> Bool {
        true
    }
    
    func run<Site>(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: Publish.PublishingContext<Site>,
        with state: PipelineState
    ) throws -> any PipelineFile where Site : Publish.Website {
        guard case .file(let path, let root) = query else {
            throw FilePipelineErrors.missingPipeline
        }
        
        var file = try state.getRawFile(for: path, root: root, with: context)
        file = try preprocessor.run(input: file, on: context)
        
        return try self.body().run(input: file, on: context)
    }
    
        
    @PipelineBuilder
    let body: () -> SingleFilePipelineStage
}
