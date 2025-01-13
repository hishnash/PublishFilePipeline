//
//  ReducingFileTypePipeline.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//

struct ReducingFileTypePipeline: Pipeline {
    func matches(query: FileQuery) -> Bool {
        query.fileExtension == self.fileType
    }
    
    func run(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: PipelineContext,
        with state: PipelineState
    ) throws -> any PipelineFile {
        var files = try state.getRawFiles(for: query, with: context)
        files = try preprocessor.run(inputs: files, on: context)
        return try self.body().run(inputs: files, on: context)
    }
    
    
    let fileType: String
    
    @PipelineBuilder
    let body: () -> ReducingFilePipelineStage
}
