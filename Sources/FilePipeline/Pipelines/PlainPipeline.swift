//
//  PlainPipeline.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//

struct PlainPipeline: Pipeline {
    func matches(query: FileQuery) -> Bool {
        true
    }
    
    func run(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: PipelineContext,
        with state: PipelineState
    ) throws -> any PipelineFile {
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
