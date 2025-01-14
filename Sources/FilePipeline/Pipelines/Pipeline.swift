//
//  PublishPipeline.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation


protocol Pipeline {
    func matches(query: FileQuery) -> Bool
    func run(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: PipelineContext,
        with state: PipelineState
    ) throws -> PipelineFile
}




internal struct SingleFilePipelineGroup: SingleFilePipelineStage {
    var tags: [String] { stages.flatMap {$0.tags} }
    
    let stages: [any SingleFilePipelineStage]
    
    func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        var output = input
        for state in stages {
            output = try state.run(input: output, on: context)
        }
        return output
    }
}

internal struct MultiFilePipelineGroup: MultiFilePipelineStage {
    let stages: [any MultiFilePipelineStage]
    
    func run(
        inputs: [any PipelineFile],
        on context: PipelineContext
    ) throws -> [any PipelineFile] {
        var outputs = inputs
        for state in stages {
            outputs = try state.run(inputs: outputs, on: context)
        }
        return outputs
    }
    
    var tags: [String]  { stages.flatMap { $0.tags } }
}


internal struct ReducingFilePipelineGroup: ReducingFilePipelineStage {
    
    
    let first: MultiFilePipelineStage
    let reduce: ReducingFilePipelineStage
    
    func run(
        inputs: [any PipelineFile],
        on context: PipelineContext
    ) throws -> any PipelineFile {
    
        let outputs = try self.first.run(inputs: inputs, on: context)
        return try self.reduce.run(inputs: outputs, on: context)
    }
    
    var tags: [String] {
        first.tags + reduce.tags
    }
}

internal struct InitialExpandingFilePipelineGroup: ExpandingFilePipelineStage {
   
    let accumulated: ExpandingFilePipelineStage
    let next: MultiFilePipelineStage
    
    func run(input: any PipelineFile, on context: PipelineContext) throws -> [any PipelineFile] {
        let outputs = try self.accumulated.run(input: input, on: context)
        return try next.run(inputs: outputs, on: context)
    }
    
    var tags: [String] {
        accumulated.tags + next.tags
    }
    
}

internal struct DeferredExpandingFilePipelineGroup: ExpandingFilePipelineStage {
   
    let accumulated: SingleFilePipelineStage
    let next: ExpandingFilePipelineStage
    
    func run(input: any PipelineFile, on context: PipelineContext) throws -> [any PipelineFile] {
        let output = try self.accumulated.run(input: input, on: context)
        return try next.run(input: output, on: context)
    }
    
    var tags: [String] {
        accumulated.tags + next.tags
    }
}


internal struct ExpandingReducingFilePipelineGroup: SingleFilePipelineStage {
   
    let accumulated: ExpandingFilePipelineStage
    let next: ReducingFilePipelineStage
    
    func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let outputs = try self.accumulated.run(input: input, on: context)
        return try next.run(inputs: outputs, on: context)
    }
    
    var tags: [String] {
        accumulated.tags + next.tags
    }
}

internal struct ReducedFilePipelineGroup: ReducingFilePipelineStage {
   
    let accumulated: ReducingFilePipelineStage
    let next: SingleFilePipelineStage
    
    func run(
        inputs: [any PipelineFile],
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let output = try self.accumulated.run(inputs: inputs, on: context)
        return try next.run(input: output, on: context)
    }
    
    var tags: [String] {
        accumulated.tags + next.tags
    }
}



extension Optional: MultiFilePipelineStage where Wrapped == SingleFilePipelineStage {}

extension Optional: SingleFilePipelineStage where Wrapped == SingleFilePipelineStage {
    public func run(input: any PipelineFile, on context: any PipelineContext) throws -> any PipelineFile {
        try self?.run(input: input, on: context) ?? input
    }
    
    public var tags: [String] {
        self?.tags ?? []
    }
}
