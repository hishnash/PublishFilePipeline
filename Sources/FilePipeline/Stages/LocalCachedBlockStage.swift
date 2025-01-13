//
//  LocalCachedBlockStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 10/10/2024.
//
import Crypto
import Foundation


/**
 This stage will cache the results of the stages it wraps using publish's file cache, the key it uses to cache these is based on the hash and name of the input files.
 
 This stage does not add any tags to the files so should be transparent to manifest.
 */
public struct LocalCachedBlockStage: SingleFilePipelineStage {
    @PipelineBuilder
    let content: () -> SingleFilePipelineStage
    
    
    /**
     Create a local cache block stage
     This takes a pipeline builder that should resolve to a single file pipeline stage.
     */
    public init(@PipelineBuilder content: @escaping () -> SingleFilePipelineStage) {
        self.content = content
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        var sha = SHA256()
        let encoder = JSONEncoder()
        sha.update(data: try input.output.file.read())
        sha.update(data: try encoder.encode(input.canonical.absoluteString))
        sha.update(data: try encoder.encode(self.tags.joined(separator: "\n")))
        
        let digest = sha.finalize()
        
        let hash = Data(
            digest
        ).base64EncodedString().replacingOccurrences(
            of: "+",
            with: "-"
        ).replacingOccurrences(
            of: "/", with: "_"
        ).replacingOccurrences(of: "=", with: "")
        
        let file = try context.cacheFile(named: "LocalCachedBlockStage.\(hash).data.cached")
        let name = try context.cacheFile(named: "LocalCachedBlockStage.\(hash).name.cached")
        guard let data = try? file.read(),
              let nameString = try? name.readAsString(encodedAs: .utf8),
              !data.isEmpty,
              !nameString.isEmpty else {
            let output = try self.content().run(input: input, on: context)
            try file.write(output.output.file.read())
            try name.write(output.canonical.name, encoding: .utf8)
            return output
        }
        
        return try PipelineTemporaryStageFile(
            from: input,
            with: data,
            named: nameString
        )
    }
    
    public var tags: [String] {
        self.content().tags
    }
}
