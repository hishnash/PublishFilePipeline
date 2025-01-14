//
//  PipelineBuilder.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 14/01/2025.
//


import Foundation

@resultBuilder
public struct PipelineBuilder {
    
    public static func buildEither(first component: SingleFilePipelineStage) -> SingleFilePipelineStage {
        component
    }
    
    public static func buildEither(second component: SingleFilePipelineStage) -> SingleFilePipelineStage {
        component
    }
    
    
    public static func buildEither(first component: ExpandingFilePipelineStage) -> ExpandingFilePipelineStage {
        component
    }
    
    public static func buildEither(second component: ExpandingFilePipelineStage) -> ExpandingFilePipelineStage {
        component
    }
    
    public static func buildEither(first component: ReducingFilePipelineStage) -> ReducingFilePipelineStage {
        component
    }
    
    public static func buildEither(second component: ReducingFilePipelineStage) -> ReducingFilePipelineStage {
        component
    }
    
    public static func buildEither(first component: MultiFilePipelineStage) -> MultiFilePipelineStage {
        component
    }
    
    public static func buildEither(second component: MultiFilePipelineStage) -> MultiFilePipelineStage {
        component
    }
    
    
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
    
    public static func buildOptional(_ component: SingleFilePipelineStage?) -> SingleFilePipelineStage {
        component
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
