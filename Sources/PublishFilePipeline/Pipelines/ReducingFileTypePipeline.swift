//
//  ReducingFileTypePipeline.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//
import Publish

struct ReducingFileTypePipeline: Pipeline {
    func matches(query: FileQuery) -> Bool {
        query.fileExtension == self.fileType
    }
    
    func run<Site>(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: Publish.PublishingContext<Site>,
        with state: PipelineState
    ) throws -> any PipelineFile where Site : Publish.Website {
        var files = try state.getRawFiles(for: query, with: context)
        files = try preprocessor.run(inputs: files, on: context)
        return try self.body().run(inputs: files, on: context)
    }
    
    
    let fileType: String
    
    @PipelineBuilder
    let body: () -> ReducingFilePipelineStage
}
