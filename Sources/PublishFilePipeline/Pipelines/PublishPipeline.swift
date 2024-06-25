//
//  PublishPipeline.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish


protocol Pipeline {
    func matches(query: FileQuery) -> Bool
    func run<Site>(
        query: FileQuery,
        preprocessor: SingleFilePipelineStage,
        on context: PublishingContext<Site>,
        with state: PipelineState
    ) throws -> PipelineFile
}




internal struct SingleFilePipelineGroup: SingleFilePipelineStage {
    var tags: [String] { stages.flatMap {$0.tags} }
    
    let stages: [any SingleFilePipelineStage]
    
    func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        var output = input
        for state in stages {
            output = try state.run(input: output, on: context)
        }
        return output
    }
}

internal struct MultiFilePipelineGroup: MultiFilePipelineStage {
    let stages: [any MultiFilePipelineStage]
    
    func run<Site>(
        inputs: [any PipelineFile],
        on context: PublishingContext<Site>
    ) throws -> [any PipelineFile] where Site : Website {
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
    
    func run<Site>(
        inputs: [any PipelineFile],
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
    
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
    
    func run<Site>(input: any PipelineFile, on context: Publish.PublishingContext<Site>) throws -> [any PipelineFile] where Site : Publish.Website {
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
    
    func run<Site>(input: any PipelineFile, on context: Publish.PublishingContext<Site>) throws -> [any PipelineFile] where Site : Publish.Website {
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
    
    func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
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
    
    func run<Site>(
        inputs: [any PipelineFile],
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        let output = try self.accumulated.run(inputs: inputs, on: context)
        return try next.run(input: output, on: context)
    }
    
    var tags: [String] {
        accumulated.tags + next.tags
    }
}



@resultBuilder
public struct PipelineBuilder {
    public static func buildPartialBlock(first: ExpandingFilePipelineStage) -> ExpandingFilePipelineStage {
        first
    }
    
    public static func buildPartialBlock(first: ReducingFilePipelineStage) -> ReducingFilePipelineStage {
        first
    }
    
    public static func buildPartialBlock(first: SingleFilePipelineStage) -> SingleFilePipelineStage {
        first
    }
    
    public static func buildPartialBlock(first: MultiFilePipelineStage) -> MultiFilePipelineStage {
        first
    }
    
    public static func buildPartialBlock(
        accumulated: MultiFilePipelineStage,
        next: ReducingFilePipelineStage
    ) -> ReducingFilePipelineStage {
        ReducingFilePipelineGroup(first: accumulated, reduce: next)
    }
    
    public static func buildPartialBlock(
        accumulated: ReducingFilePipelineStage,
        next: SingleFilePipelineStage
    ) -> ReducingFilePipelineStage {
        ReducedFilePipelineGroup(accumulated: accumulated, next: next)
    }
    
    public static func buildPartialBlock(
        accumulated: ExpandingFilePipelineStage,
        next: MultiFilePipelineStage
    ) -> ExpandingFilePipelineStage {
        InitialExpandingFilePipelineGroup(accumulated: accumulated, next: next)
    }
    
    public static func buildPartialBlock(
        accumulated: SingleFilePipelineStage,
        next: ExpandingFilePipelineStage
    ) -> ExpandingFilePipelineStage {
        DeferredExpandingFilePipelineGroup(accumulated: accumulated, next: next)
    }
    
    public static func buildPartialBlock(
        accumulated: ExpandingFilePipelineStage,
        next: ReducingFilePipelineStage
    ) -> SingleFilePipelineStage {
        ExpandingReducingFilePipelineGroup(accumulated: accumulated, next: next)
    }
    
    public static func buildPartialBlock(
        accumulated: SingleFilePipelineStage,
        next: SingleFilePipelineStage
    ) -> SingleFilePipelineStage {
        SingleFilePipelineGroup(stages: [accumulated, next])
    }
    
    public static func buildPartialBlock(
        accumulated: MultiFilePipelineStage,
        next: MultiFilePipelineStage
    ) -> MultiFilePipelineStage {
        MultiFilePipelineGroup(stages: [accumulated, next])
    }
    
    
}
