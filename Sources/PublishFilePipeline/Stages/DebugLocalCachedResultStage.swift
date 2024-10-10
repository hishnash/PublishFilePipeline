//
//  DebugLocalCachedResultStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 10/10/2024.
//
import Crypto
import Publish
import Foundation

public struct DebugLocalCachedResultStage: SingleFilePipelineStage {
    @PipelineBuilder
    let content: () -> SingleFilePipelineStage
    
    public init(@PipelineBuilder content: @escaping () -> SingleFilePipelineStage) {
        self.content = content
    }
    
    public func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        #if DEBUG
        var sha = SHA256()
        sha.update(data: try input.output.file.read())
        sha.update(data: try input.canonical.absoluteString.encoded())
        sha.update(data: try self.tags.joined(separator: "\n").encoded())
        let digest = sha.finalize()
        let hash = Data(
            digest
        ).base64EncodedString().replacingOccurrences(
            of: "+",
            with: "-"
        ).replacingOccurrences(
            of: "/", with: "_"
        ).replacingOccurrences(of: "=", with: "")
        
        let file = try context.cacheFile(named: "LocalCachedResultStage.\(hash).data.cached")
        let name = try context.cacheFile(named: "LocalCachedResultStage.\(hash).name.cached")
        guard let data = try? file.read(),
              let nameString = try? name.readAsString(encodedAs: .utf8) else {
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
        #else
        try self.content().run(input: input, on: context)
        #endif
    }
    
    public var tags: [String] {
        self.content().tags
    }
}
