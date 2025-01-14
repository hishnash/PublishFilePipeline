//
//  ImageAsFallbackFormatStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 14/01/2025.
//


public struct If: SingleFilePipelineStage {
    public protocol PipelineCondition {
        func evaluate(
            input: any PipelineFile,
            on context: PipelineContext
        ) throws -> Bool
        
        var tag: String { get }
    }
        
    @PipelineBuilder
    let truePathway: SingleFilePipelineStage
    
    @PipelineBuilder
    let falsePathway: SingleFilePipelineStage
    let condition: PipelineCondition
    
    public init(
        condition: PipelineCondition,
        @PipelineBuilder _ truePathway: @escaping () -> SingleFilePipelineStage,
        @PipelineBuilder else falsePathway: @escaping () -> SingleFilePipelineStage
    ) {
        self.condition = condition
        self.truePathway = truePathway()
        self.falsePathway = falsePathway()
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let result = try condition.evaluate(input: input, on: context)
        if result {
            return try truePathway.run(input: input, on: context)
        } else {
            return try falsePathway.run(input: input, on: context)
        }
    }
    
    public var tags: [String] {
        self.truePathway.tags.map {
            "if-\(condition.tag)-\($0)"
        } + self.falsePathway.tags.map {
            "else-\(condition.tag)-\($0)"
        }
    }
}
