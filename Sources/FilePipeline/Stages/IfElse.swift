//
//  ImageAsFallbackFormatStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 14/01/2025.
//


public struct IfElse: SingleFilePipelineStage {
    public protocol PipelineCondition {
        static func evaluate(
            input: any PipelineFile,
            on context: PipelineContext
        ) throws -> Bool
        
        static var tag: String { get }
    }
        
    @PipelineBuilder
    let truePathway: SingleFilePipelineStage
    
    @PipelineBuilder
    let falsePathway: SingleFilePipelineStage
    let condition: PipelineCondition.Type
    
    public init(
        condition: PipelineCondition.Type,
        @PipelineBuilder true truePathway: @escaping () -> SingleFilePipelineStage,
        @PipelineBuilder false falsePathway: @escaping () -> SingleFilePipelineStage
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
            "ifElse-\(condition.tag)-true-\($0)"
        } + self.falsePathway.tags.map {
            "ifElse-\(condition.tag)-false-\($0)"
        }
    }
}
