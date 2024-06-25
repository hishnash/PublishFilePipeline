//
//  RegexPipeline.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//
import Publish

struct RegexPipeline: Pipeline {
    
    func matches(query: FileQuery) -> Bool {
        switch query {
        case .file(let path, _):
            (try? self.pattern.wholeMatch(in: path.string)) != nil
        default:
            false
        }
        
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
    
    
    let pattern: Regex<Substring>
    
    @PipelineBuilder
    let body: () -> SingleFilePipelineStage
}
