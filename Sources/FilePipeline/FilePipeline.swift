//
//  FilePipeline.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 13/01/2025.
//
import RegexBuilder
import Files
import Foundation

public struct FilePipeline {
    static public func addPipeline(
        for pattern: Regex<Substring>,
        @PipelineBuilder with stages: @escaping () -> SingleFilePipelineStage
    ) {
        PipelineState.shared.addPipeline(
            RegexPipeline(pattern: pattern, body: stages)
        )
    }
    
    static public func addPipeline(
        forType: String,
        @PipelineBuilder with stages: @escaping () -> ReducingFilePipelineStage
    ) {
        PipelineState.shared.addPipeline(
            ReducingFileTypePipeline(fileType: forType, body: stages)
        )
    }
    
    static public func addPipeline(
        @PipelineBuilder with stages: @escaping () -> SingleFilePipelineStage
    ) {
        PipelineState.shared.addPipeline(
            PlainPipeline(body: stages)
        )
    }
    
    static public func copyPipelineFiles(with context: PipelineContext) throws {
        for pipelineFile in PipelineState.shared.getAllOutputs() {
            if pipelineFile is StaticManifest.StaticManifestPipelineFile {
                // Skipping static manifest files
                continue
            }
            
            let outputFile = pipelineFile.output.file
            try context.copyToOutput(
                outputFile,
                to: pipelineFile.canonical.deletingLastPathComponent(),
                with: pipelineFile.canonical.name
            )
        }
    }
    
    static public func load(manifest: StaticManifest) {
        PipelineState.shared.load(manifest: manifest)
    }
    
    static public func writePipelineManifest(
        staticDomain: URL,
        filePath: PipelinePath,
        with context: PipelineContext
    )  throws {
        let outputs = PipelineState.shared.getStaticOutputs()
        let manifest = StaticManifest(staticDomain: staticDomain, files: outputs)
        let encoder = try JSONEncoder().encode(manifest)
        let file = try context.createOutputFile(at: filePath)
        try file.write(encoder)
    }
    
    static public func reset() {
        PipelineState.shared = PipelineState()
    }
    
    static public func add(
        _ file: File,
        at resourcePath: PipelinePath,
        with originPath: PipelinePath
    ) {
        PipelineState.shared.add(
            file: file,
            at: resourcePath,
            with: originPath
        )
    }
    
    static public func getRawFile(
        for resourcePath: PipelinePath,
        root originPath: PipelinePath,
        with context: PipelineContext
    ) throws -> File {
        try PipelineState.shared.getRawFile(
            for: resourcePath,
            root: originPath,
            with: context
        ).output.file
    }
    
    static public func resolvedPath(
        for query: FileQuery,
        @PipelineBuilder preprocessor: () -> SingleFilePipelineStage,
        on context: PipelineContext
    ) throws -> PipelinePath {
        try PipelineState.shared.resolvedPath(
            for: query,
            preprocessor: preprocessor,
            on: context
        )
    }
}


